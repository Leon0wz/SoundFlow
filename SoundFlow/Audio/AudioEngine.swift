import AVFoundation

@Observable
@MainActor
final class AudioEngine {
    static let shared = AudioEngine()

    var isRunning = false

    private let engine = AVAudioEngine()
    private var mainMixerNode = AVAudioMixerNode()
    private var activeGenerators: [UUID: any GeneratorProtocol] = [:]
    private var updateTask: Task<Void, Never>?
    private var fadeTimer: Timer?

    private static let stereoFormat = AVAudioFormat(
        standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
        channels: 2
    )!

    private init() {
        setupSession()
        setupGraph()
    }

    // MARK: - Setup

    private func setupSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func setupGraph() {
        engine.attach(mainMixerNode)
        engine.connect(mainMixerNode, to: engine.outputNode, format: Self.stereoFormat)
    }

    // MARK: - Playback

    func play(scene: SoundScene) {
        stop()

        let enabled = scene.layers.filter { $0.isEnabled }
        for layer in enabled {
            let gen = createGenerator(for: layer.generatorType)
            gen.volume    = layer.volume
            gen.pitch     = layer.pitch
            gen.intensity = layer.intensity
            engine.attach(gen.outputNode)
            engine.connect(gen.outputNode, to: mainMixerNode, format: Self.stereoFormat)
            gen.start()
            activeGenerators[layer.id] = gen
        }

        do {
            try engine.start()
            isRunning = true
            startUpdateLoop()
        } catch {
            print("AudioEngine.play failed: \(error)")
        }
    }

    func stop() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        updateTask?.cancel()
        updateTask = nil

        // 1. Signal generators to output silence (render blocks check isRunning first)
        activeGenerators.values.forEach { $0.stop() }

        // 2. Stop the audio thread BEFORE detaching nodes — prevents render-thread crash
        if engine.isRunning {
            engine.stop()
        }

        // 3. Safe to detach now that the audio thread is stopped
        activeGenerators.values.forEach { engine.detach($0.outputNode) }
        activeGenerators.removeAll()

        isRunning = false
    }

    func pause() {
        engine.pause()
        isRunning = false
    }

    func resume() {
        do {
            try engine.start()
            isRunning = true
        } catch {
            print("AudioEngine.resume failed: \(error)")
        }
    }

    // MARK: - Layer Control

    func updateLayer(id: UUID, volume: Float? = nil, pitch: Float? = nil, intensity: Float? = nil) {
        guard let gen = activeGenerators[id] else { return }
        if let v = volume    { gen.volume    = v }
        if let p = pitch     { gen.pitch     = p }
        if let i = intensity { gen.intensity = i }
    }

    // MARK: - Fade

    func fadeOut(duration: Double = 30.0) {
        let startVolume = mainMixerNode.outputVolume
        let steps = 30
        let interval = duration / Double(steps)
        var step = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            step += 1
            let fraction = Float(step) / Float(steps)
            // Timer fires on main thread — safe to assume main actor isolation
            MainActor.assumeIsolated {
                self.mainMixerNode.outputVolume = startVolume * (1.0 - fraction)
                if step >= steps {
                    timer.invalidate()
                    self.stop()
                    self.mainMixerNode.outputVolume = 1.0
                }
            }
        }
    }

    // MARK: - Update Loop

    private func startUpdateLoop() {
        updateTask = Task { [weak self] in
            var lastTime = Date()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 16_666_667) // ~60 Hz
                let now = Date()
                let dt = now.timeIntervalSince(lastTime)
                lastTime = now
                await MainActor.run {
                    self?.activeGenerators.values.forEach { $0.update(deltaTime: dt) }
                }
            }
        }
    }

    // MARK: - Factory

    private func createGenerator(for type: GeneratorType) -> any GeneratorProtocol {
        switch type {
        case .whiteNoise:  NoiseGenerator(type: .whiteNoise)
        case .pinkNoise:   NoiseGenerator(type: .pinkNoise)
        case .brownNoise:  NoiseGenerator(type: .brownNoise)
        case .rain:        RainGenerator(type: .rain)
        case .heavyRain:   RainGenerator(type: .heavyRain)
        case .drizzle:     RainGenerator(type: .drizzle)
        case .ocean:       WaveGenerator(type: .ocean)
        case .waves:       WaveGenerator(type: .waves)
        case .wind:        WindGenerator(type: .wind)
        case .breeze:      WindGenerator(type: .breeze)
        case .gust:        WindGenerator(type: .gust)
        case .thunder:     ThunderGenerator()
        case .birds:       BirdGenerator(type: .birds)
        case .crickets:    BirdGenerator(type: .crickets)
        case .frogs:       BirdGenerator(type: .frogs)
        case .fire:        FireGenerator(type: .fire)
        case .campfire:    FireGenerator(type: .campfire)
        case .forest:      ForestGenerator(type: .forest)
        case .jungle:      ForestGenerator(type: .jungle)
        case .city:        CityGenerator(type: .city)
        case .cafe:        CityGenerator(type: .cafe)
        case .traffic:     CityGenerator(type: .traffic)
        case .space:       SpaceGenerator(type: .space)
        case .drone:       SpaceGenerator(type: .drone)
        case .stream:      StreamGenerator(type: .stream)
        case .river:       StreamGenerator(type: .river)
        case .waterfall:   StreamGenerator(type: .waterfall)
        case .underwater:  UnderwaterGenerator()
        case .cave:        CaveGenerator(type: .cave)
        case .drops:       CaveGenerator(type: .drops)
        case .pad:         PadGenerator(type: .pad)
        case .ambient:     PadGenerator(type: .ambient)
        case .binaural:    BinauralGenerator()
        }
    }
}

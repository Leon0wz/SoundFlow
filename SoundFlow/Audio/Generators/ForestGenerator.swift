import AVFoundation

final class ForestGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Wind layer IIR state
    nonisolated(unsafe) private var windLP: Float = 0
    nonisolated(unsafe) private var windHP: Float = 0

    // Bird call pool (FM synthesis)
    private struct Call {
        var carrierPhase: Float
        var modPhase: Float
        var carrierFreq: Float
        var modFreq: Float
        var modIndex: Float
        var amp: Float
        var decay: Float
    }
    nonisolated(unsafe) private var calls: [Call] = []
    nonisolated(unsafe) private var clusterCountdown: Float = 2.0

    // Rustling burst state
    nonisolated(unsafe) private var rustleLP: Float = 0
    nonisolated(unsafe) private var rustleAmp: Float = 0
    nonisolated(unsafe) private var rustleDecay: Float = 0

    // Per-type configuration
    private let birdDensity: Float   // multiplier on call rate
    private let hasLowCalls: Bool    // .jungle: adds frog-like calls

    init(type: GeneratorType) {
        self.generatorType = type
        switch type {
        case .jungle:
            birdDensity = 2.5
            hasLowCalls = true
        default: // .forest
            birdDensity = 1.0
            hasLowCalls = false
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: ForestGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let windLPAlpha: Float = 1 - exp(-2 * .pi * 900 / sr)
            let windHPAlpha: Float = 1 - exp(-2 * .pi * 200 / sr)
            let rustleHPAlpha: Float = 1 - exp(-2 * .pi * 4000 / sr)

            for frame in 0..<Int(frameCount) {
                // Wind layer
                let white = Float.random(in: -1...1)
                gen.windLP += windLPAlpha * (white - gen.windLP)
                gen.windHP += windHPAlpha * (gen.windLP - gen.windHP)
                let wind = (gen.windLP - gen.windHP) * 0.12

                // Bird FM calls
                var birds: Float = 0
                var i = 0
                while i < gen.calls.count {
                    gen.calls[i].amp *= gen.calls[i].decay
                    let mod = sin(gen.calls[i].modPhase * 2 * .pi) * gen.calls[i].modIndex
                    birds += sin((gen.calls[i].carrierPhase + mod) * 2 * .pi) * gen.calls[i].amp
                    gen.calls[i].carrierPhase += gen.calls[i].carrierFreq / sr
                    gen.calls[i].modPhase     += gen.calls[i].modFreq     / sr
                    if gen.calls[i].carrierPhase >= 1 { gen.calls[i].carrierPhase -= 1 }
                    if gen.calls[i].modPhase     >= 1 { gen.calls[i].modPhase     -= 1 }
                    i += 1
                }
                gen.calls.removeAll { $0.amp < 0.0001 }

                // Rustling bursts
                gen.rustleAmp *= gen.rustleDecay
                let rustleNoise = Float.random(in: -1...1)
                gen.rustleLP += rustleHPAlpha * (rustleNoise - gen.rustleLP)
                let rustle = gen.rustleLP * gen.rustleAmp * 0.15

                // Stochastic rustle trigger
                if Float.random(in: 0...1) < 2.0 / sr {
                    gen.rustleAmp   = Float.random(in: 0.3...1.0)
                    gen.rustleDecay = pow(0.001, 1.0 / (sr * 0.12))
                }

                let out = (wind + birds * 0.3 + rustle) * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
    }

    func start() { isRunning = true }
    // Do NOT touch `calls` here — audio thread may be iterating it
    func stop()  { isRunning = false }

    func update(deltaTime: Double) {
        clusterCountdown -= Float(deltaTime)
        guard clusterCountdown <= 0 else { return }

        let sr = Float(AppConstants.Audio.sampleRate)
        let count = Int.random(in: 1...2)
        for _ in 0..<count where calls.count < 4 {
            let isLow = hasLowCalls && Bool.random()
            let carrierFreq: Float = isLow ? Float.random(in: 300...700) : Float.random(in: 1500...4000)
            calls.append(.init(
                carrierPhase: 0,
                modPhase:     Float.random(in: 0...1),
                carrierFreq:  carrierFreq * pitch,
                modFreq:      isLow ? Float.random(in: 30...80) : Float.random(in: 80...200),
                modIndex:     Float.random(in: 0.5...2.0),
                amp:          Float.random(in: 0.2...0.6),
                decay:        pow(0.001, 1.0 / (sr * Float.random(in: 0.1...0.4)))
            ))
        }
        clusterCountdown = Float.random(in: 1.5...6.0) / (birdDensity * max(0.1, intensity))
    }
}

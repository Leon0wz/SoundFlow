import AVFoundation

final class RainGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type base parameters
    private let filterCoeff: Float    // LP filter coefficient (higher = brighter)
    private let baseGain: Float       // base hiss amplitude
    private let baseDropRate: Float   // drops/sec at intensity=0.5

    // Audio thread state — never touch from main thread
    nonisolated(unsafe) private var lpState: Float = 0
    nonisolated(unsafe) private var drops: [Drop] = []

    private struct Drop {
        var phase: Float
        var freq: Float
        var amp: Float
        var decay: Float
    }

    init(type: GeneratorType) {
        self.generatorType = type

        let sr = Float(AppConstants.Audio.sampleRate)

        // Higher filterCoeff = brighter/higher-pitched rain hiss
        // Using direct coefficient rather than computing from Hz to keep it simple
        switch type {
        case .drizzle:
            filterCoeff  = 0.25   // muffled, gentle
            baseGain     = 0.55
            baseDropRate = 6
        case .heavyRain:
            filterCoeff  = 0.65   // bright, loud
            baseGain     = 0.85
            baseDropRate = 70
        default: // .rain
            filterCoeff  = 0.45   // moderate
            baseGain     = 0.70
            baseDropRate = 25
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: RainGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            // Effective drop rate scaled by intensity
            let dropRate = gen.baseDropRate * max(0.1, gen.intensity) * 2

            for frame in 0..<Int(frameCount) {
                // Base hiss: LP-filtered white noise
                // filterCoeff controls brightness; compensate for filter gain loss
                let white = Float.random(in: -1...1)
                gen.lpState += gen.filterCoeff * (white - gen.lpState)
                // Normalize: output RMS of LP filter ≈ sqrt(fc/2) for white noise
                let normFactor = 1.0 / sqrt(gen.filterCoeff * 0.5)
                var out = gen.lpState * normFactor * gen.baseGain

                // Active drop oscillators (natural raindrop frequency: 300–1200 Hz)
                var i = 0
                while i < gen.drops.count {
                    gen.drops[i].amp *= gen.drops[i].decay
                    out += sin(gen.drops[i].phase * 2 * .pi) * gen.drops[i].amp
                    gen.drops[i].phase += gen.drops[i].freq / sr
                    if gen.drops[i].phase >= 1 { gen.drops[i].phase -= 1 }
                    i += 1
                }
                // Remove silent drops (audio thread only — no main-thread access)
                gen.drops.removeAll { $0.amp < 0.001 }

                // Stochastic new drop trigger
                if gen.drops.count < 32, Float.random(in: 0...1) < dropRate / sr {
                    let decaySec = Float.random(in: 0.06...0.18)
                    gen.drops.append(Drop(
                        phase: 0,
                        freq:  Float.random(in: 300...1200) * gen.pitch,
                        amp:   Float.random(in: 0.08...0.22),
                        decay: pow(0.001, 1.0 / (sr * decaySec))
                    ))
                }

                out *= gen.volume

                // Slight stereo spread for naturalness
                for (i, buf) in abl.enumerated() {
                    let spread: Float = (i == 0) ? 1.0 : 0.96
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out * spread
                }
            }
            return noErr
        }

        ref = self
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

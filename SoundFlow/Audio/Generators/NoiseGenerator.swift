import AVFoundation

final class NoiseGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Pink noise — Voss-McCartney 7-stage IIR
    nonisolated(unsafe) private var pinkB0: Float = 0
    nonisolated(unsafe) private var pinkB1: Float = 0
    nonisolated(unsafe) private var pinkB2: Float = 0
    nonisolated(unsafe) private var pinkB3: Float = 0
    nonisolated(unsafe) private var pinkB4: Float = 0
    nonisolated(unsafe) private var pinkB5: Float = 0
    nonisolated(unsafe) private var pinkB6: Float = 0

    // Brown noise — clamped random walk
    nonisolated(unsafe) private var brownState: Float = 0

    init(type: GeneratorType) {
        self.generatorType = type

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: NoiseGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let vol = gen.volume

            for frame in 0..<Int(frameCount) {
                let sample: Float

                switch gen.generatorType {
                case .whiteNoise:
                    sample = Float.random(in: -1...1) * vol

                case .pinkNoise:
                    let w = Float.random(in: -1...1)
                    gen.pinkB0 = 0.99886 * gen.pinkB0 + w * 0.0555179
                    gen.pinkB1 = 0.99332 * gen.pinkB1 + w * 0.0750759
                    gen.pinkB2 = 0.96900 * gen.pinkB2 + w * 0.1538520
                    gen.pinkB3 = 0.86650 * gen.pinkB3 + w * 0.3104856
                    gen.pinkB4 = 0.55000 * gen.pinkB4 + w * 0.5329522
                    gen.pinkB5 = -0.7616 * gen.pinkB5 - w * 0.0168980
                    let pink = (gen.pinkB0 + gen.pinkB1 + gen.pinkB2 + gen.pinkB3 +
                                gen.pinkB4 + gen.pinkB5 + gen.pinkB6 + w * 0.5362) * 0.11
                    gen.pinkB6 = w * 0.115926
                    // Pink has lower RMS than white — boost to match perceived loudness
                    sample = pink * vol * 2.5

                case .brownNoise:
                    let w = Float.random(in: -1...1)
                    gen.brownState += w * 0.02
                    gen.brownState = max(-1.0, min(1.0, gen.brownState))
                    // brownState averages ~±0.4 RMS — no extra multiplier to avoid clipping
                    sample = gen.brownState * vol

                default:
                    sample = 0
                }

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = sample
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

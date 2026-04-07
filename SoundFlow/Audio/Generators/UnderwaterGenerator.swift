import AVFoundation

final class UnderwaterGenerator: GeneratorProtocol {
    let generatorType: GeneratorType = .underwater
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Deep LP filter state (removes everything above ~300 Hz)
    nonisolated(unsafe) private var lp1: Float = 0
    nonisolated(unsafe) private var lp2: Float = 0  // double-pole for steeper rolloff

    // Two slow amplitude modulators for organic feel
    nonisolated(unsafe) private var mod1Phase: Float = 0
    nonisolated(unsafe) private var mod2Phase: Float = 0

    // Bubble layer
    nonisolated(unsafe) private var bubbleAmp: Float = 0
    nonisolated(unsafe) private var bubblePhase: Float = 0
    nonisolated(unsafe) private var bubbleFreq: Float = 900
    nonisolated(unsafe) private var bubbleDecay: Float = 0

    init() {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: UnderwaterGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            // Very narrow LP at 300 Hz (deep underwater muffling)
            let lpAlpha = 1 - exp(-2 * .pi * 300 / sr)
            let effectiveBubbleRate = 0.3 + gen.intensity * 2.0

            for frame in 0..<Int(frameCount) {
                let white = Float.random(in: -1...1)

                // Double-pole LP filter
                gen.lp1 += lpAlpha * (white - gen.lp1)
                gen.lp2 += lpAlpha * (gen.lp1 - gen.lp2)

                // Slow amplitude modulators
                gen.mod1Phase += 0.3  / sr
                gen.mod2Phase += 0.17 / sr
                if gen.mod1Phase >= 1 { gen.mod1Phase -= 1 }
                if gen.mod2Phase >= 1 { gen.mod2Phase -= 1 }
                let mod = 0.5 + 0.25 * sin(gen.mod1Phase * 2 * .pi) + 0.25 * sin(gen.mod2Phase * 2 * .pi)

                var out = gen.lp2 * mod * 0.8

                // Sparse bubble layer
                gen.bubbleAmp   *= gen.bubbleDecay
                gen.bubblePhase += gen.bubbleFreq / sr
                if gen.bubblePhase >= 1 { gen.bubblePhase -= 1 }
                out += sin(gen.bubblePhase * 2 * .pi) * gen.bubbleAmp * 0.06

                if Float.random(in: 0...1) < effectiveBubbleRate / sr {
                    gen.bubbleFreq  = Float.random(in: 800...1200) * gen.pitch
                    gen.bubbleAmp   = Float.random(in: 0.2...0.6)
                    gen.bubbleDecay = pow(0.001, 1.0 / (sr * 0.04))
                    gen.bubblePhase = 0
                }

                out *= gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
        let sr = Float(AppConstants.Audio.sampleRate)
        bubbleDecay = pow(0.001, 1.0 / (sr * 0.04))
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

import AVFoundation

final class ThunderGenerator: GeneratorProtocol {
    let generatorType: GeneratorType = .thunder
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Shared state: written by main-thread update(), read by audio-thread render
    nonisolated(unsafe) private var idleCountdown: Float = 8  // first thunder after ~8s
    nonisolated(unsafe) private var rumbleAmp: Float = 0
    nonisolated(unsafe) private var rumblePhase: Float = 0
    nonisolated(unsafe) private var rumbleFreq: Float = 45
    nonisolated(unsafe) private var rumbleDecay: Float = 0
    // Secondary low rumble layer
    nonisolated(unsafe) private var rumble2Phase: Float = 0
    nonisolated(unsafe) private var rumble2Freq: Float = 28
    // Distant hiss during rumble
    nonisolated(unsafe) private var noiseLP: Float = 0

    init() {
        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: ThunderGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let noiseAlpha: Float = 1 - exp(-2 * .pi * 120 / sr)

            for frame in 0..<Int(frameCount) {
                var out: Float = 0

                if gen.rumbleAmp > 0.0005 {
                    // Primary low-frequency sine (main thunder crack)
                    let s1 = sin(gen.rumblePhase * 2 * .pi) * gen.rumbleAmp
                    gen.rumblePhase += gen.rumbleFreq / sr
                    if gen.rumblePhase >= 1 { gen.rumblePhase -= 1 }

                    // Secondary deeper layer for body
                    let s2 = sin(gen.rumble2Phase * 2 * .pi) * gen.rumbleAmp * 0.6
                    gen.rumble2Phase += gen.rumble2Freq / sr
                    if gen.rumble2Phase >= 1 { gen.rumble2Phase -= 1 }

                    // Low-frequency noise burst for texture
                    let white = Float.random(in: -1...1)
                    gen.noiseLP += noiseAlpha * (white - gen.noiseLP)
                    let noiseBurst = gen.noiseLP * gen.rumbleAmp * 0.4

                    out = (s1 + s2 + noiseBurst) * gen.volume
                    gen.rumbleAmp *= gen.rumbleDecay
                }

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
        let sr = Float(AppConstants.Audio.sampleRate)
        rumbleDecay = pow(0.001, 1.0 / (sr * 2.5))
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false; rumbleAmp = 0 }

    func update(deltaTime: Double) {
        idleCountdown -= Float(deltaTime)
        guard idleCountdown <= 0 else { return }

        let sr = Float(AppConstants.Audio.sampleRate)
        rumbleFreq   = Float.random(in: 25...65)
        rumble2Freq  = rumbleFreq * Float.random(in: 0.5...0.7)
        rumbleAmp    = Float.random(in: 0.6...1.0)
        let decaySec = Float.random(in: 1.5...3.5)
        rumbleDecay  = pow(0.001, 1.0 / (sr * decaySec))
        rumblePhase  = 0
        rumble2Phase = 0

        // Scale gap inversely with intensity (more intense = more frequent)
        let eff = max(0.05, intensity)
        idleCountdown = Float.random(in: 12...45) / eff
    }
}

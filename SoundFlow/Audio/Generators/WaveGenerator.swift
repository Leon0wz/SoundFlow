import AVFoundation

final class WaveGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type parameters
    private let lpCoeff: Float    // low-pass cutoff (broadens the noise)
    private let hpCoeff: Float    // high-pass cutoff (removes sub-rumble)
    private let lfoFreq: Float    // swell rate Hz
    private let lfoFloor: Float   // minimum envelope (waves never fully silent)
    private let bassGain: Float   // low-frequency sub-bass boost

    // Audio thread state
    nonisolated(unsafe) private var lpState: Float = 0
    nonisolated(unsafe) private var hpState: Float = 0
    nonisolated(unsafe) private var lfoPhase: Float = 0
    nonisolated(unsafe) private var bassPhase: Float = 0   // sub-bass oscillator

    init(type: GeneratorType) {
        self.generatorType = type

        let sr = Float(AppConstants.Audio.sampleRate)

        switch type {
        case .ocean:
            // Deeper, slower — prominent sub-bass like open ocean
            lpCoeff  = 1 - exp(-2 * .pi * 800 / sr)
            hpCoeff  = 1 - exp(-2 * .pi * 40  / sr)
            lfoFreq  = 0.07
            lfoFloor = 0.25
            bassGain = 0.35
        default: // .waves
            // Higher-pitched, faster — like waves on a beach
            lpCoeff  = 1 - exp(-2 * .pi * 1400 / sr)
            hpCoeff  = 1 - exp(-2 * .pi * 60   / sr)
            lfoFreq  = 0.13
            lfoFloor = 0.15
            bassGain = 0.20
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: WaveGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            let pitchedLP = min(0.99, gen.lpCoeff * gen.pitch)

            for frame in 0..<Int(frameCount) {
                let white = Float.random(in: -1...1)

                // LP + HP → bandpass surf noise
                gen.lpState += pitchedLP * (white - gen.lpState)
                gen.hpState += gen.hpCoeff * (gen.lpState - gen.hpState)
                let surf = gen.lpState - gen.hpState

                // Sub-bass sine (wave impact low-end)
                let subFreq: Float = 0.4 * gen.pitch  // very low frequency beat
                gen.bassPhase += subFreq / sr
                if gen.bassPhase >= 1 { gen.bassPhase -= 1 }

                // Triangle LFO for swell — slow non-linear rise, quick break
                gen.lfoPhase += gen.lfoFreq / sr
                if gen.lfoPhase >= 1 { gen.lfoPhase -= 1 }
                let tri = 1.0 - 2.0 * abs(2.0 * gen.lfoPhase - 1.0)
                let envelope = gen.lfoFloor + (1.0 - gen.lfoFloor) * (tri + 1.0) * 0.5

                // Combine surf noise + sub-bass
                let bassSine = sin(gen.bassPhase * 2 * .pi) * gen.bassGain
                let out = (surf * 0.8 + bassSine * envelope) * envelope * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
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

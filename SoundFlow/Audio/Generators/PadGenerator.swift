import AVFoundation

final class PadGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type parameters
    private let lfoFreq: Float    // Hz
    private let filterCutoff: Float  // base LP cutoff Hz (for .ambient)
    private let useFilter: Bool

    // Audio thread state
    nonisolated(unsafe) private var voice1Phase: Float = 0
    nonisolated(unsafe) private var voice2Phase: Float = 0
    nonisolated(unsafe) private var lfoPhase: Float = 0
    nonisolated(unsafe) private var lpState: Float = 0   // output LP filter

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .ambient:
            lfoFreq     = 0.01
            filterCutoff = 800
            useFilter   = true
        default: // .pad
            lfoFreq     = 0.03
            filterCutoff = 4000
            useFilter   = false
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: PadGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let baseFreq = 200 * gen.pitch  // root note
            let fifth    = baseFreq * 1.5   // perfect fifth

            // LP filter alpha driven by intensity (brightness)
            let cutoff   = gen.filterCutoff * max(0.1, gen.intensity)
            let lpAlpha  = 1 - exp(-2 * .pi * cutoff / sr)

            for frame in 0..<Int(frameCount) {
                // LFO for detuning
                gen.lfoPhase += gen.lfoFreq / sr
                if gen.lfoPhase >= 1 { gen.lfoPhase -= 1 }
                let lfo = sin(gen.lfoPhase * 2 * .pi) * 0.005  // ±0.5% detune

                gen.voice1Phase += (baseFreq * (1 + lfo)) / sr
                gen.voice2Phase += (fifth * (1 - lfo * 0.5)) / sr
                if gen.voice1Phase >= 1 { gen.voice1Phase -= 1 }
                if gen.voice2Phase >= 1 { gen.voice2Phase -= 1 }

                // Sine voice 1, triangle voice 2
                let sine1     = sin(gen.voice1Phase * 2 * .pi)
                let tri2      = 2 * abs(2 * gen.voice2Phase - 1) - 1  // triangle -1..1
                var out = (sine1 * 0.6 + tri2 * 0.4) * gen.volume

                // Optional LP filter for ambient
                if gen.useFilter {
                    gen.lpState += lpAlpha * (out - gen.lpState)
                    out = gen.lpState
                }

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

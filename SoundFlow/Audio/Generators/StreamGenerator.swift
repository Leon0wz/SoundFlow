import AVFoundation

final class StreamGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    private let lpCutoff: Float
    private let hpCutoff: Float
    private let lfoFreq: Float    // 0 = no modulation
    private let lfoDepth: Float   // amplitude modulation depth

    nonisolated(unsafe) private var lpState: Float = 0
    nonisolated(unsafe) private var hpState: Float = 0
    nonisolated(unsafe) private var lfoPhase: Float = 0

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .river:
            lpCutoff = 900;  hpCutoff = 400;  lfoFreq = 0.15; lfoDepth = 0.5
        case .waterfall:
            lpCutoff = 3000; hpCutoff = 300;  lfoFreq = 0;    lfoDepth = 0
        default: // .stream
            lpCutoff = 1200; hpCutoff = 600;  lfoFreq = 0.2;  lfoDepth = 0.35
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: StreamGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            // Scale cutoffs with intensity (more turbulent = wider band)
            let eff = max(0.5, gen.intensity)
            let lpAlpha = 1 - exp(-2 * .pi * gen.lpCutoff * eff * gen.pitch / sr)
            let hpAlpha = 1 - exp(-2 * .pi * gen.hpCutoff / sr)

            for frame in 0..<Int(frameCount) {
                let white = Float.random(in: -1...1)
                gen.lpState += lpAlpha * (white - gen.lpState)
                gen.hpState += hpAlpha * (gen.lpState - gen.hpState)
                var out = gen.lpState - gen.hpState

                // LFO amplitude modulation for stream/river
                if gen.lfoFreq > 0 {
                    gen.lfoPhase += gen.lfoFreq / sr
                    if gen.lfoPhase >= 1 { gen.lfoPhase -= 1 }
                    let lfo = (1.0 - gen.lfoDepth) + gen.lfoDepth * (sin(gen.lfoPhase * 2 * .pi) + 1) * 0.5
                    out *= lfo
                }

                out *= gen.volume

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

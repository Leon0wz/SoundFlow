import AVFoundation

final class WindGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type base parameters
    private let baseCenterHz: Float
    private let sweepHz: Float
    private let lfoFreq: Float

    // Audio thread state
    nonisolated(unsafe) private var lpState: Float = 0
    nonisolated(unsafe) private var hpState: Float = 0
    nonisolated(unsafe) private var lfoPhase: Float = 0
    // Interpolated filter coefficients (avoids zipper noise)
    nonisolated(unsafe) private var currentLPAlpha: Float = 0
    nonisolated(unsafe) private var currentHPAlpha: Float = 0
    nonisolated(unsafe) private var targetLPAlpha: Float = 0
    nonisolated(unsafe) private var targetHPAlpha: Float = 0

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .breeze:
            baseCenterHz = 600;  sweepHz = 300;  lfoFreq = 0.07
        case .gust:
            baseCenterHz = 1800; sweepHz = 1000; lfoFreq = 0.22
        default: // .wind
            baseCenterHz = 1100; sweepHz = 600;  lfoFreq = 0.13
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: WindGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            for frame in 0..<Int(frameCount) {
                // Advance LFO and compute target coefficients
                gen.lfoPhase += gen.lfoFreq / sr
                if gen.lfoPhase >= 1 { gen.lfoPhase -= 1 }
                let lfo = sin(gen.lfoPhase * 2 * .pi)  // -1..1
                let effectiveSweep = gen.sweepHz * max(0.1, gen.intensity)
                let centerHz = (gen.baseCenterHz + lfo * effectiveSweep) * gen.pitch
                let bwHz = centerHz * 0.6
                let lpHz = min(centerHz + bwHz, sr * 0.49)
                let hpHz = max(centerHz - bwHz, 20)
                gen.targetLPAlpha = 1 - exp(-2 * .pi * lpHz / sr)
                gen.targetHPAlpha = 1 - exp(-2 * .pi * hpHz / sr)

                // Slowly interpolate toward target — eliminates zipper noise
                let slew: Float = 0.0005
                gen.currentLPAlpha += slew * (gen.targetLPAlpha - gen.currentLPAlpha)
                gen.currentHPAlpha += slew * (gen.targetHPAlpha - gen.currentHPAlpha)

                let white = Float.random(in: -1...1)
                gen.lpState += gen.currentLPAlpha * (white - gen.lpState)
                gen.hpState += gen.currentHPAlpha * (gen.lpState - gen.hpState)
                let bp = (gen.lpState - gen.hpState) * 2.5  // compensate for bandpass gain loss

                let out = bp * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self

        // Initialize coefficients to avoid silent startup
        let sr = Float(AppConstants.Audio.sampleRate)
        currentLPAlpha = 1 - exp(-2 * .pi * (baseCenterHz + sweepHz * 0.3) / sr)
        currentHPAlpha = 1 - exp(-2 * .pi * max(baseCenterHz - sweepHz * 0.3, 20) / sr)
        targetLPAlpha  = currentLPAlpha
        targetHPAlpha  = currentHPAlpha
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

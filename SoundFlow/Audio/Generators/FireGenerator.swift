import AVFoundation

final class FireGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type parameters
    private let emberGain: Float
    private let baseCrackleRate: Float  // crackles per second
    private let crackleFreqRange: ClosedRange<Float>

    // Audio thread state
    nonisolated(unsafe) private var emberState: Float = 0   // brown-noise accumulator
    nonisolated(unsafe) private var emberLP: Float = 0      // IIR state
    nonisolated(unsafe) private var crackleAmp: Float = 0
    nonisolated(unsafe) private var cracklePhase: Float = 0
    nonisolated(unsafe) private var crackleFreq: Float = 3000
    nonisolated(unsafe) private var crackleDecay: Float = 0

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .campfire:
            emberGain       = 0.35
            baseCrackleRate = 4
            crackleFreqRange = 1500...3500
        default: // .fire
            emberGain       = 0.2
            baseCrackleRate = 10
            crackleFreqRange = 2000...6000
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: FireGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let emberAlpha: Float = 1 - exp(-2 * .pi * 200 / sr)
            let effectiveCrackleRate = gen.baseCrackleRate * max(0.1, gen.intensity) * 2

            for frame in 0..<Int(frameCount) {
                // Ember layer: LP-filtered brown noise
                let w = Float.random(in: -1...1)
                gen.emberState += w * 0.02
                gen.emberState = max(-1.0, min(1.0, gen.emberState))
                gen.emberLP += emberAlpha * (gen.emberState - gen.emberLP)
                let ember = gen.emberLP * gen.emberGain

                // Crackle layer
                gen.crackleAmp   *= gen.crackleDecay
                gen.cracklePhase += gen.crackleFreq / sr
                if gen.cracklePhase >= 1 { gen.cracklePhase -= 1 }
                let crackle = sin(gen.cracklePhase * 2 * .pi) * gen.crackleAmp

                // Stochastic new crackle
                if Float.random(in: 0...1) < effectiveCrackleRate / sr {
                    gen.crackleFreq  = Float.random(in: gen.crackleFreqRange) * gen.pitch
                    gen.crackleAmp   = Float.random(in: 0.05...0.2)
                    gen.crackleDecay = pow(0.001, 1.0 / (sr * 0.02))
                    gen.cracklePhase = 0
                }

                let out = (ember + crackle) * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
        let sr = Float(AppConstants.Audio.sampleRate)
        crackleDecay = pow(0.001, 1.0 / (sr * 0.02))
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

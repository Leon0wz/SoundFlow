import AVFoundation

final class CityGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Audio thread state
    nonisolated(unsafe) private var brownState: Float = 0
    nonisolated(unsafe) private var rumbleLP: Float = 0
    nonisolated(unsafe) private var chatterLP: Float = 0
    nonisolated(unsafe) private var transientAmp: Float = 0
    nonisolated(unsafe) private var transientPhase: Float = 0
    nonisolated(unsafe) private var transientFreq: Float = 4000
    nonisolated(unsafe) private var transientDecay: Float = 0

    // Per-type
    private let rumbleGain: Float
    private let chatterGain: Float
    private let chatterCutoff: Float
    private let transientRate: Float  // per second
    private let transientFreqRange: ClosedRange<Float>

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .cafe:
            rumbleGain       = 0.0
            chatterGain      = 0.3
            chatterCutoff    = 800
            transientRate    = 0.5
            transientFreqRange = 4000...8000
        case .traffic:
            rumbleGain       = 0.35
            chatterGain      = 0.0
            chatterCutoff    = 400
            transientRate    = 8
            transientFreqRange = 2000...5000
        default: // .city
            rumbleGain       = 0.2
            chatterGain      = 0.1
            chatterCutoff    = 600
            transientRate    = 4
            transientFreqRange = 3000...6000
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: CityGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let rumbleAlpha  = 1 - exp(-2 * .pi * 150  / sr)
            let chatAlpha    = 1 - exp(-2 * .pi * gen.chatterCutoff / sr)
            let effectiveRate = gen.transientRate * max(0.1, gen.intensity) * 2

            for frame in 0..<Int(frameCount) {
                let white = Float.random(in: -1...1)

                // Brown noise engine rumble
                gen.brownState += white * 0.02
                gen.brownState  = max(-1.0, min(1.0, gen.brownState))
                gen.rumbleLP   += rumbleAlpha * (gen.brownState - gen.rumbleLP)
                let rumble = gen.rumbleLP * gen.rumbleGain

                // Chatter (cafe crowd)
                gen.chatterLP += chatAlpha * (white - gen.chatterLP)
                let chatter = gen.chatterLP * gen.chatterGain

                // Transient (horn, tire screech, cup clink)
                gen.transientAmp   *= gen.transientDecay
                gen.transientPhase += gen.transientFreq / sr
                if gen.transientPhase >= 1 { gen.transientPhase -= 1 }
                let transient = sin(gen.transientPhase * 2 * .pi) * gen.transientAmp * 0.15

                if Float.random(in: 0...1) < effectiveRate / sr {
                    gen.transientFreq  = Float.random(in: gen.transientFreqRange)
                    gen.transientAmp   = Float.random(in: 0.2...0.8)
                    gen.transientDecay = pow(0.001, 1.0 / (sr * 0.04))
                    gen.transientPhase = 0
                }

                let out = (rumble + chatter + transient) * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
        let sr = Float(AppConstants.Audio.sampleRate)
        transientDecay = pow(0.001, 1.0 / (sr * 0.04))
    }

    func start() { isRunning = true }
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

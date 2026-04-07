import AVFoundation

final class CaveGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // 40 ms comb-filter delay line at 44100 Hz
    private static let delayLength = 1764
    nonisolated(unsafe) private var delayLine: [Float]
    nonisolated(unsafe) private var delayIndex: Int = 0

    // Resonant bandpass IIR state
    nonisolated(unsafe) private var lpState: Float = 0
    nonisolated(unsafe) private var hpState: Float = 0

    // Drop oscillator
    nonisolated(unsafe) private var dropAmp: Float = 0
    nonisolated(unsafe) private var dropPhase: Float = 0
    nonisolated(unsafe) private var dropFreq: Float = 700
    nonisolated(unsafe) private var dropDecay: Float = 0

    private let isDrops: Bool

    init(type: GeneratorType) {
        self.generatorType = type
        self.isDrops = (type == .drops)
        self.delayLine = [Float](repeating: 0, count: CaveGenerator.delayLength)

        let sr = Float(AppConstants.Audio.sampleRate)
        self.dropDecay = pow(0.001, 1.0 / (sr * 0.8))

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: CaveGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let delayLen = CaveGenerator.delayLength
            let lpAlpha = 1 - exp(-2 * .pi * 400 / sr)
            let hpAlpha = 1 - exp(-2 * .pi * 80  / sr)

            for frame in 0..<Int(frameCount) {
                var input: Float

                if gen.isDrops {
                    // Sparse drip events
                    gen.dropAmp   *= gen.dropDecay
                    gen.dropPhase += gen.dropFreq / sr
                    if gen.dropPhase >= 1 { gen.dropPhase -= 1 }
                    input = sin(gen.dropPhase * 2 * .pi) * gen.dropAmp

                    // Stochastic drip trigger
                    let dropRate = (0.5 + gen.intensity * 1.5)
                    if Float.random(in: 0...1) < dropRate / sr {
                        gen.dropFreq  = Float.random(in: 500...1000) * gen.pitch
                        gen.dropAmp   = Float.random(in: 0.3...0.8)
                        gen.dropPhase = 0
                        gen.dropDecay = pow(0.001, 1.0 / (sr * Float.random(in: 0.5...1.2)))
                    }
                } else {
                    // Narrow cave resonance from brown noise
                    let white = Float.random(in: -1...1)
                    gen.lpState += lpAlpha * (white - gen.lpState)
                    gen.hpState += hpAlpha * (gen.lpState - gen.hpState)
                    input = (gen.lpState - gen.hpState) * 0.2
                }

                // Comb filter reverb: comb[n] = input + 0.85 * comb[n - delayLen]
                let readIndex = (gen.delayIndex - delayLen + delayLen * 2) % delayLen
                let delayed   = gen.delayLine[readIndex]
                let combOut   = input + 0.85 * delayed
                gen.delayLine[gen.delayIndex] = combOut
                gen.delayIndex = (gen.delayIndex + 1) % delayLen

                let out = combOut * gen.volume

                for buf in abl {
                    buf.mData!.assumingMemoryBound(to: Float.self)[frame] = out
                }
            }
            return noErr
        }

        ref = self
    }

    func start() { isRunning = true }
    // Do NOT reset delayLine here — audio thread may be reading it
    func stop()  { isRunning = false }
    func update(deltaTime: Double) {}
}

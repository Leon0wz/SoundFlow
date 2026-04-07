import AVFoundation

final class BirdGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Per-type frequency ranges
    private let carrierRange: ClosedRange<Float>
    private let modulatorRange: ClosedRange<Float>
    private let modIndexRange: ClosedRange<Float>
    private let decaySec: ClosedRange<Float>

    private struct BirdCall {
        var carrierPhase: Float
        var modulatorPhase: Float
        var carrierFreq: Float
        var modulatorFreq: Float
        var modIndex: Float
        var amp: Float
        var decay: Float  // per-sample
    }

    nonisolated(unsafe) private var calls: [BirdCall] = []
    nonisolated(unsafe) private var clusterCountdown: Float = 3.0

    init(type: GeneratorType) {
        self.generatorType = type

        switch type {
        case .crickets:
            carrierRange   = 4000...6000
            modulatorRange = 150...250
            modIndexRange  = 1.0...2.0
            decaySec       = 0.05...0.15
        case .frogs:
            carrierRange   = 300...800
            modulatorRange = 30...100
            modIndexRange  = 1.5...3.0
            decaySec       = 0.15...0.5
        default: // .birds
            carrierRange   = 1500...4000
            modulatorRange = 80...200
            modIndexRange  = 0.5...2.5
            decaySec       = 0.08...0.3
        }

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: BirdGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            for frame in 0..<Int(frameCount) {
                var out: Float = 0

                // Mix active calls
                var i = 0
                while i < gen.calls.count {
                    gen.calls[i].amp *= gen.calls[i].decay
                    let mod = sin(gen.calls[i].modulatorPhase * 2 * .pi) * gen.calls[i].modIndex
                    let s   = sin((gen.calls[i].carrierPhase + mod) * 2 * .pi) * gen.calls[i].amp
                    gen.calls[i].carrierPhase   += gen.calls[i].carrierFreq   / sr
                    gen.calls[i].modulatorPhase += gen.calls[i].modulatorFreq / sr
                    if gen.calls[i].carrierPhase   >= 1 { gen.calls[i].carrierPhase   -= 1 }
                    if gen.calls[i].modulatorPhase >= 1 { gen.calls[i].modulatorPhase -= 1 }
                    out += s
                    i += 1
                }
                gen.calls.removeAll { $0.amp < 0.0001 }

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
    // Do NOT touch `calls` here — audio thread may be iterating it
    func stop()  { isRunning = false }

    // Spawn call clusters from the main-thread update loop
    func update(deltaTime: Double) {
        clusterCountdown -= Float(deltaTime)
        guard clusterCountdown <= 0 else { return }

        let sr = Float(AppConstants.Audio.sampleRate)
        let count = Int.random(in: 1...3)
        for _ in 0..<count where calls.count < 4 {
            let decaySecs = Float.random(in: decaySec)
            calls.append(.init(
                carrierPhase:   0,
                modulatorPhase: Float.random(in: 0...1),
                carrierFreq:    Float.random(in: carrierRange) * pitch,
                modulatorFreq:  Float.random(in: modulatorRange),
                modIndex:       Float.random(in: modIndexRange),
                amp:            Float.random(in: 0.3...0.8),
                decay:          pow(0.001, 1.0 / (sr * decaySecs))
            ))
        }

        let gap: Float = generatorType == .crickets ? Float.random(in: 0.1...0.4)
                       : generatorType == .frogs    ? Float.random(in: 1.0...4.0)
                                                    : Float.random(in: 1.5...8.0)
        clusterCountdown = gap / max(0.1, intensity)
    }
}

import AVFoundation

final class SpaceGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0
    nonisolated(unsafe) var intensity: Float = 0.5
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Audio thread state
    nonisolated(unsafe) private var brownState: Float = 0
    nonisolated(unsafe) private var subLP: Float = 0
    nonisolated(unsafe) private var lfo1Phase: Float = 0
    nonisolated(unsafe) private var lfo2Phase: Float = 0
    nonisolated(unsafe) private var padPhase: Float = 0      // sub-bass sine
    nonisolated(unsafe) private var overtone2Phase: Float = 0
    nonisolated(unsafe) private var overtone3Phase: Float = 0

    private let isDrone: Bool

    init(type: GeneratorType) {
        self.generatorType = type
        self.isDrone = (type == .drone)

        let format = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: SpaceGenerator?

        self.outputNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)
            let subAlpha = 1 - exp(-2 * .pi * 80 / sr)
            let baseFreq = 60 * gen.pitch

            for frame in 0..<Int(frameCount) {
                var out: Float

                if gen.isDrone {
                    // Drone: single fundamental + overtones with tremolo LFO
                    gen.lfo1Phase += 0.05 / sr
                    if gen.lfo1Phase >= 1 { gen.lfo1Phase -= 1 }
                    let tremolo = 0.5 + 0.5 * sin(gen.lfo1Phase * 2 * .pi)

                    gen.padPhase      += baseFreq       / sr
                    gen.overtone2Phase += (baseFreq * 2) / sr
                    gen.overtone3Phase += (baseFreq * 3) / sr
                    if gen.padPhase      >= 1 { gen.padPhase      -= 1 }
                    if gen.overtone2Phase >= 1 { gen.overtone2Phase -= 1 }
                    if gen.overtone3Phase >= 1 { gen.overtone3Phase -= 1 }

                    out = (sin(gen.padPhase      * 2 * .pi) * 0.6 +
                           sin(gen.overtone2Phase * 2 * .pi) * 0.25 +
                           sin(gen.overtone3Phase * 2 * .pi) * 0.15) * tremolo

                } else {
                    // Space: LP brown noise + sub-bass sine, two slow beating LFOs
                    let w = Float.random(in: -1...1)
                    gen.brownState += w * 0.02
                    gen.brownState  = max(-1.0, min(1.0, gen.brownState))
                    gen.subLP      += subAlpha * (gen.brownState - gen.subLP)

                    gen.padPhase += baseFreq / sr
                    if gen.padPhase >= 1 { gen.padPhase -= 1 }
                    let subSine = sin(gen.padPhase * 2 * .pi) * 0.4

                    gen.lfo1Phase += 0.01  / sr
                    gen.lfo2Phase += 0.007 / sr
                    if gen.lfo1Phase >= 1 { gen.lfo1Phase -= 1 }
                    if gen.lfo2Phase >= 1 { gen.lfo2Phase -= 1 }
                    let lfo = (sin(gen.lfo1Phase * 2 * .pi) + sin(gen.lfo2Phase * 2 * .pi)) * 0.25 + 0.5

                    out = (gen.subLP * 0.3 + subSine) * lfo
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

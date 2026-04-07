import AVFoundation

final class BinauralGenerator: GeneratorProtocol {
    let generatorType: GeneratorType = .binaural
    nonisolated(unsafe) var volume: Float = 0.5
    nonisolated(unsafe) var pitch: Float = 1.0    // scales base frequency
    nonisolated(unsafe) var intensity: Float = 0.5 // maps to beat frequency
    nonisolated(unsafe) private(set) var isRunning = false

    let outputNode: AVAudioSourceNode

    // Audio thread state
    nonisolated(unsafe) private var leftPhase: Float = 0
    nonisolated(unsafe) private var rightPhase: Float = 0

    init() {
        // Binaural MUST use stereo format so L/R channels are separate
        let stereoFormat = AVAudioFormat(
            standardFormatWithSampleRate: AppConstants.Audio.sampleRate,
            channels: 2
        )!

        var ref: BinauralGenerator?

        self.outputNode = AVAudioSourceNode(format: stereoFormat) { _, _, frameCount, audioBufferList -> OSStatus in
            guard let gen = ref, gen.isRunning else {
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for buf in abl { memset(buf.mData, 0, Int(buf.mDataByteSize)) }
                return noErr
            }

            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let sr = Float(AppConstants.Audio.sampleRate)

            // intensity 0.0 = 4 Hz (delta), 1.0 = 40 Hz (gamma)
            let baseFreq = 200 * gen.pitch
            let beatFreq = 4 + gen.intensity * 36
            let leftFreq  = baseFreq
            let rightFreq = baseFreq + beatFreq

            for frame in 0..<Int(frameCount) {
                let leftSample  = sin(gen.leftPhase  * 2 * .pi) * gen.volume
                let rightSample = sin(gen.rightPhase * 2 * .pi) * gen.volume

                gen.leftPhase  += leftFreq  / sr
                gen.rightPhase += rightFreq / sr
                if gen.leftPhase  >= 1 { gen.leftPhase  -= 1 }
                if gen.rightPhase >= 1 { gen.rightPhase -= 1 }

                // Non-interleaved planar stereo: abl[0] = left, abl[1] = right
                if abl.count >= 2 {
                    abl[0].mData!.assumingMemoryBound(to: Float.self)[frame] = leftSample
                    abl[1].mData!.assumingMemoryBound(to: Float.self)[frame] = rightSample
                } else if abl.count == 1 {
                    // Fallback: interleaved — write both channels with stride 2
                    let ptr = abl[0].mData!.assumingMemoryBound(to: Float.self)
                    ptr[frame * 2]     = leftSample
                    ptr[frame * 2 + 1] = rightSample
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

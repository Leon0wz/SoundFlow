import AVFoundation

extension AVAudioNode {
    var outputFormat: AVAudioFormat {
        outputFormat(forBus: 0)
    }
}

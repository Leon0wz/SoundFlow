import AVFoundation

@Observable
@MainActor
final class AudioEngine {
    static let shared = AudioEngine()

    var isRunning = false

    private let engine = AVAudioEngine()
    private let mixer = AudioMixer()

    private init() {}

    func start() {
        guard !isRunning else { return }
        do {
            try engine.start()
            isRunning = true
        } catch {
            print("AudioEngine start failed: \(error)")
        }
    }

    func stop() {
        engine.stop()
        isRunning = false
    }
}

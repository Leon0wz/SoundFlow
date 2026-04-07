import AVFoundation

final class WindGenerator: GeneratorProtocol {
    let generatorType: GeneratorType = .wind
    var volume: Float = 0.5
    private(set) var isRunning = false

    func start() { isRunning = true }
    func stop() { isRunning = false }
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {}
    func setParameter(_ key: String, value: Double) {}
}

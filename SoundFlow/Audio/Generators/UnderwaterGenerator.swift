import AVFoundation

final class UnderwaterGenerator: GeneratorProtocol {
    let generatorType: GeneratorType = .underwater
    var volume: Float = 0.5
    private(set) var isRunning = false

    func start() { isRunning = true }
    func stop() { isRunning = false }
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {}
    func setParameter(_ key: String, value: Double) {}
}

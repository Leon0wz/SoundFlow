import AVFoundation

final class NoiseGenerator: GeneratorProtocol {
    let generatorType: GeneratorType
    var volume: Float = 0.5
    private(set) var isRunning = false

    init(type: GeneratorType) {
        self.generatorType = type
    }

    func start() { isRunning = true }
    func stop() { isRunning = false }
    func fillBuffer(_ buffer: AVAudioPCMBuffer) {}
    func setParameter(_ key: String, value: Double) {}
}

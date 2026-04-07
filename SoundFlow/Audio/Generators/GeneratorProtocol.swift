import AVFoundation

protocol GeneratorProtocol: AnyObject {
    var generatorType: GeneratorType { get }
    var volume: Float { get set }
    var isRunning: Bool { get }

    func start()
    func stop()
    func fillBuffer(_ buffer: AVAudioPCMBuffer)
    func setParameter(_ key: String, value: Double)
}

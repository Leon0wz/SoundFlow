import AVFoundation

protocol GeneratorProtocol: AnyObject {
    var generatorType: GeneratorType { get }
    var volume: Float { get set }      // 0.0–1.0
    var pitch: Float { get set }       // 0.5–2.0
    var intensity: Float { get set }   // 0.0–1.0
    var isRunning: Bool { get }
    var outputNode: AVAudioSourceNode { get }

    func start()
    func stop()
    func update(deltaTime: Double)
}

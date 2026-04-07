import Foundation

struct SoundLayer: Identifiable, Codable {
    let id: UUID
    var generatorType: GeneratorType
    var volume: Float          // 0.0 – 1.0
    var pitch: Float           // 0.5 – 2.0 (Multiplikator)
    var intensity: Float       // 0.0 – 1.0 (Generator-spezifisch)
    var pan: Float             // -1.0 (links) bis 1.0 (rechts)
    var isEnabled: Bool

    init(
        generatorType: GeneratorType,
        volume: Float = 0.7,
        pitch: Float = 1.0,
        intensity: Float = 0.5,
        pan: Float = 0.0
    ) {
        self.id = UUID()
        self.generatorType = generatorType
        self.volume = volume
        self.pitch = pitch
        self.intensity = intensity
        self.pan = pan
        self.isEnabled = true
    }
}

import Foundation

struct SoundLayer: Identifiable, Codable {
    let id: UUID
    var generatorType: GeneratorType
    var volume: Float
    var parameters: [String: Double]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        generatorType: GeneratorType,
        volume: Float = 0.5,
        parameters: [String: Double] = [:],
        isActive: Bool = true
    ) {
        self.id = id
        self.generatorType = generatorType
        self.volume = volume
        self.parameters = parameters
        self.isActive = isActive
    }
}

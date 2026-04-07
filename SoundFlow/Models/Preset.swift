import Foundation
import SwiftData

@Model
final class Preset {
    var name: String
    var layers: [SoundLayer]
    var createdAt: Date
    var updatedAt: Date

    init(name: String, layers: [SoundLayer], createdAt: Date = .now, updatedAt: Date = .now) {
        self.name = name
        self.layers = layers
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

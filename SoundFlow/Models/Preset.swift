import Foundation
import SwiftData

@Model
final class Preset {
    var id: UUID
    var name: String
    var createdAt: Date
    var layersData: Data
    var timerMinutes: Int?

    init(name: String, layers: [SoundLayer], timerMinutes: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.timerMinutes = timerMinutes
        self.layersData = (try? JSONEncoder().encode(layers)) ?? Data()
    }

    var layers: [SoundLayer] {
        (try? JSONDecoder().decode([SoundLayer].self, from: layersData)) ?? []
    }
}

import Foundation
import SwiftData

@Model
final class SleepSession {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var durationMinutes: Int
    var sceneID: String
    var category: String

    init(sceneID: String, category: SceneCategory) {
        self.id = UUID()
        self.startDate = Date()
        self.durationMinutes = 0
        self.sceneID = sceneID
        self.category = category.rawValue
    }
}

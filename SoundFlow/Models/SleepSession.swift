import Foundation
import SwiftData

@Model
final class SleepSession {
    var startDate: Date
    var endDate: Date?
    var durationMinutes: Int
    var sceneName: String
    var layers: [SoundLayer]

    init(startDate: Date = .now, endDate: Date? = nil, durationMinutes: Int = 0, sceneName: String, layers: [SoundLayer] = []) {
        self.startDate = startDate
        self.endDate = endDate
        self.durationMinutes = durationMinutes
        self.sceneName = sceneName
        self.layers = layers
    }
}

import Foundation
import SwiftData

@Model
class SleepSession {
    var date: Date = Date()

    init(date: Date = Date()) {
        self.date = date
    }
}

import Foundation

@Observable
@MainActor
final class AlarmManager {
    var alarmTime: Date?
    var isAlarmSet = false
}

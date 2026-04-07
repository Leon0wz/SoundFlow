import Foundation

extension Date {
    var shortTimeString: String {
        formatted(date: .omitted, time: .shortened)
    }

    var mediumDateString: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}

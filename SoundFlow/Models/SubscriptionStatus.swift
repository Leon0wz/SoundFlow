import Foundation

enum AppSubscriptionStatus: Codable {
    case free
    case premium(expirationDate: Date?)
    case lifetime

    var isPremium: Bool {
        switch self {
        case .free: false
        case .premium, .lifetime: true
        }
    }
}

import Foundation

struct SoundScene: Identifiable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let category: SceneCategory
    let layers: [SoundLayer]
    let isPremium: Bool
    let gradientColors: [String]    // Hex-Farben für Hintergrund
    let iconName: String

    var isFree: Bool { !isPremium }
}

enum SceneCategory: String, Codable, CaseIterable {
    case sleep = "Schlaf"
    case focus = "Fokus"
    case relax = "Entspannung"
    case nature = "Natur"

    var iconName: String {
        switch self {
        case .sleep: "moon.fill"
        case .focus: "brain.head.profile"
        case .relax: "leaf.fill"
        case .nature: "tree.fill"
        }
    }
}

import Foundation

struct SoundScene: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var category: SceneCategory
    var layers: [SoundLayer]
    var iconName: String
    var isPremium: Bool

    enum SceneCategory: String, Codable, CaseIterable {
        case nature
        case urban
        case ambient
        case focus
        case sleep
    }
}

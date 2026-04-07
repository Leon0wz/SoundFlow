import ActivityKit

struct SoundFlowActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sceneName: String
        var isPlaying: Bool
        var remainingMinutes: Int
    }

    var sceneIconName: String
}

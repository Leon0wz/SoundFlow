import SwiftUI

@Observable
@MainActor
final class AppState {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    var lastPlayedSceneID: String {
        get { UserDefaults.standard.string(forKey: "lastPlayedSceneID") ?? "rain" }
        set { UserDefaults.standard.set(newValue, forKey: "lastPlayedSceneID") }
    }
    var currentScene: SoundScene?
    var isPlaying = false
    var showPaywall = false
    var selectedCategory: SceneCategory = .sleep
    var currentTimerMinutes: Int = 0
    var timerRemainingSeconds: Int = 0
}

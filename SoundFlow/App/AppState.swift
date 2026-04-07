import SwiftUI

@Observable
@MainActor
final class AppState {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    var currentScene: SoundScene?
    var isPlaying = false
    var activeLayers: [SoundLayer] = []
}

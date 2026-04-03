import SwiftUI
import Combine

class AppState: ObservableObject {
    private static let onboardingKey = "hasCompletedOnboarding"

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: AppState.onboardingKey)
        }
    }

    @Published var isPlaying: Bool = false
    @Published var currentSceneID: String? = nil

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppState.onboardingKey)
    }
}

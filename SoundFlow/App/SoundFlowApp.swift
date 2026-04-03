import SwiftUI
import SwiftData

@main
struct SoundFlowApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var audioEngine = AudioEngine.shared
    @StateObject private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
            .environmentObject(audioEngine)
            .environmentObject(storeManager)
            .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Preset.self, SleepSession.self])
    }
}

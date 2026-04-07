import SwiftUI
import SwiftData

@main
struct SoundFlowApp: App {
    @State private var appState = AppState()
    @State private var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(AudioEngine.shared)
                .environment(storeManager)
                .preferredColorScheme(.dark)
                .modelContainer(for: [Preset.self, SleepSession.self])
        }
    }
}

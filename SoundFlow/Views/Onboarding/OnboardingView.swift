import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        TabView {
            OnboardingPage(
                title: "Welcome to SoundFlow",
                description: "Immersive soundscapes for sleep, focus, and relaxation.",
                iconName: "waveform.circle.fill"
            )
            OnboardingPage(
                title: "Procedural Audio",
                description: "Every sound is uniquely generated — never a loop.",
                iconName: "music.note"
            )
            OnboardingPage(
                title: "Your Sound, Your Way",
                description: "Mix and customize layers to create your perfect soundscape.",
                iconName: "slider.horizontal.3",
                showGetStarted: true
            ) {
                appState.hasCompletedOnboarding = true
            }
        }
        .tabViewStyle(.page)
        .background(Color.sfBackground.ignoresSafeArea())
    }
}

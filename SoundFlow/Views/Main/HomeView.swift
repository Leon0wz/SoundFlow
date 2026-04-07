import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.sfBackground.ignoresSafeArea()
                Text("SoundFlow")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.sfTextPrimary)
            }
            .navigationTitle("SoundFlow")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

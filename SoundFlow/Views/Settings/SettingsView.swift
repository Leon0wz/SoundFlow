import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("Settings")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

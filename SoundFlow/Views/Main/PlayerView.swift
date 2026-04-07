import SwiftUI

struct PlayerView: View {
    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("Player")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

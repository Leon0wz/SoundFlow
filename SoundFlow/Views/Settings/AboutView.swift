import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("About SoundFlow")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

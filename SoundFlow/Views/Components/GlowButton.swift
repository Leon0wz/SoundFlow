import SwiftUI

struct GlowButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Color.sfPrimary)
                .clipShape(Circle())
                .shadow(color: isPlaying ? Color.sfGlow : .clear, radius: 16)
        }
    }
}

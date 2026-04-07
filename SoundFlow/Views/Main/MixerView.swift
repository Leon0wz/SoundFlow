import SwiftUI

struct MixerView: View {
    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("Mixer")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

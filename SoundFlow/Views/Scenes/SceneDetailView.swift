import SwiftUI

struct SceneDetailView: View {
    let scene: SoundScene

    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text(scene.name)
                .font(.title)
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

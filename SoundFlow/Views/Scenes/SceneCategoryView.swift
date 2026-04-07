import SwiftUI

struct SceneCategoryView: View {
    let category: SoundScene.SceneCategory

    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text(category.rawValue.capitalized)
                .font(.title)
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

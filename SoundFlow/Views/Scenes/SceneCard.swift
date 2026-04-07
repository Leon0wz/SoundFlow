import SwiftUI

struct SceneCard: View {
    let scene: SoundScene

    var body: some View {
        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
            .fill(Color.sfSurface)
            .frame(height: AppConstants.UI.cardHeight)
            .overlay {
                VStack {
                    Image(systemName: scene.iconName)
                        .font(.title)
                    Text(scene.name)
                        .font(.headline)
                }
                .foregroundStyle(Color.sfTextPrimary)
            }
    }
}

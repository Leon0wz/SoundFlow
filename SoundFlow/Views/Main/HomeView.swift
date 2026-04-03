import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("SoundFlow")
            .foregroundStyle(Color.sfTextPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.sfBackground)
    }
}

#Preview {
    HomeView()
}

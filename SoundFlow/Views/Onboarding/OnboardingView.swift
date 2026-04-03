import SwiftUI

struct OnboardingView: View {
    var body: some View {
        Text("Welcome to SoundFlow")
            .foregroundStyle(Color.sfTextPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.sfBackground)
    }
}

#Preview {
    OnboardingView()
}

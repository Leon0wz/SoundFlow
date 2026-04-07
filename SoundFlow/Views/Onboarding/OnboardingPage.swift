import SwiftUI

struct OnboardingPage: View {
    let title: String
    let description: String
    let iconName: String
    var showGetStarted = false
    var onGetStarted: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundStyle(Color.sfPrimary)
            Text(title)
                .font(.title.bold())
                .foregroundStyle(Color.sfTextPrimary)
            Text(description)
                .font(.body)
                .foregroundStyle(Color.sfTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            if showGetStarted {
                Button(action: { onGetStarted?() }) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.sfPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

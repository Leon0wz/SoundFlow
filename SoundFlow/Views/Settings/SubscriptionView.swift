import SwiftUI

struct SubscriptionView: View {
    @Environment(StoreManager.self) var storeManager

    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("Premium")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

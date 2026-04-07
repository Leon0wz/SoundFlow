import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.caption)
            .foregroundStyle(Color.sfWarning)
            .padding(6)
            .background(Color.sfSurface)
            .clipShape(Circle())
    }
}

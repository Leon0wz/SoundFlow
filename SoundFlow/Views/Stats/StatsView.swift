import SwiftUI

struct StatsView: View {
    var body: some View {
        ZStack {
            Color.sfBackground.ignoresSafeArea()
            Text("Statistics")
                .foregroundStyle(Color.sfTextPrimary)
        }
    }
}

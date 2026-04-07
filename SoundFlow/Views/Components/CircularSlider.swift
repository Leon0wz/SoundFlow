import SwiftUI

struct CircularSlider: View {
    @Binding var value: Double

    var body: some View {
        Circle()
            .stroke(Color.sfSurfaceLight, lineWidth: 4)
            .frame(width: 100, height: 100)
            .overlay {
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(Color.sfPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
    }
}

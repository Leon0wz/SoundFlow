import SwiftUI
import AVFoundation

enum AppConstants {
    static let appName = "SoundFlow"

    enum Timer {
        static let freeMaxMinutes: Int = 30
        static let maxMinutes: Int = 720
        static let fadeOutDurationSeconds: Double = 30.0
        static let fadeInDurationSeconds: Double = 60.0
    }

    enum Audio {
        static let sampleRate: Double = 44_100.0
        static let bufferSize: AVAudioFrameCount = 1024
        static let maxLayers: Int = 5
        static let crossfadeDuration: Double = 3.0
    }

    enum Subscription {
        static let monthlyProductID = "com.soundflow.premium.monthly"
        static let yearlyProductID = "com.soundflow.premium.yearly"
        static let lifetimeProductID = "com.soundflow.premium.lifetime"
        static let maxFreePresets: Int = 2
        static let freeSceneIDs: Set<String> = ["rain", "ocean", "forest"]
    }

    enum UI {
        static let cornerRadius: CGFloat = 16
        static let cardHeight: CGFloat = 160
        static let gridColumns = 2
        static let animationDuration: Double = 0.3
    }
}

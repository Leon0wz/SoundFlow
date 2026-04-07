import WidgetKit
import SwiftUI

struct StandByWidget: Widget {
    let kind = "StandByWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SoundFlowWidgetProvider()) { entry in
            Text(entry.sceneName)
        }
        .configurationDisplayName("SoundFlow StandBy")
        .description("SoundFlow in StandBy mode.")
        .supportedFamilies([.systemSmall])
    }
}

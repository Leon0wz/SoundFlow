import WidgetKit
import SwiftUI

struct SoundFlowWidget: Widget {
    let kind = "SoundFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SoundFlowWidgetProvider()) { entry in
            Text(entry.sceneName)
        }
        .configurationDisplayName("SoundFlow")
        .description("Quick access to your soundscapes.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SoundFlowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: .now, sceneName: "Rain")
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: .now, sceneName: "Rain"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: .now, sceneName: "Rain")
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600))))
    }
}

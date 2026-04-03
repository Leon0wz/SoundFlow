import WidgetKit
import SwiftUI

struct SoundFlowWidgetEntryView: View {
    var body: some View {
        Text("SoundFlow")
    }
}

struct SoundFlowWidget: Widget {
    let kind: String = "SoundFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SoundFlowTimelineProvider()) { _ in
            SoundFlowWidgetEntryView()
        }
        .configurationDisplayName("SoundFlow")
        .description("Quick access to SoundFlow.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SoundFlowTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SoundFlowEntry {
        SoundFlowEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SoundFlowEntry) -> Void) {
        completion(SoundFlowEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SoundFlowEntry>) -> Void) {
        completion(Timeline(entries: [SoundFlowEntry(date: Date())], policy: .never))
    }
}

struct SoundFlowEntry: TimelineEntry {
    let date: Date
}

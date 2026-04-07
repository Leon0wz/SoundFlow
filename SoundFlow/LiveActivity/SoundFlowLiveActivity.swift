import ActivityKit
import WidgetKit
import SwiftUI

struct SoundFlowLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SoundFlowActivityAttributes.self) { context in
            HStack {
                Image(systemName: context.attributes.sceneIconName)
                Text(context.state.sceneName)
                Spacer()
                Text("\(context.state.remainingMinutes) min")
            }
            .padding()
            .background(Color.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.sceneIconName)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.sceneName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingMinutes)m")
                }
            } compactLeading: {
                Image(systemName: context.attributes.sceneIconName)
            } compactTrailing: {
                Text("\(context.state.remainingMinutes)m")
            } minimal: {
                Image(systemName: context.attributes.sceneIconName)
            }
        }
    }
}

import SwiftData
import Foundation

final class SessionTracker {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startSession(sceneID: String, category: SceneCategory) -> SleepSession {
        let session = SleepSession(sceneID: sceneID, category: category)
        modelContext.insert(session)
        return session
    }

    func endSession(_ session: SleepSession) {
        session.endDate = .now
        session.durationMinutes = Int(Date.now.timeIntervalSince(session.startDate) / 60)
        try? modelContext.save()
    }
}

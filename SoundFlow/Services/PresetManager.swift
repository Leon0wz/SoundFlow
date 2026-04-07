import SwiftData
import Foundation

final class PresetManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(name: String, layers: [SoundLayer]) {
        let preset = Preset(name: name, layers: layers)
        modelContext.insert(preset)
        try? modelContext.save()
    }

    func delete(_ preset: Preset) {
        modelContext.delete(preset)
        try? modelContext.save()
    }
}

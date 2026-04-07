import AVFoundation

final class AudioMixer {
    private var layers: [UUID: any GeneratorProtocol] = [:]

    func addLayer(_ generator: any GeneratorProtocol, id: UUID) {
        layers[id] = generator
    }

    func removeLayer(id: UUID) {
        layers[id]?.stop()
        layers.removeValue(forKey: id)
    }

    func removeAllLayers() {
        layers.values.forEach { $0.stop() }
        layers.removeAll()
    }
}

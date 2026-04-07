import Foundation

struct SceneCatalog {
    static let allScenes: [SoundScene] = [
        // === FREE SZENEN ===
        SoundScene(
            id: "rain",
            name: "Sanfter Regen",
            subtitle: "Gleichmäßiger Regen auf Fensterscheibe",
            category: .sleep,
            layers: [
                SoundLayer(generatorType: .rain, volume: 0.8, intensity: 0.5),
                SoundLayer(generatorType: .wind, volume: 0.2, intensity: 0.3),
            ],
            isPremium: false,
            gradientColors: ["1a1a2e", "16213e"],
            iconName: "cloud.rain.fill"
        ),
        SoundScene(
            id: "ocean",
            name: "Ozean",
            subtitle: "Rhythmische Wellen am Strand",
            category: .relax,
            layers: [
                SoundLayer(generatorType: .ocean, volume: 0.8, intensity: 0.6),
                SoundLayer(generatorType: .wind, volume: 0.15, intensity: 0.2),
            ],
            isPremium: false,
            gradientColors: ["0a3d62", "1e3799"],
            iconName: "water.waves"
        ),
        SoundScene(
            id: "forest",
            name: "Wald",
            subtitle: "Vögel und Wind in den Baumkronen",
            category: .nature,
            layers: [
                SoundLayer(generatorType: .forest, volume: 0.6, intensity: 0.5),
                SoundLayer(generatorType: .birds, volume: 0.4, intensity: 0.4),
                SoundLayer(generatorType: .wind, volume: 0.2, intensity: 0.2),
            ],
            isPremium: false,
            gradientColors: ["1B4332", "2D6A4F"],
            iconName: "tree.fill"
        ),

        // === PREMIUM SZENEN ===
        SoundScene(
            id: "thunderstorm",
            name: "Gewitter",
            subtitle: "Starkregen mit fernem Donner",
            category: .sleep,
            layers: [
                SoundLayer(generatorType: .heavyRain, volume: 0.7, intensity: 0.8),
                SoundLayer(generatorType: .thunder, volume: 0.5, intensity: 0.3),
                SoundLayer(generatorType: .wind, volume: 0.4, intensity: 0.6),
            ],
            isPremium: true,
            gradientColors: ["1a1a2e", "2d2d44"],
            iconName: "cloud.bolt.fill"
        ),
        SoundScene(
            id: "campfire",
            name: "Lagerfeuer",
            subtitle: "Knisterndes Feuer unter Sternenhimmel",
            category: .relax,
            layers: [
                SoundLayer(generatorType: .campfire, volume: 0.7, intensity: 0.6),
                SoundLayer(generatorType: .crickets, volume: 0.3, intensity: 0.4),
                SoundLayer(generatorType: .wind, volume: 0.1, intensity: 0.15),
            ],
            isPremium: true,
            gradientColors: ["2C1810", "8B4513"],
            iconName: "flame.fill"
        ),
        SoundScene(
            id: "deep_space",
            name: "Deep Space",
            subtitle: "Kosmische Drones und Stille",
            category: .focus,
            layers: [
                SoundLayer(generatorType: .space, volume: 0.6, intensity: 0.5),
                SoundLayer(generatorType: .pad, volume: 0.4, intensity: 0.3),
                SoundLayer(generatorType: .binaural, volume: 0.2, intensity: 0.5),
            ],
            isPremium: true,
            gradientColors: ["0B0C10", "1F2833"],
            iconName: "moon.stars.fill"
        ),
        SoundScene(
            id: "mountain_stream",
            name: "Bergbach",
            subtitle: "Klares Wasser über Kieselsteine",
            category: .nature,
            layers: [
                SoundLayer(generatorType: .stream, volume: 0.7, intensity: 0.6),
                SoundLayer(generatorType: .birds, volume: 0.25, intensity: 0.3),
                SoundLayer(generatorType: .breeze, volume: 0.15, intensity: 0.2),
            ],
            isPremium: true,
            gradientColors: ["1B4332", "52796F"],
            iconName: "drop.fill"
        ),
        SoundScene(
            id: "cafe",
            name: "Café",
            subtitle: "Gedämpftes Gespräch und Tassen",
            category: .focus,
            layers: [
                SoundLayer(generatorType: .cafe, volume: 0.5, intensity: 0.5),
                SoundLayer(generatorType: .ambient, volume: 0.2, intensity: 0.3),
            ],
            isPremium: true,
            gradientColors: ["3E2723", "5D4037"],
            iconName: "cup.and.saucer.fill"
        ),
        SoundScene(
            id: "underwater",
            name: "Unterwasser",
            subtitle: "Gedämpfte Klänge der Tiefe",
            category: .relax,
            layers: [
                SoundLayer(generatorType: .underwater, volume: 0.7, intensity: 0.5),
                SoundLayer(generatorType: .pad, volume: 0.3, intensity: 0.4),
            ],
            isPremium: true,
            gradientColors: ["003049", "00587A"],
            iconName: "water.waves"
        ),
        SoundScene(
            id: "cave",
            name: "Tropfsteinhöhle",
            subtitle: "Echo und fallende Tropfen",
            category: .sleep,
            layers: [
                SoundLayer(generatorType: .cave, volume: 0.5, intensity: 0.4),
                SoundLayer(generatorType: .drops, volume: 0.6, intensity: 0.5),
                SoundLayer(generatorType: .drone, volume: 0.2, intensity: 0.2),
            ],
            isPremium: true,
            gradientColors: ["1a1a1a", "2d2d2d"],
            iconName: "mountain.2.fill"
        ),
        SoundScene(
            id: "night_jungle",
            name: "Nacht-Dschungel",
            subtitle: "Frösche, Grillen und ferne Rufe",
            category: .nature,
            layers: [
                SoundLayer(generatorType: .jungle, volume: 0.5, intensity: 0.6),
                SoundLayer(generatorType: .frogs, volume: 0.4, intensity: 0.5),
                SoundLayer(generatorType: .crickets, volume: 0.3, intensity: 0.4),
            ],
            isPremium: true,
            gradientColors: ["0B3D0B", "1B5E20"],
            iconName: "leaf.fill"
        ),
        SoundScene(
            id: "white_noise_pure",
            name: "Reines Rauschen",
            subtitle: "White, Pink oder Brown Noise",
            category: .focus,
            layers: [
                SoundLayer(generatorType: .pinkNoise, volume: 0.7, intensity: 0.5),
            ],
            isPremium: true,
            gradientColors: ["212121", "424242"],
            iconName: "waveform"
        ),
        SoundScene(
            id: "focus_binaural",
            name: "Fokus-Frequenz",
            subtitle: "Binaurale Beats für Konzentration",
            category: .focus,
            layers: [
                SoundLayer(generatorType: .binaural, volume: 0.5, intensity: 0.6),
                SoundLayer(generatorType: .pad, volume: 0.4, intensity: 0.4),
                SoundLayer(generatorType: .brownNoise, volume: 0.15, intensity: 0.3),
            ],
            isPremium: true,
            gradientColors: ["1A237E", "283593"],
            iconName: "headphones"
        ),
    ]

    static func scenes(for category: SceneCategory) -> [SoundScene] {
        allScenes.filter { $0.category == category }
    }

    static func scene(byID id: String) -> SoundScene? {
        allScenes.first { $0.id == id }
    }

    static var freeScenes: [SoundScene] {
        allScenes.filter { $0.isFree }
    }

    static var premiumScenes: [SoundScene] {
        allScenes.filter { $0.isPremium }
    }
}

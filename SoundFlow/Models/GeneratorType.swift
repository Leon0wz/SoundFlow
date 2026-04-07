import Foundation

enum GeneratorType: String, Codable, CaseIterable, Identifiable {
    case whiteNoise, pinkNoise, brownNoise
    case rain, heavyRain, drizzle
    case ocean, waves, underwater
    case wind, breeze, gust
    case thunder
    case birds, crickets, frogs
    case fire, campfire
    case forest, jungle
    case city, cafe, traffic
    case space, drone
    case stream, river, waterfall
    case cave, drops
    case pad, ambient
    case binaural

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .whiteNoise: "Weißes Rauschen"
        case .pinkNoise: "Rosa Rauschen"
        case .brownNoise: "Braunes Rauschen"
        case .rain: "Regen"
        case .heavyRain: "Starkregen"
        case .drizzle: "Nieselregen"
        case .ocean: "Ozean"
        case .waves: "Wellen"
        case .underwater: "Unterwasser"
        case .wind: "Wind"
        case .breeze: "Brise"
        case .gust: "Sturm"
        case .thunder: "Donner"
        case .birds: "Vögel"
        case .crickets: "Grillen"
        case .frogs: "Frösche"
        case .fire: "Feuer"
        case .campfire: "Lagerfeuer"
        case .forest: "Wald"
        case .jungle: "Dschungel"
        case .city: "Stadt"
        case .cafe: "Café"
        case .traffic: "Verkehr"
        case .space: "Weltraum"
        case .drone: "Drone"
        case .stream: "Bach"
        case .river: "Fluss"
        case .waterfall: "Wasserfall"
        case .cave: "Höhle"
        case .drops: "Tropfen"
        case .pad: "Pad"
        case .ambient: "Ambient"
        case .binaural: "Binaural"
        }
    }

    var iconName: String {
        switch self {
        case .whiteNoise, .pinkNoise, .brownNoise: "waveform"
        case .rain, .heavyRain, .drizzle: "cloud.rain.fill"
        case .ocean, .waves, .underwater: "water.waves"
        case .wind, .breeze, .gust: "wind"
        case .thunder: "cloud.bolt.fill"
        case .birds, .crickets, .frogs: "bird.fill"
        case .fire, .campfire: "flame.fill"
        case .forest, .jungle: "tree.fill"
        case .city, .cafe, .traffic: "building.2.fill"
        case .space, .drone: "moon.stars.fill"
        case .stream, .river, .waterfall: "drop.fill"
        case .cave, .drops: "mountain.2.fill"
        case .pad, .ambient: "waveform"
        case .binaural: "headphones"
        }
    }
}

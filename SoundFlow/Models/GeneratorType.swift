import Foundation

enum GeneratorType: String, Codable, CaseIterable, Identifiable {
    case whiteNoise = "white_noise"
    case pinkNoise = "pink_noise"
    case brownNoise = "brown_noise"
    case rain
    case waves
    case wind
    case thunder
    case birds
    case fire
    case forest
    case city
    case space
    case underwater
    case stream
    case cave
    case pad
    case binaural

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .whiteNoise: "White Noise"
        case .pinkNoise: "Pink Noise"
        case .brownNoise: "Brown Noise"
        case .rain: "Rain"
        case .waves: "Ocean Waves"
        case .wind: "Wind"
        case .thunder: "Thunder"
        case .birds: "Birds"
        case .fire: "Fireplace"
        case .forest: "Forest"
        case .city: "City"
        case .space: "Space"
        case .underwater: "Underwater"
        case .stream: "Stream"
        case .cave: "Cave"
        case .pad: "Pad"
        case .binaural: "Binaural Beats"
        }
    }

    var iconName: String {
        switch self {
        case .whiteNoise, .pinkNoise, .brownNoise: "waveform"
        case .rain: "cloud.rain.fill"
        case .waves: "water.waves"
        case .wind: "wind"
        case .thunder: "cloud.bolt.fill"
        case .birds: "bird.fill"
        case .fire: "flame.fill"
        case .forest: "tree.fill"
        case .city: "building.2.fill"
        case .space: "moon.stars.fill"
        case .underwater: "drop.fill"
        case .stream: "humidity.fill"
        case .cave: "mountain.2.fill"
        case .pad: "pianokeys"
        case .binaural: "headphones"
        }
    }

    var isPremium: Bool {
        switch self {
        case .rain, .waves, .wind, .whiteNoise, .pinkNoise, .brownNoise, .forest:
            false
        default:
            true
        }
    }
}

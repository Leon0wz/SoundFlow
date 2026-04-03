import SwiftUI

extension Color {
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - SoundFlow Palette
    static let sfBackground     = Color(hex: "0A0E1A")       // Tiefes Nachtblau
    static let sfSurface        = Color(hex: "141B2D")        // Karten-Hintergrund
    static let sfSurfaceLight   = Color(hex: "1E2740")        // Erhöhte Flächen
    static let sfPrimary        = Color(hex: "6C63FF")        // Akzent-Violett
    static let sfSecondary      = Color(hex: "00D9FF")        // Cyan-Akzent
    static let sfTextPrimary    = Color.white
    static let sfTextSecondary  = Color(hex: "8892B0")        // Gedämpftes Grau-Blau
    static let sfGlow           = Color(hex: "6C63FF").opacity(0.4) // Glow-Effekt
    static let sfSuccess        = Color(hex: "00C48C")
    static let sfWarning        = Color(hex: "FFB946")
}

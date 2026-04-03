import SwiftUI

enum Theme {
    // MARK: - Colors

    static let background = Color(hex: 0x0A0A0A)
    static let surface = Color(hex: 0x1A1A1C)
    static let card = Color(hex: 0x2C2C2E)
    static let border = Color(hex: 0x3A3A3C)

    static let olive = Color(hex: 0x4A5A2B)
    static let oliveLight = Color(hex: 0x6B7D3A)
    static let amber = Color(hex: 0xD4A017)
    static let amberDim = Color(hex: 0xA67C12)

    static let textPrimary = Color(hex: 0xE8E6E1)
    static let textSecondary = Color(hex: 0x8E8E93)
    static let textTertiary = Color(hex: 0x636366)

    static let danger = Color(hex: 0xC0392B)
    static let dangerDim = Color(hex: 0x8B2D1F)
    static let success = Color(hex: 0x27AE60)
    static let info = Color(hex: 0x3498DB)

    static let proteinColor = Color(hex: 0x3498DB)
    static let carbsColor = Color(hex: 0xD4A017)
    static let fatColor = Color(hex: 0xC0392B)
    static let waterColor = Color(hex: 0x5DADE2)

    // MARK: - Typography

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default).width(.condensed)
    }

    static func label(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    static let cornerRadius: CGFloat = 4
    static let cardCornerRadius: CGFloat = 6

    // MARK: - Animation

    static let snapAnimation = Animation.spring(response: 0.3, dampingFraction: 0.85)
    static let quickFade = Animation.easeOut(duration: 0.15)
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

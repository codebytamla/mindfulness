//
//  AppTheme.swift
//  mindfulness
//
//  Created by Claude on 3/9/2025.
//

import SwiftUI

enum WaterTheme: String, CaseIterable {
    case riverFlow = "River Flow"
    case moonlitLake = "Moonlit Lake"
    case tropicalLagoon = "Tropical Lagoon"
    case deepStream = "Deep Stream"
    case morningTide = "Morning Tide"
    case crystalSprings = "Crystal Springs"
    case glacierPool = "Glacier Pool"
    case underwaterCave = "Underwater Cave"
    
    var colors: ThemeColors {
        switch self {
        case .riverFlow:
            return ThemeColors(
                bgGradientStart: Color(hex: "1E3A5F"),
                bgGradientEnd: Color(hex: "2E5B7E"),
                primary: Color(hex: "5E9EC8"),
                accent: Color(hex: "8AC4E6"),
                textPrimary: Color(hex: "E8F4F8"),
                textSecondary: Color(hex: "B8D4E3"),
                cardBackground: Color(hex: "2E5B7E").opacity(0.3),
                buttonGradientStart: Color(hex: "5E9EC8"),
                buttonGradientEnd: Color(hex: "6EAED8"),
                glowColor: Color(hex: "8AC4E6").opacity(0.25)
            )
        case .moonlitLake:
            return ThemeColors(
                bgGradientStart: Color(hex: "0F1F3D"),
                bgGradientEnd: Color(hex: "1A3254"),
                primary: Color(hex: "4B7FA6"),
                accent: Color(hex: "7BA7CC"),
                textPrimary: Color(hex: "D6E5F0"),
                textSecondary: Color(hex: "A8C5D8"),
                cardBackground: Color(hex: "1A3254").opacity(0.4),
                buttonGradientStart: Color(hex: "4B7FA6"),
                buttonGradientEnd: Color(hex: "5B8FB6"),
                glowColor: Color(hex: "7BA7CC").opacity(0.2)
            )
        case .tropicalLagoon:
            return ThemeColors(
                bgGradientStart: Color(hex: "1B4F72"),
                bgGradientEnd: Color(hex: "2E86AB"),
                primary: Color(hex: "5DADE2"),
                accent: Color(hex: "85C1E5"),
                textPrimary: Color(hex: "F0F8FC"),
                textSecondary: Color(hex: "AED6F1"),
                cardBackground: Color(hex: "2E86AB").opacity(0.25),
                buttonGradientStart: Color(hex: "5DADE2"),
                buttonGradientEnd: Color(hex: "6DBDF2"),
                glowColor: Color(hex: "85C1E5").opacity(0.3)
            )
        case .deepStream:
            return ThemeColors(
                bgGradientStart: Color(hex: "1C3A52"),
                bgGradientEnd: Color(hex: "2C5F7C"),
                primary: Color(hex: "4A90B8"),
                accent: Color(hex: "6FA8C8"),
                textPrimary: Color(hex: "E2EFF5"),
                textSecondary: Color(hex: "B0CDD9"),
                cardBackground: Color(hex: "2C5F7C").opacity(0.35),
                buttonGradientStart: Color(hex: "4A90B8"),
                buttonGradientEnd: Color(hex: "5AA0C8"),
                glowColor: Color(hex: "6FA8C8").opacity(0.25)
            )
        case .morningTide:
            return ThemeColors(
                bgGradientStart: Color(hex: "264653"),
                bgGradientEnd: Color(hex: "2A6F8A"),
                primary: Color(hex: "52B2CF"),
                accent: Color(hex: "84D2E4"),
                textPrimary: Color(hex: "EFF8FA"),
                textSecondary: Color(hex: "B8DDE8"),
                cardBackground: Color(hex: "2A6F8A").opacity(0.3),
                buttonGradientStart: Color(hex: "52B2CF"),
                buttonGradientEnd: Color(hex: "62C2DF"),
                glowColor: Color(hex: "84D2E4").opacity(0.25)
            )
        case .crystalSprings:
            return ThemeColors(
                bgGradientStart: Color(hex: "1E4E6B"),
                bgGradientEnd: Color(hex: "2E7FA6"),
                primary: Color(hex: "5CAFDB"),
                accent: Color(hex: "8CC8E8"),
                textPrimary: Color(hex: "F2FAFD"),
                textSecondary: Color(hex: "C2E0ED"),
                cardBackground: Color(hex: "2E7FA6").opacity(0.25),
                buttonGradientStart: Color(hex: "5CAFDB"),
                buttonGradientEnd: Color(hex: "6CBFEB"),
                glowColor: Color(hex: "8CC8E8").opacity(0.28)
            )
        case .glacierPool:
            return ThemeColors(
                bgGradientStart: Color(hex: "1A3A52"),
                bgGradientEnd: Color(hex: "285170"),
                primary: Color(hex: "4682B4"),
                accent: Color(hex: "6FA5D2"),
                textPrimary: Color(hex: "E6F2F8"),
                textSecondary: Color(hex: "B0CDDE"),
                cardBackground: Color(hex: "285170").opacity(0.35),
                buttonGradientStart: Color(hex: "4682B4"),
                buttonGradientEnd: Color(hex: "5692C4"),
                glowColor: Color(hex: "6FA5D2").opacity(0.22)
            )
        case .underwaterCave:
            return ThemeColors(
                bgGradientStart: Color(hex: "0E2433"),
                bgGradientEnd: Color(hex: "1C4966"),
                primary: Color(hex: "3E7FA7"),
                accent: Color(hex: "5A9BC7"),
                textPrimary: Color(hex: "D4E5F0"),
                textSecondary: Color(hex: "9CBDD4"),
                cardBackground: Color(hex: "1C4966").opacity(0.4),
                buttonGradientStart: Color(hex: "3E7FA7"),
                buttonGradientEnd: Color(hex: "4E8FB7"),
                glowColor: Color(hex: "5A9BC7").opacity(0.2)
            )
        }
    }
}

struct ThemeColors {
    let bgGradientStart: Color
    let bgGradientEnd: Color
    let primary: Color
    let accent: Color
    let textPrimary: Color
    let textSecondary: Color
    let cardBackground: Color
    let buttonGradientStart: Color
    let buttonGradientEnd: Color
    let glowColor: Color
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: WaterTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        self.currentTheme = WaterTheme.allCases.first { $0.rawValue == savedTheme } ?? .riverFlow
    }
}

extension EnvironmentValues {
    private struct ThemeKey: EnvironmentKey {
        static let defaultValue = WaterTheme.riverFlow.colors
    }
    
    var theme: ThemeColors {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
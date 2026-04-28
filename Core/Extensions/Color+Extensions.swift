// Color+Extensions.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

extension Color {

    /// Creates a Color from a hex string (e.g., "#FF5733" or "FF5733").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    /// Returns the color for a given risk level.
    static func forRiskLevel(_ level: RiskLevel) -> Color {
        switch level {
        case .low:      return Theme.Colors.riskLow
        case .moderate:  return Theme.Colors.riskMedium
        case .high:     return Theme.Colors.riskHigh
        case .critical: return Theme.Colors.riskCritical
        case .unknown:  return Theme.Colors.textSecondary
        }
    }

    /// Returns the color for a given risk score (0-100).
    static func forRiskScore(_ score: Int) -> Color {
        forRiskLevel(RiskLevel.fromScore(score))
    }
}

// MARK: - RiskLevel Color Extension

extension RiskLevel {
    /// Presentation-layer color for this risk level.
    var color: Color {
        Color.forRiskLevel(self)
    }
}

// Theme.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// Centralized theme configuration for consistent styling across the app.
enum Theme {

    // MARK: - Colors

    enum Colors {
        // Primary
        static let primary = Color("PrimaryColor", bundle: nil)
        static let primaryFallback = Color(hex: "2563EB")
        static let secondary = Color(hex: "7C3AED")
        static let accent = Color(hex: "F59E0B")

        // Background
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        static let groupedBackground = Color(UIColor.systemGroupedBackground)

        // Text
        static let textPrimary = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let textTertiary = Color(UIColor.tertiaryLabel)

        // Risk Levels
        static let riskLow = Color(hex: "22C55E")       // Green
        static let riskMedium = Color(hex: "F59E0B")     // Amber
        static let riskHigh = Color(hex: "EF4444")       // Red
        static let riskCritical = Color(hex: "7C2D12")   // Dark Red

        // Weather
        static let sunny = Color(hex: "FCD34D")
        static let cloudy = Color(hex: "9CA3AF")
        static let rainy = Color(hex: "3B82F6")
        static let stormy = Color(hex: "6B21A8")
        static let snowy = Color(hex: "E0F2FE")

        // Semantic
        static let success = Color(hex: "22C55E")
        static let warning = Color(hex: "F59E0B")
        static let error = Color(hex: "EF4444")
        static let info = Color(hex: "3B82F6")

        // Card
        static let cardBackground = Color(UIColor.secondarySystemBackground)
        static let cardShadow = Color.black.opacity(0.08)
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Custom
        static let riskScore = Font.system(size: 48, weight: .bold, design: .rounded)
        static let temperature = Font.system(size: 56, weight: .thin, design: .rounded)
        static let statValue = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let statLabel = Font.system(size: 12, weight: .medium, design: .rounded)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxSmall: CGFloat = 2
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let standard: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let xxxLarge: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let circular: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadows {
        static let small = ShadowStyle(color: Colors.cardShadow, radius: 4, x: 0, y: 2)
        static let medium = ShadowStyle(color: Colors.cardShadow, radius: 8, x: 0, y: 4)
        static let large = ShadowStyle(color: Colors.cardShadow, radius: 16, x: 0, y: 8)
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let xLarge: CGFloat = 48
        static let xxLarge: CGFloat = 64
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Shadow View Modifier

extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

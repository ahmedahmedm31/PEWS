// CardModifier.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A view modifier that applies standard card styling with background, corner radius, and shadow.
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.CornerRadius.large
    var shadowStyle: ShadowStyle = Theme.Shadows.small

    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.standard)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.Colors.cardBackground)
            )
            .shadow(shadowStyle)
    }
}

/// A view modifier for elevated card styling with more prominent shadow.
struct ElevatedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.standard)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(Theme.Colors.cardBackground)
            )
            .shadow(Theme.Shadows.medium)
    }
}

/// A view modifier for gradient card backgrounds.
struct GradientCardModifier: ViewModifier {
    let colors: [Color]

    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.standard)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(Theme.Shadows.small)
    }
}

extension View {
    func elevatedCard() -> some View {
        self.modifier(ElevatedCardModifier())
    }

    func gradientCard(colors: [Color]) -> some View {
        self.modifier(GradientCardModifier(colors: colors))
    }
}

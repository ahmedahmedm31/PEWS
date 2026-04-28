// View+Extensions.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

extension View {

    /// Applies the standard card styling modifier.
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }

    /// Conditionally applies a modifier.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies a loading overlay when the condition is true.
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                LoadingView()
            }
        }
    }

    /// Applies standard accessibility sizing.
    func accessibleTouchTarget() -> some View {
        self.frame(
            minWidth: AppConfig.UI.minimumTouchTarget,
            minHeight: AppConfig.UI.minimumTouchTarget
        )
    }

    /// Applies a fade-in animation on appear.
    func fadeInOnAppear(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }

    /// Hides the view based on a condition.
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }

    /// Applies a shimmer loading effect.
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

// MARK: - Fade In Modifier

struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: AppConfig.UI.defaultAnimationDuration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 300
                        }
                    }
                )
                .clipped()
        } else {
            content
        }
    }
}

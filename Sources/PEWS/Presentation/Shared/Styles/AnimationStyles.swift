// AnimationStyles.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// Centralized animation definitions for consistent motion throughout the app.
enum AnimationStyles {

    /// Standard spring animation for most UI interactions.
    static let standard = Animation.spring(
        response: Constants.Animation.springResponse,
        dampingFraction: Constants.Animation.springDamping
    )

    /// Quick animation for small state changes.
    static let quick = Animation.easeInOut(duration: 0.15)

    /// Smooth animation for transitions.
    static let smooth = Animation.easeInOut(duration: Constants.Animation.defaultDuration)

    /// Slow animation for gauge and chart reveals.
    static let reveal = Animation.easeOut(duration: Constants.Animation.gaugeAnimationDuration)

    /// Chart data animation.
    static let chart = Animation.easeInOut(duration: Constants.Animation.chartAnimationDuration)

    /// Bounce animation for attention-grabbing elements.
    static let bounce = Animation.spring(response: 0.4, dampingFraction: 0.5)

    /// Gentle pulse animation.
    static let pulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
}

// MARK: - Transition Styles

extension AnyTransition {
    /// Slide up with fade transition.
    static var slideUpFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
    }

    /// Scale with fade transition.
    static var scaleFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }

    /// Slide from trailing edge.
    static var slideTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

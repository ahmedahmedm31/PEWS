// ErrorView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A reusable error state view with retry action.
struct ErrorView: View {
    let message: String
    let retryAction: (() async -> Void)?

    init(message: String, retryAction: (() async -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: Theme.IconSize.xxLarge))
                .foregroundColor(Theme.Colors.error)
                .accessibilityHidden(true)

            Text("Something Went Wrong")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xxLarge)

            if let retryAction = retryAction {
                Button {
                    Task { await retryAction() }
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.primary)
                .padding(.horizontal, Theme.Spacing.xxxLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            message: "Unable to fetch weather data. Please check your internet connection.",
            retryAction: { }
        )
    }
}
#endif

// EmptyStateView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A reusable empty state view with icon, title, message, and optional action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String = "tray",
        title: String = "No Data",
        message: String = "There's nothing to show here yet.",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.xxLarge))
                .foregroundColor(Theme.Colors.textTertiary)
                .accessibilityHidden(true)

            Text(title)
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(message)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xxLarge)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.primary)
                    .padding(.horizontal, Theme.Spacing.xxxLarge)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(
            icon: "location.slash",
            title: "No Locations",
            message: "Add a location to start monitoring weather conditions.",
            actionTitle: "Add Location",
            action: { }
        )
    }
}
#endif

// OnboardingView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// Onboarding flow presented on first launch to introduce the app's features.
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "shield.checkered",
            title: "Welcome to PEWS",
            description: "Your Predictive Early Warning System for weather crisis monitoring and prediction.",
            color: .blue
        ),
        OnboardingPage(
            icon: "gauge.medium",
            title: "Real-Time Risk Assessment",
            description: "Monitor weather conditions with an intuitive risk gauge that shows your current crisis risk level from Low to Critical.",
            color: .orange
        ),
        OnboardingPage(
            icon: "brain",
            title: "ML-Powered Predictions",
            description: "Our machine learning model analyzes weather patterns to predict potential crises up to 48 hours in advance.",
            color: .purple
        ),
        OnboardingPage(
            icon: "bell.badge",
            title: "Smart Alerts",
            description: "Receive customizable notifications when risk levels exceed your threshold. Stay informed, stay safe.",
            color: .red
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Historical Analysis",
            description: "Track weather trends over time with interactive charts and export data for further analysis.",
            color: .green
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    onboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation { currentPage -= 1 }
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation { currentPage += 1 }
                    }
                    .fontWeight(.semibold)
                } else {
                    Button("Get Started") {
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.horizontal, Theme.Spacing.xLarge)
                    .padding(.vertical, Theme.Spacing.medium)
                    .background(Theme.Colors.primaryFallback)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, Theme.Spacing.xLarge)
            .padding(.bottom, Theme.Spacing.xLarge)
        }
        .background(Theme.Colors.background)
    }

    private func onboardingPageView(page: OnboardingPage) -> some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .padding()

            Text(page.title)
                .font(Theme.Typography.title)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xLarge)

            Spacer()
            Spacer()
        }
    }
}

/// Data model for an onboarding page.
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
#endif

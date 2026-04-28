// DashboardView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// Main dashboard view displaying weather data, risk gauge, and forecasts.
struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Loading weather data...")

                case .loaded:
                    dashboardContent

                case .error(let message):
                    ErrorView(message: message) {
                        await viewModel.refresh()
                    }

                case .empty:
                    EmptyStateView(
                        icon: "cloud.sun",
                        title: "No Weather Data",
                        message: "Add a location to start monitoring weather conditions."
                    )
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    locationPicker
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Dashboard Content

    @ViewBuilder
    private var dashboardContent: some View {
        RefreshableScrollView(onRefresh: { await viewModel.refresh() }) {
            if horizontalSizeClass == .compact {
                compactLayout
            } else {
                regularLayout
            }
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        LazyVStack(spacing: Theme.Spacing.standard) {
            riskGaugeSection
            weatherCardSection
            forecastSection
            contributingFactorsSection
            lastUpdatedSection
        }
        .padding(.horizontal, Theme.Spacing.standard)
        .padding(.bottom, Theme.Spacing.xxLarge)
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: Theme.Spacing.standard
        ) {
            riskGaugeSection
            weatherCardSection
            forecastSection
            contributingFactorsSection
        }
        .padding(Theme.Spacing.standard)
    }

    // MARK: - Sections

    private var riskGaugeSection: some View {
        VStack(spacing: Theme.Spacing.small) {
            RiskGaugeView(
                riskScore: viewModel.riskScore,
                riskLevel: viewModel.riskLevel
            )

            if let prediction = viewModel.prediction {
                Text("Confidence: \(prediction.confidencePercentageString)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .cardStyle()
        .fadeInOnAppear(delay: 0.1)
    }

    private var weatherCardSection: some View {
        Group {
            if let weather = viewModel.currentWeather {
                WeatherCardView(weather: weather)
                    .fadeInOnAppear(delay: 0.2)
            }
        }
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("7-Day Forecast")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.textPrimary)

            ForEach(viewModel.forecast) { day in
                ForecastRowView(forecast: day)
            }
        }
        .cardStyle()
        .fadeInOnAppear(delay: 0.3)
    }

    private var contributingFactorsSection: some View {
        Group {
            if let prediction = viewModel.prediction,
               !prediction.contributingFactors.isEmpty {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Text("Risk Factors")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.textPrimary)

                    ForEach(prediction.contributingFactors) { factor in
                        HStack {
                            Circle()
                                .fill(colorForSeverity(factor.severity))
                                .frame(width: 8, height: 8)

                            Text(factor.name)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            Spacer()

                            Text(factor.formattedValue)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
                .cardStyle()
                .fadeInOnAppear(delay: 0.4)
            }
        }
    }

    private var lastUpdatedSection: some View {
        Text(viewModel.lastUpdatedString)
            .font(Theme.Typography.caption)
            .foregroundColor(Theme.Colors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, Theme.Spacing.small)
    }

    // MARK: - Location Picker

    private var locationPicker: some View {
        Menu {
            ForEach(viewModel.locations) { location in
                Button {
                    Task { await viewModel.selectLocation(location) }
                } label: {
                    Label(
                        location.displayName,
                        systemImage: location.id == viewModel.selectedLocation.id
                            ? "checkmark.circle.fill"
                            : "mappin"
                    )
                }
            }
        } label: {
            Image(systemName: "location.circle")
                .font(.title3)
        }
        .accessibilityLabel("Select location")
    }

    // MARK: - Helpers

    private func colorForSeverity(_ severity: FactorSeverity) -> Color {
        switch severity {
        case .low: return Theme.Colors.riskLow
        case .moderate: return Theme.Colors.riskMedium
        case .high: return Theme.Colors.riskHigh
        case .critical: return Theme.Colors.riskCritical
        }
    }
}

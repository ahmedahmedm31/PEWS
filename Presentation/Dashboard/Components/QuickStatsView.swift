// QuickStatsView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A grid view displaying quick weather statistics (humidity, wind, pressure, visibility).
struct QuickStatsView: View {
    let weather: WeatherData

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            StatItem(
                icon: Constants.WeatherIcons.humidity,
                value: weather.humidity.percentageString,
                label: "Humidity"
            )

            StatItem(
                icon: Constants.WeatherIcons.wind,
                value: weather.windSpeed.windSpeedString(),
                label: "Wind"
            )

            StatItem(
                icon: Constants.WeatherIcons.pressure,
                value: String(format: "%.0f hPa", weather.pressure),
                label: "Pressure"
            )

            StatItem(
                icon: Constants.WeatherIcons.visibility,
                value: formatVisibility(weather.visibility),
                label: "Visibility"
            )
        }
    }

    private func formatVisibility(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        }
        return String(format: "%.0f m", meters)
    }
}

/// A single statistic item with icon, value, and label.
struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.small))
                .foregroundColor(Theme.Colors.primaryFallback)

            Text(value)
                .font(Theme.Typography.statLabel)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(label)
                .font(Theme.Typography.caption2)
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#if DEBUG
struct QuickStatsView_Previews: PreviewProvider {
    static var previews: some View {
        QuickStatsView(weather: WeatherData.mock())
            .padding()
    }
}
#endif

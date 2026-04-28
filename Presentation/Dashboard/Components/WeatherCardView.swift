// WeatherCardView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A card displaying current weather conditions with temperature, condition, and key metrics.
struct WeatherCardView: View {
    let weather: WeatherData

    var body: some View {
        VStack(spacing: Theme.Spacing.standard) {
            // Location and condition header
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                    Text(weather.location.displayName)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text(weather.conditionDescription)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: weather.iconName)
                    .font(.system(size: Theme.IconSize.xLarge))
                    .foregroundColor(Theme.Colors.primaryFallback)
                    .symbolRenderingMode(.multicolor)
            }

            // Temperature
            HStack(alignment: .top) {
                Text(weather.temperature.temperatureString())
                    .font(Theme.Typography.temperature)
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                VStack(alignment: .trailing, spacing: Theme.Spacing.xSmall) {
                    Label("Feels like \(weather.feelsLike.temperatureString())", systemImage: "thermometer.medium")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)

                    HStack(spacing: Theme.Spacing.small) {
                        Text("H: \(weather.tempMax.temperatureString())")
                        Text("L: \(weather.tempMin.temperatureString())")
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Divider()

            // Quick stats grid
            QuickStatsView(weather: weather)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(weather.location.name), \(weather.temperature.temperatureString()), \(weather.conditionDescription)"
        )
    }
}

#if DEBUG
struct WeatherCardView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherCardView(weather: WeatherData.mock())
            .padding()
    }
}
#endif

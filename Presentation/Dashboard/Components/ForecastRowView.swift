// ForecastRowView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// A row displaying a single day's forecast with day, icon, condition, and temperature range.
struct ForecastRowView: View {
    let forecast: Forecast

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Day label
            Text(forecast.dayLabel)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textPrimary)
                .frame(width: 80, alignment: .leading)

            // Weather icon
            Image(systemName: iconForCondition(forecast.condition))
                .font(.title3)
                .foregroundColor(Theme.Colors.primaryFallback)
                .symbolRenderingMode(.multicolor)
                .frame(width: 30)

            // Precipitation probability
            if forecast.precipitationProbability > 0.1 {
                Text(String(format: "%.0f%%", forecast.precipitationProbability * 100))
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.rainy)
                    .frame(width: 35)
            } else {
                Spacer()
                    .frame(width: 35)
            }

            Spacer()

            // Temperature range bar
            TemperatureRangeBar(
                low: forecast.tempMin,
                high: forecast.tempMax,
                absoluteLow: 0,
                absoluteHigh: 40
            )
            .frame(width: 80)

            // Temperature labels
            HStack(spacing: Theme.Spacing.small) {
                Text(forecast.tempMin.temperatureString())
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(width: 40, alignment: .trailing)

                Text(forecast.tempMax.temperatureString())
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(width: 40, alignment: .trailing)
            }
        }
        .padding(.vertical, Theme.Spacing.xSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(forecast.dayLabel), \(forecast.conditionDescription), low \(forecast.tempMin.temperatureString()), high \(forecast.tempMax.temperatureString())"
        )
    }

    private func iconForCondition(_ condition: WeatherCondition) -> String {
        WeatherMapper.mapToIcon(conditionID: condition.conditionID, isNight: false)
    }
}

/// A visual bar showing the temperature range relative to absolute bounds.
struct TemperatureRangeBar: View {
    let low: Double
    let high: Double
    let absoluteLow: Double
    let absoluteHigh: Double

    var body: some View {
        GeometryReader { geometry in
            let range = absoluteHigh - absoluteLow
            let startFraction = max(0, (low - absoluteLow) / range)
            let endFraction = min(1, (high - absoluteLow) / range)

            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Theme.Colors.secondaryBackground)
                    .frame(height: 4)

                // Range bar
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.rainy, Theme.Colors.sunny],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * (endFraction - startFraction),
                        height: 4
                    )
                    .offset(x: geometry.size.width * startFraction)
            }
        }
        .frame(height: 4)
    }
}

#if DEBUG
struct ForecastRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(Forecast.mockWeek()) { forecast in
                ForecastRowView(forecast: forecast)
            }
        }
        .padding()
    }
}
#endif

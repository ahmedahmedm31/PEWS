// TrendChartView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI
import Charts

/// A chart view displaying weather data trends over time using Swift Charts.
@available(iOS 16.0, *)
struct TrendChartView: View {
    let dataPoints: [TrendDataPoint]
    let title: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text(title)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Chart(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.date),
                    y: .value(title, point.value)
                )
                .foregroundStyle(color)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Time", point.date),
                    y: .value(title, point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.3), color.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .chartYAxisLabel(unit)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .frame(height: 200)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) trend chart showing \(dataPoints.count) data points")
    }
}

/// A data point for trend charts.
struct TrendDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

#if DEBUG
struct TrendChartView_Previews: PreviewProvider {
    static var previews: some View {
        TrendChartView(
            dataPoints: (0..<24).map { hour in
                TrendDataPoint(
                    date: Date().addingTimeInterval(TimeInterval(hour * 3600)),
                    value: 15.0 + Double.random(in: -3...3)
                )
            },
            title: "Temperature",
            unit: "°C",
            color: Theme.Colors.primaryFallback
        )
        .padding()
    }
}
#endif

// HistoryView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// View displaying historical weather data with charts, statistics, and export options.
struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    LoadingView(message: "Loading historical data...")

                case .loaded:
                    historyContent

                case .empty:
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "No Historical Data",
                        message: "No weather data available for the selected date range."
                    )

                case .error(let message):
                    ErrorView(message: message) {
                        await viewModel.loadData()
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    exportButton
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Content

    private var historyContent: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.standard) {
                dateRangeSection
                chartTypeSelector
                chartSection
                statisticsSection
            }
            .padding(.horizontal, Theme.Spacing.standard)
            .padding(.bottom, Theme.Spacing.xxLarge)
        }
    }

    // MARK: - Date Range

    private var dateRangeSection: some View {
        DateRangePickerView(
            startDate: $viewModel.startDate,
            endDate: $viewModel.endDate,
            onChanged: {
                Task { await viewModel.onDateRangeChanged() }
            }
        )
        .cardStyle()
    }

    // MARK: - Chart Type Selector

    private var chartTypeSelector: some View {
        Picker("Chart Type", selection: $viewModel.selectedChartType) {
            ForEach(HistoryViewModel.ChartType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, Theme.Spacing.xSmall)
    }

    // MARK: - Chart

    private var chartSection: some View {
        Group {
            if #available(iOS 16.0, *) {
                TrendChartView(
                    dataPoints: viewModel.currentDataPoints,
                    title: viewModel.selectedChartType.rawValue,
                    unit: viewModel.selectedChartType.unit,
                    color: viewModel.selectedChartType.color
                )
                .cardStyle()
            } else {
                Text("Charts require iOS 16+")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .cardStyle()
            }
        }
    }

    // MARK: - Statistics

    private var statisticsSection: some View {
        Group {
            if let stats = viewModel.statistics {
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    Text("Statistics")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.textPrimary)

                    StatisticsGrid(statistics: stats)
                }
                .cardStyle()
            }
        }
    }

    // MARK: - Export Button

    private var exportButton: some View {
        Button {
            Task { await viewModel.exportCSV() }
        } label: {
            if viewModel.isExporting {
                ProgressView()
            } else {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .disabled(viewModel.isExporting || viewModel.historicalData.isEmpty)
        .accessibilityLabel("Export data as CSV")
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let csv = viewModel.exportedCSV {
                CSVExportView(csvContent: csv)
            }
        }
    }
}

/// Grid displaying summary statistics.
struct StatisticsGrid: View {
    let statistics: HistoryStatistics

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
            StatisticCell(
                label: "Avg Temperature",
                value: String(format: "%.1f°C", statistics.avgTemperature)
            )
            StatisticCell(
                label: "Temp Range",
                value: String(format: "%.1f - %.1f°C", statistics.minTemperature, statistics.maxTemperature)
            )
            StatisticCell(
                label: "Avg Humidity",
                value: String(format: "%.0f%%", statistics.avgHumidity)
            )
            StatisticCell(
                label: "Avg Pressure",
                value: String(format: "%.0f hPa", statistics.avgPressure)
            )
            StatisticCell(
                label: "Avg Wind",
                value: String(format: "%.1f m/s", statistics.avgWindSpeed)
            )
            StatisticCell(
                label: "Max Wind",
                value: String(format: "%.1f m/s", statistics.maxWindSpeed)
            )
        }
    }
}

/// A single statistic cell with label and value.
struct StatisticCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: Theme.Spacing.xSmall) {
            Text(value)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.small)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.small)
    }
}

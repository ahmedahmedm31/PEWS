// HistoryViewModel.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI

/// ViewModel managing the History screen state, data, and export functionality.
@MainActor
final class HistoryViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var historicalData: [WeatherData] = []
    @Published private(set) var temperatureDataPoints: [TrendDataPoint] = []
    @Published private(set) var humidityDataPoints: [TrendDataPoint] = []
    @Published private(set) var pressureDataPoints: [TrendDataPoint] = []
    @Published private(set) var windDataPoints: [TrendDataPoint] = []
    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    @Published var selectedChartType: ChartType = .temperature
    @Published private(set) var isExporting = false
    @Published var showExportSheet = false
    @Published private(set) var exportedCSV: String?

    // MARK: - Chart Type

    enum ChartType: String, CaseIterable {
        case temperature = "Temperature"
        case humidity = "Humidity"
        case pressure = "Pressure"
        case wind = "Wind Speed"

        var unit: String {
            switch self {
            case .temperature: return "°C"
            case .humidity: return "%"
            case .pressure: return "hPa"
            case .wind: return "m/s"
            }
        }

        var color: Color {
            switch self {
            case .temperature: return Theme.Colors.sunny
            case .humidity: return Theme.Colors.rainy
            case .pressure: return Theme.Colors.primaryFallback
            case .wind: return Theme.Colors.cloudy
            }
        }
    }

    // MARK: - Dependencies

    private let weatherRepository: WeatherRepositoryInterface
    private let generateReportUseCase: GenerateReportUseCase
    private let location: Location

    // MARK: - Initialization

    init(
        weatherRepository: WeatherRepositoryInterface,
        generateReportUseCase: GenerateReportUseCase,
        location: Location
    ) {
        self.weatherRepository = weatherRepository
        self.generateReportUseCase = generateReportUseCase
        self.location = location
    }

    // MARK: - Data Loading

    /// Loads historical weather data for the selected date range.
    func loadData() async {
        state = .loading

        do {
            historicalData = try await weatherRepository.fetchHistoricalWeather(
                for: location,
                from: startDate,
                to: endDate
            )

            if historicalData.isEmpty {
                state = .empty
            } else {
                buildChartDataPoints()
                state = .loaded
            }

            Logger.ui("History loaded: \(historicalData.count) records")
        } catch {
            Logger.error("History load failed", error: error)
            state = .error(error.localizedDescription)
        }
    }

    /// Refreshes data when date range changes.
    func onDateRangeChanged() async {
        await loadData()
    }

    // MARK: - Chart Data Building

    private func buildChartDataPoints() {
        temperatureDataPoints = historicalData.map {
            TrendDataPoint(date: $0.timestamp, value: $0.temperature)
        }
        humidityDataPoints = historicalData.map {
            TrendDataPoint(date: $0.timestamp, value: $0.humidity)
        }
        pressureDataPoints = historicalData.map {
            TrendDataPoint(date: $0.timestamp, value: $0.pressure)
        }
        windDataPoints = historicalData.map {
            TrendDataPoint(date: $0.timestamp, value: $0.windSpeed)
        }
    }

    /// Returns the data points for the currently selected chart type.
    var currentDataPoints: [TrendDataPoint] {
        switch selectedChartType {
        case .temperature: return temperatureDataPoints
        case .humidity: return humidityDataPoints
        case .pressure: return pressureDataPoints
        case .wind: return windDataPoints
        }
    }

    // MARK: - CSV Export

    /// Exports historical data as a CSV string.
    func exportCSV() async {
        isExporting = true

        do {
            let csv = try await generateReportUseCase.executeCSV(
                location: location,
                startDate: startDate,
                endDate: endDate
            )
            exportedCSV = csv
            showExportSheet = true
            Logger.ui("CSV export ready")
        } catch {
            Logger.error("CSV export failed", error: error)
        }

        isExporting = false
    }

    // MARK: - Statistics

    /// Returns summary statistics for the current data.
    var statistics: HistoryStatistics? {
        guard !historicalData.isEmpty else { return nil }

        let temps = historicalData.map(\.temperature)
        let humidities = historicalData.map(\.humidity)
        let pressures = historicalData.map(\.pressure)
        let winds = historicalData.map(\.windSpeed)

        return HistoryStatistics(
            avgTemperature: temps.reduce(0, +) / Double(temps.count),
            maxTemperature: temps.max() ?? 0,
            minTemperature: temps.min() ?? 0,
            avgHumidity: humidities.reduce(0, +) / Double(humidities.count),
            avgPressure: pressures.reduce(0, +) / Double(pressures.count),
            avgWindSpeed: winds.reduce(0, +) / Double(winds.count),
            maxWindSpeed: winds.max() ?? 0,
            recordCount: historicalData.count
        )
    }
}

/// Summary statistics for historical weather data.
struct HistoryStatistics: Sendable {
    let avgTemperature: Double
    let maxTemperature: Double
    let minTemperature: Double
    let avgHumidity: Double
    let avgPressure: Double
    let avgWindSpeed: Double
    let maxWindSpeed: Double
    let recordCount: Int
}

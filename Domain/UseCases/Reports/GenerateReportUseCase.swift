// GenerateReportUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for generating weather and risk reports for export.
final class GenerateReportUseCase {

    // MARK: - Properties

    private let weatherRepository: WeatherRepositoryInterface
    private let predictionRepository: PredictionRepositoryInterface

    // MARK: - Initialization

    init(
        weatherRepository: WeatherRepositoryInterface,
        predictionRepository: PredictionRepositoryInterface
    ) {
        self.weatherRepository = weatherRepository
        self.predictionRepository = predictionRepository
    }

    // MARK: - Execute

    /// Generates a CSV report for the specified location and date range.
    /// - Parameters:
    ///   - location: The location to generate the report for.
    ///   - startDate: The start date of the report period.
    ///   - endDate: The end date of the report period.
    /// - Returns: A string containing the CSV-formatted report.
    func executeCSV(
        location: Location,
        startDate: Date,
        endDate: Date
    ) async throws -> String {
        let weatherData = try await weatherRepository.fetchHistoricalWeather(
            for: location,
            from: startDate,
            to: endDate
        )

        var csv = "Date,Temperature (°C),Humidity (%),Pressure (hPa),Wind Speed (m/s),Cloud Coverage (%),Precipitation (mm),Visibility (m),Condition\n"

        for data in weatherData {
            let row = [
                Formatters.displayDateTime.string(from: data.timestamp),
                String(format: "%.1f", data.temperature),
                String(format: "%.0f", data.humidity),
                String(format: "%.0f", data.pressure),
                String(format: "%.1f", data.windSpeed),
                String(format: "%.0f", data.cloudCoverage),
                String(format: "%.1f", data.precipitation),
                String(format: "%.0f", data.visibility),
                data.condition.description
            ].joined(separator: ",")
            csv += row + "\n"
        }

        Logger.info("CSV report generated: \(weatherData.count) records")
        return csv
    }

    /// Generates a summary report for the specified location.
    /// - Parameter location: The location to generate the report for.
    /// - Returns: A ReportSummary containing key metrics.
    func executeSummary(location: Location) async throws -> ReportSummary {
        let weather = try await weatherRepository.fetchCurrentWeather(for: location)
        let forecast = try await weatherRepository.fetchForecast(for: location)
        let prediction = try await predictionRepository.predictCrisis(for: weather)

        return ReportSummary(
            location: location,
            currentWeather: weather,
            forecast: forecast,
            prediction: prediction,
            generatedAt: Date()
        )
    }
}

/// Summary report containing key weather and risk metrics.
struct ReportSummary {
    let location: Location
    let currentWeather: WeatherData
    let forecast: [Forecast]
    let prediction: Prediction
    let generatedAt: Date
}

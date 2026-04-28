// FetchForecastUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for fetching weather forecast data for a location.
final class FetchForecastUseCase {

    // MARK: - Properties

    private let repository: WeatherRepositoryInterface

    // MARK: - Initialization

    init(repository: WeatherRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Execute

    /// Fetches the 7-day forecast for the specified location.
    /// - Parameter location: The location to fetch forecast for.
    /// - Returns: Array of daily forecasts, limited to 7 days.
    func execute(location: Location) async throws -> [Forecast] {
        guard location.isValid else {
            throw WeatherError.invalidCoordinates
        }

        Logger.info("Fetching forecast for \(location.name)")
        let forecasts = try await repository.fetchForecast(for: location)

        // Limit to configured forecast days
        return Array(forecasts.prefix(AppConfig.DataConstraints.forecastDays))
    }
}

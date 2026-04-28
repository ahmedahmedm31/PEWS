// FetchCurrentWeatherUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for fetching current weather data for a location.
/// Encapsulates the business logic for weather data retrieval.
final class FetchCurrentWeatherUseCase {

    // MARK: - Properties

    private let repository: WeatherRepositoryInterface

    // MARK: - Initialization

    init(repository: WeatherRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Execute

    /// Fetches current weather data for the specified location.
    /// - Parameter location: The location to fetch weather for.
    /// - Returns: Current weather data.
    /// - Throws: WeatherError if the location is invalid or data is unavailable.
    func execute(location: Location) async throws -> WeatherData {
        guard location.isValid else {
            throw WeatherError.invalidCoordinates
        }

        Logger.info("Fetching current weather for \(location.name)")
        let weatherData = try await repository.fetchCurrentWeather(for: location)
        return weatherData
    }
}

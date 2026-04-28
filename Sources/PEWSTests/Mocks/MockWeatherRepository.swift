// MockWeatherRepository.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
@testable import PEWS

/// Mock implementation of WeatherRepositoryInterface for unit testing.
final class MockWeatherRepository: WeatherRepositoryInterface {

    // MARK: - Call Tracking

    var fetchCurrentWeatherCallCount = 0
    var fetchForecastCallCount = 0
    var fetchHistoricalWeatherCallCount = 0
    var invalidateCacheCallCount = 0

    // MARK: - Stubbed Responses

    var stubbedWeatherData: WeatherData?
    var stubbedForecasts: [Forecast] = []
    var stubbedHistoricalData: [WeatherData] = []
    var stubbedError: Error?

    // MARK: - Protocol Implementation

    func fetchCurrentWeather(for location: Location) async throws -> WeatherData {
        fetchCurrentWeatherCallCount += 1
        if let error = stubbedError { throw error }
        guard let data = stubbedWeatherData else {
            throw WeatherError.dataParsingFailed
        }
        return data
    }

    func fetchForecast(for location: Location) async throws -> [Forecast] {
        fetchForecastCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedForecasts
    }

    func fetchHistoricalWeather(
        for location: Location,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherData] {
        fetchHistoricalWeatherCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedHistoricalData
    }

    func invalidateCache(for location: Location) {
        invalidateCacheCallCount += 1
    }
}

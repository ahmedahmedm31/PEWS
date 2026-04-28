// MockWeatherAPIService.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
@testable import PEWS

/// Mock implementation of WeatherAPIServiceProtocol for unit testing.
final class MockWeatherAPIService: WeatherAPIServiceProtocol {

    // MARK: - Call Tracking

    var fetchCurrentWeatherCallCount = 0
    var fetchForecastCallCount = 0
    var fetchHistoricalWeatherCallCount = 0
    var searchLocationsCallCount = 0
    var reverseGeocodeCallCount = 0

    // MARK: - Stubbed Responses

    var stubbedCurrentWeather: CurrentWeatherResponseDTO?
    var stubbedForecast: ForecastResponseDTO?
    var stubbedHistoricalWeather: CurrentWeatherResponseDTO?
    var stubbedLocations: [GeocodingResponseDTO] = []
    var stubbedError: Error?

    // MARK: - Protocol Implementation

    func fetchCurrentWeather(request: WeatherRequestDTO) async throws -> CurrentWeatherResponseDTO {
        fetchCurrentWeatherCallCount += 1
        if let error = stubbedError { throw error }
        guard let response = stubbedCurrentWeather else {
            throw APIError.decodingFailed
        }
        return response
    }

    func fetchForecast(request: WeatherRequestDTO) async throws -> ForecastResponseDTO {
        fetchForecastCallCount += 1
        if let error = stubbedError { throw error }
        guard let response = stubbedForecast else {
            throw APIError.decodingFailed
        }
        return response
    }

    func fetchHistoricalWeather(request: HistoricalWeatherRequestDTO) async throws -> CurrentWeatherResponseDTO {
        fetchHistoricalWeatherCallCount += 1
        if let error = stubbedError { throw error }
        guard let response = stubbedHistoricalWeather else {
            throw APIError.decodingFailed
        }
        return response
    }

    func searchLocations(query: String) async throws -> [GeocodingResponseDTO] {
        searchLocationsCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedLocations
    }

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> [GeocodingResponseDTO] {
        reverseGeocodeCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedLocations
    }

    // MARK: - Reset

    func reset() {
        fetchCurrentWeatherCallCount = 0
        fetchForecastCallCount = 0
        fetchHistoricalWeatherCallCount = 0
        searchLocationsCallCount = 0
        reverseGeocodeCallCount = 0
        stubbedCurrentWeather = nil
        stubbedForecast = nil
        stubbedHistoricalWeather = nil
        stubbedLocations = []
        stubbedError = nil
    }
}

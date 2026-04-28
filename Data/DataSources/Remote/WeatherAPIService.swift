// WeatherAPIService.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol for the weather API service to enable testing with mocks.
protocol WeatherAPIServiceProtocol: Sendable {
    func fetchCurrentWeather(request: WeatherRequestDTO) async throws -> CurrentWeatherResponseDTO
    func fetchForecast(request: WeatherRequestDTO) async throws -> ForecastResponseDTO
    func fetchHistoricalWeather(request: HistoricalWeatherRequestDTO) async throws -> CurrentWeatherResponseDTO
    func searchLocations(query: String) async throws -> [GeocodingResponseDTO]
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> [GeocodingResponseDTO]
}

/// Handles all weather-related API calls, delegating HTTP communication
/// to a `NetworkClient` instance and routing each request to the correct endpoint.
final class WeatherAPIService: WeatherAPIServiceProtocol, @unchecked Sendable {

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // MARK: - Current Weather

    func fetchCurrentWeather(request: WeatherRequestDTO) async throws -> CurrentWeatherResponseDTO {
        Logger.network("Fetching current weather")
        let endpoint = Endpoint.currentWeather(request)
        let response: CurrentWeatherResponseDTO = try await networkClient.request(endpoint)
        Logger.network("Current weather fetched: \(response.name)")
        return response
    }

    // MARK: - Forecast

    func fetchForecast(request: WeatherRequestDTO) async throws -> ForecastResponseDTO {
        Logger.network("Fetching forecast")
        let endpoint = Endpoint.forecast(request)
        let response: ForecastResponseDTO = try await networkClient.request(endpoint)
        Logger.network("Forecast fetched: \(response.cnt) items")
        return response
    }

    // MARK: - Historical Weather

    func fetchHistoricalWeather(request: HistoricalWeatherRequestDTO) async throws -> CurrentWeatherResponseDTO {
        Logger.network("Fetching historical weather")
        let endpoint = Endpoint.historicalWeather(request)
        return try await networkClient.request(endpoint)
    }

    // MARK: - Geocoding

    func searchLocations(query: String) async throws -> [GeocodingResponseDTO] {
        Logger.network("Searching locations")
        let request = GeocodingRequestDTO(query: query)
        let endpoint = Endpoint.geocoding(request)
        let results: [GeocodingResponseDTO] = try await networkClient.request(endpoint)
        Logger.network("Found \(results.count) locations")
        return results
    }

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> [GeocodingResponseDTO] {
        Logger.network("Performing reverse geocode")
        let endpoint = Endpoint.reverseGeocoding(latitude: latitude, longitude: longitude)
        return try await networkClient.request(endpoint)
    }
}

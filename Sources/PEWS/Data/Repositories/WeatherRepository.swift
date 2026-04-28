// WeatherRepository.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Repository coordinating weather data from remote API and local cache.
/// Implements the WeatherRepositoryInterface protocol from the domain layer.
final class WeatherRepository: WeatherRepositoryInterface {

    // MARK: - Properties

    private let remoteDataSource: WeatherAPIServiceProtocol
    private let cacheManager: CacheManager

    // MARK: - Initialization

    init(
        remoteDataSource: WeatherAPIServiceProtocol,
        cacheManager: CacheManager
    ) {
        self.remoteDataSource = remoteDataSource
        self.cacheManager = cacheManager
    }

    // MARK: - Current Weather

    /// Fetches current weather for a location, using cache when available.
    /// - Parameter location: The location to fetch weather for.
    /// - Returns: Current weather data.
    func fetchCurrentWeather(for location: Location) async throws -> WeatherData {
        let cacheKey = "weather_current_\(location.latitude)_\(location.longitude)"

        // Check cache first
        if let cached: WeatherData = cacheManager.get(forKey: cacheKey) {
            Logger.data("Returning cached current weather for \(location.name)")
            return cached
        }

        // Fetch from API
        let request = WeatherRequestDTO(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let dto = try await remoteDataSource.fetchCurrentWeather(request: request)
        let weatherData = WeatherMapper.mapToDomain(dto)

        // Cache the result
        cacheManager.set(
            weatherData,
            forKey: cacheKey,
            ttl: AppConfig.CacheDuration.currentWeather
        )

        return weatherData
    }

    // MARK: - Forecast

    /// Fetches forecast data for a location, using cache when available.
    /// - Parameter location: The location to fetch forecast for.
    /// - Returns: Array of daily forecasts.
    func fetchForecast(for location: Location) async throws -> [Forecast] {
        let cacheKey = "weather_forecast_\(location.latitude)_\(location.longitude)"

        // Check cache first
        if let cached: [Forecast] = cacheManager.get(forKey: cacheKey) {
            Logger.data("Returning cached forecast for \(location.name)")
            return cached
        }

        // Fetch from API
        let request = WeatherRequestDTO(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let dto = try await remoteDataSource.fetchForecast(request: request)
        let forecasts = ForecastMapper.mapToDomain(dto)

        // Cache the result
        cacheManager.set(
            forecasts,
            forKey: cacheKey,
            ttl: AppConfig.CacheDuration.forecast
        )

        return forecasts
    }

    // MARK: - Historical Weather

    /// Fetches historical weather data for a location and date range.
    /// - Parameters:
    ///   - location: The location to fetch historical data for.
    ///   - startDate: The start date of the range.
    ///   - endDate: The end date of the range.
    /// - Returns: Array of historical weather data points.
    func fetchHistoricalWeather(
        for location: Location,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherData] {
        let cacheKey = "weather_history_\(location.latitude)_\(location.longitude)_\(startDate.unixTimestamp)_\(endDate.unixTimestamp)"

        // Check cache first
        if let cached: [WeatherData] = cacheManager.get(forKey: cacheKey) {
            Logger.data("Returning cached historical weather for \(location.name)")
            return cached
        }

        // Fetch day by day
        var results: [WeatherData] = []
        var currentDate = startDate
        let calendar = Calendar.current

        while currentDate <= endDate {
            let request = HistoricalWeatherRequestDTO(
                latitude: location.latitude,
                longitude: location.longitude,
                date: currentDate
            )

            do {
                let dto = try await remoteDataSource.fetchHistoricalWeather(request: request)
                let weatherData = WeatherMapper.mapToDomain(dto)
                results.append(weatherData)
            } catch {
                Logger.warning("Failed to fetch historical data for \(currentDate): \(error.localizedDescription)")
            }

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        // Cache the result
        if !results.isEmpty {
            cacheManager.set(
                results,
                forKey: cacheKey,
                ttl: AppConfig.CacheDuration.historicalData
            )
        }

        return results
    }

    // MARK: - Cache Management

    /// Forces a refresh by clearing the cache for a location.
    func invalidateCache(for location: Location) {
        let currentKey = "weather_current_\(location.latitude)_\(location.longitude)"
        let forecastKey = "weather_forecast_\(location.latitude)_\(location.longitude)"
        cacheManager.remove(forKey: currentKey)
        cacheManager.remove(forKey: forecastKey)
        Logger.data("Cache invalidated for \(location.name)")
    }

    func refresh() async throws {
        cacheManager.clearAll()
    }
}

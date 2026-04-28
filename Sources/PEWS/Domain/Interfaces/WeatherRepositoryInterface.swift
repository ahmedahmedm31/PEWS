// WeatherRepositoryInterface.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol defining the contract for weather data access.
/// Implemented by WeatherRepository in the data layer.
protocol WeatherRepositoryInterface: AnyObject {
    /// Fetches current weather data for a location.
    func fetchCurrentWeather(for location: Location) async throws -> WeatherData

    /// Fetches forecast data for a location.
    func fetchForecast(for location: Location) async throws -> [Forecast]

    /// Fetches historical weather data for a location and date range.
    func fetchHistoricalWeather(
        for location: Location,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [WeatherData]

    /// Invalidates cached data for a location.
    func invalidateCache(for location: Location)
}

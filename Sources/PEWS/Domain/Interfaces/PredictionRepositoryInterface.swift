// PredictionRepositoryInterface.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol defining the contract for prediction data access.
/// Implemented by PredictionRepository in the data layer.
protocol PredictionRepositoryInterface: AnyObject {
    /// Generates a crisis prediction for the given weather data.
    func predictCrisis(for weatherData: WeatherData) async throws -> Prediction

    /// Generates predictions for a timeline based on forecast data.
    func predictTimeline(
        for location: Location,
        using forecasts: [Forecast]
    ) async throws -> [Prediction]
}

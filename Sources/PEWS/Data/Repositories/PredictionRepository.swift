// PredictionRepository.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Repository coordinating prediction data from ML engine and weather data.
/// Implements the PredictionRepositoryInterface protocol from the domain layer.
final class PredictionRepository: PredictionRepositoryInterface {

    // MARK: - Properties

    private let predictionEngine: PredictionEngine
    private let weatherRepository: WeatherRepository

    // MARK: - Initialization

    init(
        predictionEngine: PredictionEngine,
        weatherRepository: WeatherRepository
    ) {
        self.predictionEngine = predictionEngine
        self.weatherRepository = weatherRepository
    }

    // MARK: - Predict

    /// Generates a crisis prediction for the given weather data.
    /// - Parameter weatherData: Current weather data to analyze.
    /// - Returns: A Prediction domain entity.
    func predictCrisis(for weatherData: WeatherData) async throws -> Prediction {
        Logger.ml("Generating prediction for \(weatherData.location.name)")

        let features = FeatureExtractor.extractFeatures(from: weatherData)
        let result = try await predictionEngine.predict(features: features)

        let prediction = Prediction(
            id: UUID().uuidString,
            locationID: weatherData.location.id,
            locationName: weatherData.location.name,
            crisisProbability: result.crisisProbability,
            confidence: result.confidence,
            riskScore: Int(result.crisisProbability * 100),
            riskLevel: RiskLevel.fromScore(Int(result.crisisProbability * 100)),
            contributingFactors: identifyContributingFactors(from: weatherData),
            timestamp: Date(),
            validUntil: Date().addingTimeInterval(TimeInterval(AppConfig.DataConstraints.predictionHorizonHours * 3600))
        )

        Logger.ml("Prediction: risk=\(prediction.riskScore), confidence=\(result.confidence)")
        return prediction
    }

    /// Generates predictions for the next 48 hours based on forecast data.
    /// - Parameters:
    ///   - location: The location to predict for.
    ///   - forecasts: The forecast data to use.
    /// - Returns: Array of Prediction entities.
    func predictTimeline(
        for location: Location,
        using forecasts: [Forecast]
    ) async throws -> [Prediction] {
        var predictions: [Prediction] = []

        for forecast in forecasts {
            for hourlyItem in forecast.hourlyItems {
                let features = FeatureExtractor.extractFeaturesFromForecast(hourlyItem)
                let result = try await predictionEngine.predict(features: features)

                let prediction = Prediction(
                    id: UUID().uuidString,
                    locationID: location.id,
                    locationName: location.name,
                    crisisProbability: result.crisisProbability,
                    confidence: result.confidence,
                    riskScore: Int(result.crisisProbability * 100),
                    riskLevel: RiskLevel.fromScore(Int(result.crisisProbability * 100)),
                    contributingFactors: [],
                    timestamp: hourlyItem.time,
                    validUntil: hourlyItem.time.addingTimeInterval(3600)
                )

                predictions.append(prediction)
            }
        }

        return predictions.sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Refresh

    func refresh() async throws {
        // Predictions are computed on-demand
    }

    // MARK: - Private Helpers

    private func identifyContributingFactors(from weather: WeatherData) -> [ContributingFactor] {
        var factors: [ContributingFactor] = []

        // Temperature extremes
        if weather.temperature > 35 {
            factors.append(ContributingFactor(
                name: "Extreme Heat",
                description: "Temperature exceeds 35°C",
                severity: .high,
                value: weather.temperature,
                unit: "°C"
            ))
        } else if weather.temperature < -10 {
            factors.append(ContributingFactor(
                name: "Extreme Cold",
                description: "Temperature below -10°C",
                severity: .high,
                value: weather.temperature,
                unit: "°C"
            ))
        }

        // High wind
        if weather.windSpeed > 20 {
            factors.append(ContributingFactor(
                name: "High Wind",
                description: "Wind speed exceeds 20 m/s",
                severity: weather.windSpeed > 30 ? .critical : .high,
                value: weather.windSpeed,
                unit: "m/s"
            ))
        }

        // Heavy precipitation
        if weather.precipitation > 10 {
            factors.append(ContributingFactor(
                name: "Heavy Precipitation",
                description: "Precipitation exceeds 10mm/h",
                severity: weather.precipitation > 25 ? .critical : .high,
                value: weather.precipitation,
                unit: "mm/h"
            ))
        }

        // Low pressure
        if weather.pressure < 980 {
            factors.append(ContributingFactor(
                name: "Low Pressure",
                description: "Atmospheric pressure below 980 hPa",
                severity: .moderate,
                value: weather.pressure,
                unit: "hPa"
            ))
        }

        // Low visibility
        if weather.visibility < 1000 {
            factors.append(ContributingFactor(
                name: "Low Visibility",
                description: "Visibility below 1km",
                severity: .high,
                value: weather.visibility,
                unit: "m"
            ))
        }

        // High humidity
        if weather.humidity > 90 {
            factors.append(ContributingFactor(
                name: "High Humidity",
                description: "Humidity exceeds 90%",
                severity: .low,
                value: weather.humidity,
                unit: "%"
            ))
        }

        return factors
    }
}

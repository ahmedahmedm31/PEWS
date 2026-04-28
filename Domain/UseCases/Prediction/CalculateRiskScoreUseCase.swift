// CalculateRiskScoreUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for calculating risk scores from weather data using a rule-based algorithm.
/// This serves as a fallback when the ML model is unavailable and as a validation tool.
final class CalculateRiskScoreUseCase {

    // MARK: - Weight Configuration

    private struct Weights {
        static let temperature: Double = 0.20
        static let wind: Double = 0.20
        static let precipitation: Double = 0.15
        static let pressure: Double = 0.15
        static let visibility: Double = 0.10
        static let humidity: Double = 0.10
        static let cloudCoverage: Double = 0.05
        static let uvIndex: Double = 0.05
    }

    // MARK: - Execute

    /// Calculates a risk score (0-100) from weather data.
    /// - Parameter weatherData: The weather data to analyze.
    /// - Returns: An integer risk score from 0 to 100.
    func execute(weatherData: WeatherData) -> Int {
        var totalRisk: Double = 0

        // Temperature risk (extreme heat or cold)
        let tempRisk = calculateTemperatureRisk(weatherData.temperature)
        totalRisk += tempRisk * Weights.temperature

        // Wind risk
        let windRisk = calculateWindRisk(weatherData.windSpeed)
        totalRisk += windRisk * Weights.wind

        // Precipitation risk
        let precipRisk = calculatePrecipitationRisk(weatherData.precipitation)
        totalRisk += precipRisk * Weights.precipitation

        // Pressure risk (low pressure = storm potential)
        let pressureRisk = calculatePressureRisk(weatherData.pressure)
        totalRisk += pressureRisk * Weights.pressure

        // Visibility risk
        let visibilityRisk = calculateVisibilityRisk(weatherData.visibility)
        totalRisk += visibilityRisk * Weights.visibility

        // Humidity risk
        let humidityRisk = calculateHumidityRisk(weatherData.humidity)
        totalRisk += humidityRisk * Weights.humidity

        // Cloud coverage risk
        let cloudRisk = calculateCloudRisk(weatherData.cloudCoverage)
        totalRisk += cloudRisk * Weights.cloudCoverage

        // UV Index risk
        let uvRisk = calculateUVRisk(weatherData.uvIndex)
        totalRisk += uvRisk * Weights.uvIndex

        // Condition multiplier for severe weather
        let conditionMultiplier = weatherConditionMultiplier(weatherData.condition)
        totalRisk *= conditionMultiplier

        let score = Int((totalRisk * 100).clamped(to: 0...100))
        Logger.info("Risk score calculated: \(score) for \(weatherData.location.name)")
        return score
    }

    // MARK: - Individual Risk Calculations

    private func calculateTemperatureRisk(_ temp: Double) -> Double {
        switch temp {
        case ...(-20): return 1.0
        case -20...(-10): return 0.7
        case -10...0: return 0.3
        case 0...35: return 0.0
        case 35...40: return 0.5
        case 40...45: return 0.8
        default: return 1.0
        }
    }

    private func calculateWindRisk(_ speed: Double) -> Double {
        switch speed {
        case 0...10: return 0.0
        case 10...15: return 0.2
        case 15...20: return 0.4
        case 20...25: return 0.6
        case 25...30: return 0.8
        default: return 1.0
        }
    }

    private func calculatePrecipitationRisk(_ amount: Double) -> Double {
        switch amount {
        case 0...2: return 0.0
        case 2...5: return 0.2
        case 5...10: return 0.4
        case 10...20: return 0.7
        case 20...30: return 0.9
        default: return 1.0
        }
    }

    private func calculatePressureRisk(_ pressure: Double) -> Double {
        switch pressure {
        case ...960: return 1.0
        case 960...970: return 0.8
        case 970...980: return 0.6
        case 980...990: return 0.3
        case 990...1000: return 0.1
        default: return 0.0
        }
    }

    private func calculateVisibilityRisk(_ visibility: Double) -> Double {
        switch visibility {
        case 0...200: return 1.0
        case 200...500: return 0.8
        case 500...1000: return 0.6
        case 1000...3000: return 0.3
        case 3000...5000: return 0.1
        default: return 0.0
        }
    }

    private func calculateHumidityRisk(_ humidity: Double) -> Double {
        switch humidity {
        case 0...30: return 0.1
        case 30...60: return 0.0
        case 60...80: return 0.1
        case 80...90: return 0.3
        case 90...95: return 0.5
        default: return 0.7
        }
    }

    private func calculateCloudRisk(_ coverage: Double) -> Double {
        coverage > 90 ? 0.3 : 0.0
    }

    private func calculateUVRisk(_ uvIndex: Double) -> Double {
        switch uvIndex {
        case 0...5: return 0.0
        case 5...8: return 0.3
        case 8...11: return 0.6
        default: return 1.0
        }
    }

    /// Maps WeatherCondition to a risk multiplier. Severe conditions amplify the score.
    private func weatherConditionMultiplier(_ condition: WeatherCondition) -> Double {
        switch condition {
        case .thunderstorm:  return 1.5
        case .snow:          return 1.3
        case .fog:           return 1.2
        case .mist:          return 1.15
        case .rain:          return 1.1
        case .drizzle:       return 1.0
        case .overcast:      return 1.0
        case .partlyCloudy:  return 1.0
        case .clear:         return 1.0
        case .unknown:       return 1.0
        }
    }
}

// FeatureExtractor.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Extracted weather features for ML model input.
struct WeatherFeatures: Sendable {
    // Raw measurements
    let temperature: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windDirection: Double
    let cloudCoverage: Double
    let visibility: Double
    let precipitation: Double

    // Derived features (rate of change)
    let tempChange: Double
    let pressureChange: Double
    let humidityChange: Double
    let windSpeedChange: Double

    // Computed features
    let dewPoint: Double
    let heatIndex: Double
    let windChill: Double

    /// Returns all features as a dictionary for ML input.
    var featureDict: [String: Double] {
        [
            "temperature": temperature,
            "humidity": humidity,
            "pressure": pressure,
            "windSpeed": windSpeed,
            "windDirection": windDirection,
            "cloudCoverage": cloudCoverage,
            "visibility": visibility,
            "precipitation": precipitation,
            "tempChange": tempChange,
            "pressureChange": pressureChange,
            "humidityChange": humidityChange,
            "windSpeedChange": windSpeedChange,
            "dewPoint": dewPoint,
            "heatIndex": heatIndex,
            "windChill": windChill
        ]
    }

    /// Returns features as an array for model input (ordered).
    var featureArray: [Double] {
        [
            temperature, humidity, pressure, windSpeed, windDirection,
            cloudCoverage, visibility, precipitation,
            tempChange, pressureChange, humidityChange, windSpeedChange,
            dewPoint, heatIndex, windChill
        ]
    }
}

/// Extracts and normalizes weather features from domain entities for ML model input.
enum FeatureExtractor {

    // MARK: - Feature Extraction

    /// Extracts features from current weather data.
    /// - Parameter weatherData: The current weather data.
    /// - Returns: Normalized weather features for ML input.
    static func extractFeatures(from weatherData: WeatherData) -> WeatherFeatures {
        let dewPoint = calculateDewPoint(
            temperature: weatherData.temperature,
            humidity: weatherData.humidity
        )

        let heatIndex = calculateHeatIndex(
            temperature: weatherData.temperature,
            humidity: weatherData.humidity
        )

        let windChill = calculateWindChill(
            temperature: weatherData.temperature,
            windSpeed: weatherData.windSpeed
        )

        return WeatherFeatures(
            temperature: normalize(weatherData.temperature, min: -40, max: 50),
            humidity: normalize(weatherData.humidity, min: 0, max: 100),
            pressure: normalize(weatherData.pressure, min: 950, max: 1050),
            windSpeed: normalize(weatherData.windSpeed, min: 0, max: 50),
            windDirection: normalize(weatherData.windDirection, min: 0, max: 360),
            cloudCoverage: normalize(weatherData.cloudCoverage, min: 0, max: 100),
            visibility: normalize(weatherData.visibility, min: 0, max: 20000),
            precipitation: normalize(weatherData.precipitation, min: 0, max: 50),
            tempChange: 0, // Requires historical data
            pressureChange: 0,
            humidityChange: 0,
            windSpeedChange: 0,
            dewPoint: normalize(dewPoint, min: -40, max: 40),
            heatIndex: normalize(heatIndex, min: -40, max: 60),
            windChill: normalize(windChill, min: -60, max: 50)
        )
    }

    /// Extracts features from a forecast hourly item.
    /// - Parameter item: The forecast hourly item.
    /// - Returns: Normalized weather features for ML input.
    static func extractFeaturesFromForecast(_ item: ForecastHourlyItem) -> WeatherFeatures {
        let dewPoint = calculateDewPoint(
            temperature: item.temperature,
            humidity: item.humidity
        )

        let heatIndex = calculateHeatIndex(
            temperature: item.temperature,
            humidity: item.humidity
        )

        let windChill = calculateWindChill(
            temperature: item.temperature,
            windSpeed: item.windSpeed
        )

        return WeatherFeatures(
            temperature: normalize(item.temperature, min: -40, max: 50),
            humidity: normalize(item.humidity, min: 0, max: 100),
            pressure: normalize(item.pressure, min: 950, max: 1050),
            windSpeed: normalize(item.windSpeed, min: 0, max: 50),
            windDirection: 0,
            cloudCoverage: normalize(item.cloudCoverage, min: 0, max: 100),
            visibility: 1.0, // Not available in forecast
            precipitation: normalize(item.precipitationProbability * 10, min: 0, max: 50),
            tempChange: 0,
            pressureChange: 0,
            humidityChange: 0,
            windSpeedChange: 0,
            dewPoint: normalize(dewPoint, min: -40, max: 40),
            heatIndex: normalize(heatIndex, min: -40, max: 60),
            windChill: normalize(windChill, min: -60, max: 50)
        )
    }

    /// Extracts features with rate-of-change from a sequence of weather data.
    /// - Parameter history: Array of historical weather data points (oldest first).
    /// - Returns: Features including rate-of-change calculations.
    static func extractFeaturesWithHistory(
        current: WeatherData,
        history: [WeatherData]
    ) -> WeatherFeatures {
        let baseFeatures = extractFeatures(from: current)

        guard let previous = history.last else {
            return baseFeatures
        }

        let timeDelta = current.timestamp.timeIntervalSince(previous.timestamp) / 3600 // hours
        guard timeDelta > 0 else { return baseFeatures }

        let tempChange = (current.temperature - previous.temperature) / timeDelta
        let pressureChange = (current.pressure - previous.pressure) / timeDelta
        let humidityChange = (current.humidity - previous.humidity) / timeDelta
        let windSpeedChange = (current.windSpeed - previous.windSpeed) / timeDelta

        return WeatherFeatures(
            temperature: baseFeatures.temperature,
            humidity: baseFeatures.humidity,
            pressure: baseFeatures.pressure,
            windSpeed: baseFeatures.windSpeed,
            windDirection: baseFeatures.windDirection,
            cloudCoverage: baseFeatures.cloudCoverage,
            visibility: baseFeatures.visibility,
            precipitation: baseFeatures.precipitation,
            tempChange: normalize(tempChange, min: -10, max: 10),
            pressureChange: normalize(pressureChange, min: -10, max: 10),
            humidityChange: normalize(humidityChange, min: -20, max: 20),
            windSpeedChange: normalize(windSpeedChange, min: -15, max: 15),
            dewPoint: baseFeatures.dewPoint,
            heatIndex: baseFeatures.heatIndex,
            windChill: baseFeatures.windChill
        )
    }

    // MARK: - Normalization

    /// Normalizes a value to the 0-1 range using min-max scaling.
    static func normalize(_ value: Double, min: Double, max: Double) -> Double {
        guard max > min else { return 0 }
        return Swift.max(0, Swift.min(1, (value - min) / (max - min)))
    }

    // MARK: - Derived Feature Calculations

    /// Calculates the dew point temperature using the Magnus formula.
    static func calculateDewPoint(temperature: Double, humidity: Double) -> Double {
        let a: Double = 17.27
        let b: Double = 237.7
        let alpha = (a * temperature) / (b + temperature) + log(humidity / 100.0)
        return (b * alpha) / (a - alpha)
    }

    /// Calculates the heat index (apparent temperature in hot conditions).
    static func calculateHeatIndex(temperature: Double, humidity: Double) -> Double {
        // Only applicable above 27°C
        guard temperature >= 27 else { return temperature }

        let t = temperature
        let h = humidity

        let heatIndex = -8.78469475556 +
            1.61139411 * t +
            2.33854883889 * h +
            -0.14611605 * t * h +
            -0.012308094 * t * t +
            -0.0164248277778 * h * h +
            0.002211732 * t * t * h +
            0.00072546 * t * h * h +
            -0.000003582 * t * t * h * h

        return heatIndex
    }

    /// Calculates the wind chill temperature.
    static func calculateWindChill(temperature: Double, windSpeed: Double) -> Double {
        // Only applicable below 10°C and wind > 4.8 km/h
        let windKmh = windSpeed * 3.6
        guard temperature <= 10 && windKmh > 4.8 else { return temperature }

        return 13.12 + 0.6215 * temperature -
            11.37 * pow(windKmh, 0.16) +
            0.3965 * temperature * pow(windKmh, 0.16)
    }
}

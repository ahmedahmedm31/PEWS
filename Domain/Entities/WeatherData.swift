// WeatherData.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Core domain entity representing current weather conditions for a location.
struct WeatherData: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let location: Location
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windDirection: Double
    let windGust: Double?
    let cloudCoverage: Double
    let visibility: Double
    let precipitation: Double
    let uvIndex: Double
    let condition: WeatherCondition
    let iconCode: String
    let sunrise: Date
    let sunset: Date
    let timestamp: Date
    let timezone: Int

    /// SF Symbol icon name derived from the current condition and time of day.
    var iconName: String {
        condition.iconName(isNight: Date() > sunset || Date() < sunrise)
    }

    /// Human-readable description of the weather condition.
    var conditionDescription: String {
        condition.description
    }

    /// Whether the data is still considered fresh based on cache duration.
    var isFresh: Bool {
        timestamp.isWithinMinutes(Int(AppConfig.CacheDuration.currentWeather / 60))
    }
}

// MARK: - Weather Condition

enum WeatherCondition: String, Codable, CaseIterable, Sendable {
    case clear
    case partlyCloudy
    case overcast
    case rain
    case drizzle
    case thunderstorm
    case snow
    case mist
    case fog
    case unknown

    var description: String {
        switch self {
        case .clear: return "Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .overcast: return "Overcast"
        case .rain: return "Rainy"
        case .drizzle: return "Drizzle"
        case .thunderstorm: return "Thunderstorm"
        case .snow: return "Snow"
        case .mist: return "Mist"
        case .fog: return "Fog"
        case .unknown: return "Unknown"
        }
    }

    var conditionID: Int {
        switch self {
        case .clear: return 800
        case .partlyCloudy: return 801
        case .overcast: return 804
        case .rain: return 500
        case .drizzle: return 300
        case .thunderstorm: return 200
        case .snow: return 600
        case .mist: return 701
        case .fog: return 741
        case .unknown: return 0
        }
    }

    func iconName(isNight: Bool) -> String {
        switch self {
        case .clear:
            return isNight ? "moon.stars.fill" : "sun.max.fill"
        case .partlyCloudy:
            return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        case .overcast:
            return "cloud.fill"
        case .rain:
            return "cloud.rain.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .mist, .fog:
            return "cloud.fog.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }
}

// MARK: - Mock Data

#if DEBUG
extension WeatherData: Mockable {
    static func mock() -> WeatherData {
        WeatherData(
            id: UUID().uuidString,
            location: Location.mock(),
            temperature: 15.5,
            feelsLike: 14.2,
            tempMin: 13.0,
            tempMax: 17.0,
            humidity: 72,
            pressure: 1013,
            windSpeed: 5.2,
            windDirection: 230,
            windGust: 8.1,
            cloudCoverage: 40,
            visibility: 10000,
            precipitation: 0,
            uvIndex: 3,
            condition: .partlyCloudy,
            iconCode: "03d",
            sunrise: Date().addingTimeInterval(-3600),
            sunset: Date().addingTimeInterval(3600),
            timestamp: Date(),
            timezone: 0
        )
    }

    static func mockExtreme() -> WeatherData {
        WeatherData(
            id: UUID().uuidString,
            location: Location.mock(),
            temperature: 42.0,
            feelsLike: 45.0,
            tempMin: 38.0,
            tempMax: 44.0,
            humidity: 95,
            pressure: 970,
            windSpeed: 35.0,
            windDirection: 180,
            windGust: 50.0,
            cloudCoverage: 100,
            visibility: 500,
            precipitation: 30,
            uvIndex: 11,
            condition: .thunderstorm,
            iconCode: "11d",
            sunrise: Date().addingTimeInterval(-3600),
            sunset: Date().addingTimeInterval(3600),
            timestamp: Date(),
            timezone: 0
        )
    }
}
#endif

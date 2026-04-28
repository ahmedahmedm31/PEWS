// WeatherRequestDTO.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Data transfer object for weather API requests.
struct WeatherRequestDTO: Sendable {
    let latitude: Double
    let longitude: Double
    let units: String
    let language: String

    init(
        latitude: Double,
        longitude: Double,
        units: String = "metric",
        language: String = "en"
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.units = units
        self.language = language
    }

    /// URL query parameters. Coordinates use a POSIX-locale formatter so that
    /// a period is always used as the decimal separator regardless of device locale.
    var queryParameters: [String: String] {
        [
            "lat": CoordinateFormatter.format(latitude),
            "lon": CoordinateFormatter.format(longitude),
            "units": units,
            "lang": language,
            "appid": APIKeys.openWeatherMapKey
        ]
    }
}

/// Data transfer object for geocoding API requests.
struct GeocodingRequestDTO: Sendable {
    let query: String
    let limit: Int

    init(query: String, limit: Int = 5) {
        self.query = query
        self.limit = limit
    }

    var queryParameters: [String: String] {
        [
            "q": query,
            "limit": String(limit),
            "appid": APIKeys.openWeatherMapKey
        ]
    }
}

/// Data transfer object for historical weather API requests.
struct HistoricalWeatherRequestDTO: Sendable {
    let latitude: Double
    let longitude: Double
    let timestamp: Int
    let units: String

    init(
        latitude: Double,
        longitude: Double,
        date: Date,
        units: String = "metric"
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Int(date.timeIntervalSince1970)
        self.units = units
    }

    var queryParameters: [String: String] {
        [
            "lat": CoordinateFormatter.format(latitude),
            "lon": CoordinateFormatter.format(longitude),
            "dt": String(timestamp),
            "units": units,
            "appid": APIKeys.openWeatherMapKey
        ]
    }
}

/// Shared locale-safe coordinate formatter used by all request DTOs.
enum CoordinateFormatter {
    private static let formatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.minimumFractionDigits = 4
        fmt.maximumFractionDigits = 4
        return fmt
    }()

    static func format(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// TestData.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
@testable import PEWS

// MARK: - WeatherData Test Factory

enum TestWeatherData {
    static func normal() -> WeatherData {
        WeatherData(
            id: UUID().uuidString,
            location: TestLocations.london(),
            temperature: 15.5,
            feelsLike: 14.2,
            tempMin: 13.0,
            tempMax: 17.0,
            humidity: 65,
            pressure: 1013,
            windSpeed: 5.2,
            windDirection: 180,
            windGust: nil,
            cloudCoverage: 30,
            visibility: 10000,
            precipitation: 0,
            uvIndex: 3,
            condition: .clear,
            iconCode: "01d",
            sunrise: Date(),
            sunset: Date().addingTimeInterval(43200),
            timestamp: Date(),
            timezone: 0
        )
    }

    static func extreme() -> WeatherData {
        WeatherData(
            id: UUID().uuidString,
            location: TestLocations.london(),
            temperature: 42,
            feelsLike: 48,
            tempMin: 38,
            tempMax: 44,
            humidity: 95,
            pressure: 965,
            windSpeed: 35,
            windDirection: 270,
            windGust: 50,
            cloudCoverage: 100,
            visibility: 500,
            precipitation: 25,
            uvIndex: 0,
            condition: .thunderstorm,
            iconCode: "11d",
            sunrise: Date(),
            sunset: Date().addingTimeInterval(43200),
            timestamp: Date(),
            timezone: 0
        )
    }
}

// MARK: - Location Test Factory

enum TestLocations {
    static func london() -> Location {
        Location(
            id: "mock_london",
            name: "London",
            latitude: 51.5085,
            longitude: -0.1257,
            country: "GB",
            state: "England",
            isDefault: true
        )
    }

    static func dublin() -> Location {
        Location(
            id: "mock_dublin",
            name: "Dublin",
            latitude: 53.3498,
            longitude: -6.2603,
            country: "IE",
            state: "Leinster",
            isDefault: false
        )
    }
}

// MARK: - Prediction Test Factory

enum TestPredictions {
    static func lowRisk() -> Prediction {
        Prediction(
            id: UUID().uuidString,
            locationID: "mock_london",
            locationName: "London",
            crisisProbability: 0.15,
            confidence: 0.82,
            riskScore: 25,
            riskLevel: .low,
            contributingFactors: [
                ContributingFactor(
                    name: "Temperature",
                    description: "Normal range",
                    severity: .low,
                    value: 15.5,
                    unit: "°C"
                ),
                ContributingFactor(
                    name: "Wind",
                    description: "Light breeze",
                    severity: .low,
                    value: 5.2,
                    unit: "m/s"
                ),
                ContributingFactor(
                    name: "Pressure",
                    description: "Stable",
                    severity: .low,
                    value: 1013,
                    unit: "hPa"
                )
            ],
            timestamp: Date(),
            validUntil: Date().addingTimeInterval(3600)
        )
    }

    static func highRisk() -> Prediction {
        Prediction(
            id: UUID().uuidString,
            locationID: "mock_london",
            locationName: "London",
            crisisProbability: 0.85,
            confidence: 0.91,
            riskScore: 85,
            riskLevel: .critical,
            contributingFactors: [
                ContributingFactor(
                    name: "Extreme Heat",
                    description: "Temperature exceeds 35°C",
                    severity: .critical,
                    value: 42.0,
                    unit: "°C"
                ),
                ContributingFactor(
                    name: "High Wind",
                    description: "Wind speed exceeds 30 m/s",
                    severity: .critical,
                    value: 35.0,
                    unit: "m/s"
                )
            ],
            timestamp: Date(),
            validUntil: Date().addingTimeInterval(3600)
        )
    }
}

// MARK: - Alert Test Factory

enum TestAlerts {
    static func moderate(isRead: Bool = false) -> Alert {
        Alert(
            id: UUID().uuidString,
            locationID: "mock_london",
            locationName: "London",
            riskScore: 65,
            riskLevel: .moderate,
            title: "Moderate Risk: London",
            message: "Risk score has reached 65/100. Monitor conditions closely.",
            timestamp: Date(),
            isRead: isRead,
            isAcknowledged: false
        )
    }

    static func critical() -> Alert {
        Alert(
            id: UUID().uuidString,
            locationID: "mock_london",
            locationName: "London",
            riskScore: 90,
            riskLevel: .critical,
            title: "Critical Risk: London",
            message: "Risk score has reached 90/100. Take immediate action.",
            timestamp: Date(),
            isRead: false,
            isAcknowledged: false
        )
    }
}

// MARK: - Forecast Test Factory

enum TestForecasts {
    static func normal() -> Forecast {
        Forecast(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(3600),
            tempMin: 14.0,
            tempMax: 18.0,
            tempAverage: 16.0,
            humidity: 60,
            pressure: 1012,
            windSpeed: 4.5,
            windDirection: 200,
            cloudCoverage: 40,
            precipitationProbability: 0.2,
            precipitationAmount: 0,
            condition: .partlyCloudy,
            iconCode: "02d",
            conditionDescription: "Partly cloudy",
            hourlyItems: [
                ForecastHourlyItem(
                    time: Date().addingTimeInterval(3600),
                    temperature: 16.0,
                    feelsLike: 15.5,
                    humidity: 60,
                    pressure: 1012,
                    windSpeed: 4.5,
                    cloudCoverage: 40,
                    precipitationProbability: 0.2,
                    condition: .partlyCloudy,
                    iconCode: "02d"
                )
            ]
        )
    }
}

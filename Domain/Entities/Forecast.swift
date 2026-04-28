// Forecast.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Domain entity representing a daily weather forecast.
struct Forecast: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let date: Date
    let tempMin: Double
    let tempMax: Double
    let tempAverage: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windDirection: Double
    let cloudCoverage: Double
    let precipitationProbability: Double
    let precipitationAmount: Double
    let condition: WeatherCondition
    let iconCode: String
    let conditionDescription: String
    let hourlyItems: [ForecastHourlyItem]

    var dayOfWeek: String {
        date.dayOfWeekAbbreviation
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(date)
    }

    var dayLabel: String {
        if isToday { return "Today" }
        if isTomorrow { return "Tomorrow" }
        return dayOfWeek
    }
}

/// Hourly forecast item within a daily forecast.
struct ForecastHourlyItem: Identifiable, Codable, Equatable, Sendable {
    var id: String { "\(time.timeIntervalSince1970)" }
    let time: Date
    let temperature: Double
    let feelsLike: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let cloudCoverage: Double
    let precipitationProbability: Double
    let condition: WeatherCondition
    let iconCode: String
}

// MARK: - Mock Data

#if DEBUG
extension Forecast: Mockable {
    static func mock() -> Forecast {
        let now = Date()
        return Forecast(
            id: UUID().uuidString,
            date: now,
            tempMin: 12.0,
            tempMax: 18.0,
            tempAverage: 15.0,
            humidity: 65,
            pressure: 1015,
            windSpeed: 4.5,
            windDirection: 200,
            cloudCoverage: 50,
            precipitationProbability: 0.3,
            precipitationAmount: 2.0,
            condition: .partlyCloudy,
            iconCode: "03d",
            conditionDescription: "Scattered clouds",
            hourlyItems: (0..<8).map { i in
                ForecastHourlyItem(
                    time: now.addingTimeInterval(TimeInterval(i * 3600)),
                    temperature: 14.0 + Double(i) * 0.5,
                    feelsLike: 13.0 + Double(i) * 0.5,
                    humidity: 60 + Double(i * 2),
                    pressure: 1015,
                    windSpeed: 4.0 + Double(i) * 0.3,
                    cloudCoverage: 40 + Double(i * 5),
                    precipitationProbability: 0.1 * Double(i),
                    condition: .partlyCloudy,
                    iconCode: "03d"
                )
            }
        )
    }

    static func mockWeek() -> [Forecast] {
        (0..<7).map { day in
            let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
            let conditions: [WeatherCondition] = [.clear, .partlyCloudy, .rain]
            let icons = ["01d", "03d", "10d"]
            let descriptions = ["Clear sky", "Partly cloudy", "Rain"]
            let index = day % 3
            return Forecast(
                id: UUID().uuidString,
                date: date,
                tempMin: 10.0 + Double(day),
                tempMax: 18.0 + Double(day),
                tempAverage: 14.0 + Double(day),
                humidity: 60 + Double(day * 3),
                pressure: 1010 + Double(day),
                windSpeed: 3.0 + Double(day) * 0.5,
                windDirection: Double(day * 30),
                cloudCoverage: Double(day * 10),
                precipitationProbability: Double(day) * 0.1,
                precipitationAmount: Double(day) * 0.5,
                condition: conditions[index],
                iconCode: icons[index],
                conditionDescription: descriptions[index],
                hourlyItems: []
            )
        }
    }
}
#endif

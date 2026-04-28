// ForecastMapper.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Maps forecast API response DTOs to domain entities.
enum ForecastMapper {

    /// Maps a ForecastResponseDTO to an array of Forecast domain entities.
    /// Groups 3-hour intervals into daily forecasts.
    /// - Parameter dto: The API response DTO.
    /// - Returns: An array of daily Forecast domain entities.
    static func mapToDomain(_ dto: ForecastResponseDTO) -> [Forecast] {
        let grouped = groupByDay(dto.list)

        return grouped.compactMap { (date, items) -> Forecast? in
            guard !items.isEmpty else { return nil }

            let temps = items.map(\.main.temp)
            let humidities = items.map { Double($0.main.humidity) }
            let pressures = items.map { Double($0.main.pressure) }
            let windSpeeds = items.map(\.wind.speed)
            let pops = items.map(\.pop)
            let conditions = items.compactMap(\.weather.first)

            // Find the most common weather condition
            let dominantCondition = findDominantCondition(conditions)

            return Forecast(
                id: UUID().uuidString,
                date: date,
                tempMin: temps.min() ?? 0,
                tempMax: temps.max() ?? 0,
                tempAverage: temps.reduce(0, +) / Double(temps.count),
                humidity: humidities.reduce(0, +) / Double(humidities.count),
                pressure: pressures.reduce(0, +) / Double(pressures.count),
                windSpeed: windSpeeds.reduce(0, +) / Double(windSpeeds.count),
                windDirection: Double(items.first?.wind.deg ?? 0),
                cloudCoverage: Double(items.map { $0.clouds.all }.reduce(0, +)) / Double(items.count),
                precipitationProbability: pops.max() ?? 0,
                precipitationAmount: items.compactMap { $0.rain?.threeHour }.reduce(0, +),
                condition: WeatherMapper.mapWeatherCondition(dominantCondition),
                iconCode: dominantCondition?.icon ?? "01d",
                conditionDescription: dominantCondition?.description ?? "Unknown",
                hourlyItems: mapHourlyItems(items)
            )
        }
        .sorted { $0.date < $1.date }
    }

    /// Maps a single ForecastItemDTO to a ForecastHourlyItem.
    static func mapToHourlyItem(_ dto: ForecastItemDTO) -> ForecastHourlyItem {
        ForecastHourlyItem(
            time: Date.fromUnixTimestamp(dto.dt),
            temperature: dto.main.temp,
            feelsLike: dto.main.feelsLike,
            humidity: Double(dto.main.humidity),
            pressure: Double(dto.main.pressure),
            windSpeed: dto.wind.speed,
            cloudCoverage: Double(dto.clouds.all),
            precipitationProbability: dto.pop,
            condition: WeatherMapper.mapWeatherCondition(dto.weather.first),
            iconCode: dto.weather.first?.icon ?? "01d"
        )
    }

    // MARK: - Private Helpers

    private static func groupByDay(_ items: [ForecastItemDTO]) -> [(Date, [ForecastItemDTO])] {
        let calendar = Calendar.current
        var groups: [Date: [ForecastItemDTO]] = [:]

        for item in items {
            let date = Date.fromUnixTimestamp(item.dt)
            let dayStart = calendar.startOfDay(for: date)
            groups[dayStart, default: []].append(item)
        }

        return groups.sorted { $0.key < $1.key }
    }

    private static func findDominantCondition(_ conditions: [WeatherConditionDTO]) -> WeatherConditionDTO? {
        var frequency: [Int: Int] = [:]
        for condition in conditions {
            frequency[condition.id, default: 0] += 1
        }
        let dominantID = frequency.max(by: { $0.value < $1.value })?.key
        return conditions.first { $0.id == dominantID }
    }

    private static func mapHourlyItems(_ items: [ForecastItemDTO]) -> [ForecastHourlyItem] {
        items.map { mapToHourlyItem($0) }
    }
}

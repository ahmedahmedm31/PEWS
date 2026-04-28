// WeatherMapper.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Maps weather API response DTOs to domain entities.
enum WeatherMapper {

    /// Maps a CurrentWeatherResponseDTO to a WeatherData domain entity.
    static func mapToDomain(_ dto: CurrentWeatherResponseDTO) -> WeatherData {
        let condition = mapWeatherCondition(dto.weather.first)

        return WeatherData(
            id: UUID().uuidString,
            location: Location(
                id: String(dto.id),
                name: dto.name,
                latitude: dto.coord.lat,
                longitude: dto.coord.lon,
                country: dto.sys.country ?? "",
                state: nil
            ),
            temperature: dto.main.temp,
            feelsLike: dto.main.feelsLike,
            tempMin: dto.main.tempMin,
            tempMax: dto.main.tempMax,
            humidity: Double(dto.main.humidity),
            pressure: Double(dto.main.pressure),
            windSpeed: dto.wind.speed,
            windDirection: Double(dto.wind.deg),
            windGust: dto.wind.gust,
            cloudCoverage: Double(dto.clouds.all),
            visibility: Double(dto.visibility ?? 10000),
            precipitation: dto.rain?.oneHour ?? dto.snow?.oneHour ?? 0,
            uvIndex: 0,
            condition: condition,
            iconCode: dto.weather.first?.icon ?? "01d",
            sunrise: Date.fromUnixTimestamp(dto.sys.sunrise),
            sunset: Date.fromUnixTimestamp(dto.sys.sunset),
            timestamp: Date.fromUnixTimestamp(dto.dt),
            timezone: dto.timezone
        )
    }

    /// Maps a weather condition DTO to a WeatherCondition domain type.
    static func mapWeatherCondition(_ dto: WeatherConditionDTO?) -> WeatherCondition {
        guard let dto else { return .unknown }

        switch dto.id {
        case 200...232: return .thunderstorm
        case 300...321: return .drizzle
        case 500...531: return .rain
        case 600...622: return .snow
        case 701...721: return .mist
        case 741:       return .fog
        case 751...781: return .mist
        case 800:       return .clear
        case 801...802: return .partlyCloudy
        case 803...804: return .overcast
        default:        return .unknown
        }
    }

    /// Maps a weather condition ID to an SF Symbol icon name.
    static func mapToIcon(conditionID: Int, isNight: Bool) -> String {
        switch conditionID {
        case 200...232: return Constants.WeatherIcons.thunderstorm
        case 300...321: return Constants.WeatherIcons.rain
        case 500...504: return Constants.WeatherIcons.rain
        case 511:       return Constants.WeatherIcons.snow
        case 520...531: return Constants.WeatherIcons.heavyRain
        case 600...622: return Constants.WeatherIcons.snow
        case 701...741: return Constants.WeatherIcons.fog
        case 751...781: return Constants.WeatherIcons.wind
        case 800:
            return isNight ? Constants.WeatherIcons.clearNight : Constants.WeatherIcons.clearDay
        case 801...802:
            return isNight ? Constants.WeatherIcons.partlyCloudyNight : Constants.WeatherIcons.partlyCloudyDay
        case 803...804: return Constants.WeatherIcons.cloudy
        default:        return Constants.WeatherIcons.clearDay
        }
    }
}

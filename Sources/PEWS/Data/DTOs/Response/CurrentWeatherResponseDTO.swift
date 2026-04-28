// CurrentWeatherResponseDTO.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// DTO matching the OpenWeatherMap Current Weather API response.
struct CurrentWeatherResponseDTO: Codable, Equatable {
    let coord: CoordinatesDTO
    let weather: [WeatherConditionDTO]
    let base: String?
    let main: MainWeatherDTO
    let visibility: Int?
    let wind: WindDTO
    let clouds: CloudsDTO
    let rain: PrecipitationDTO?
    let snow: PrecipitationDTO?
    let dt: Int
    let sys: SystemDTO
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int

    enum CodingKeys: String, CodingKey {
        case coord, weather, base, main, visibility, wind, clouds
        case rain, snow, dt, sys, timezone, id, name, cod
    }
}

// MARK: - Nested DTOs

struct CoordinatesDTO: Codable, Equatable {
    let lon: Double
    let lat: Double
}

struct WeatherConditionDTO: Codable, Equatable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherDTO: Codable, Equatable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let groundLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}

struct WindDTO: Codable, Equatable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct CloudsDTO: Codable, Equatable {
    let all: Int
}

struct PrecipitationDTO: Codable, Equatable {
    let oneHour: Double?
    let threeHour: Double?

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}

struct SystemDTO: Codable, Equatable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int
    let sunset: Int
}

// MARK: - Mock Data

extension CurrentWeatherResponseDTO: Mockable {
    static func mock() -> CurrentWeatherResponseDTO {
        CurrentWeatherResponseDTO(
            coord: CoordinatesDTO(lon: -6.2603, lat: 53.3498),
            weather: [
                WeatherConditionDTO(
                    id: 802,
                    main: "Clouds",
                    description: "scattered clouds",
                    icon: "03d"
                )
            ],
            base: "stations",
            main: MainWeatherDTO(
                temp: 15.5,
                feelsLike: 14.2,
                tempMin: 13.0,
                tempMax: 17.0,
                pressure: 1013,
                humidity: 72,
                seaLevel: 1013,
                groundLevel: 1010
            ),
            visibility: 10000,
            wind: WindDTO(speed: 5.2, deg: 230, gust: 8.1),
            clouds: CloudsDTO(all: 40),
            rain: nil,
            snow: nil,
            dt: Int(Date().timeIntervalSince1970),
            sys: SystemDTO(
                type: 2,
                id: 2019143,
                country: "IE",
                sunrise: Int(Date().timeIntervalSince1970) - 3600,
                sunset: Int(Date().timeIntervalSince1970) + 3600
            ),
            timezone: 0,
            id: 2964574,
            name: "Dublin",
            cod: 200
        )
    }
}

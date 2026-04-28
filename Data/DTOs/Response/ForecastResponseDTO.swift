// ForecastResponseDTO.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// DTO matching the OpenWeatherMap 5-day Forecast API response.
struct ForecastResponseDTO: Codable, Equatable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItemDTO]
    let city: CityDTO
}

// MARK: - Forecast Item

struct ForecastItemDTO: Codable, Equatable {
    let dt: Int
    let main: MainWeatherDTO
    let weather: [WeatherConditionDTO]
    let clouds: CloudsDTO
    let wind: WindDTO
    let visibility: Int?
    let pop: Double // Probability of precipitation
    let rain: PrecipitationDTO?
    let snow: PrecipitationDTO?
    let sys: ForecastSystemDTO
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, snow, sys
        case dtTxt = "dt_txt"
    }
}

struct ForecastSystemDTO: Codable, Equatable {
    let pod: String // "d" for day, "n" for night
}

// MARK: - City

struct CityDTO: Codable, Equatable {
    let id: Int
    let name: String
    let coord: CoordinatesDTO
    let country: String
    let population: Int?
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Mock Data

extension ForecastResponseDTO: Mockable {
    static func mock() -> ForecastResponseDTO {
        let now = Date()
        let items = (0..<40).map { index -> ForecastItemDTO in
            let date = now.addingTimeInterval(TimeInterval(index * 3 * 3600))
            return ForecastItemDTO(
                dt: Int(date.timeIntervalSince1970),
                main: MainWeatherDTO(
                    temp: 15.0 + Double(index % 8) * 0.5,
                    feelsLike: 14.0 + Double(index % 8) * 0.5,
                    tempMin: 13.0,
                    tempMax: 18.0,
                    pressure: 1013 + (index % 5),
                    humidity: 65 + (index % 20),
                    seaLevel: 1013,
                    groundLevel: 1010
                ),
                weather: [
                    WeatherConditionDTO(
                        id: 802,
                        main: "Clouds",
                        description: "scattered clouds",
                        icon: index % 2 == 0 ? "03d" : "03n"
                    )
                ],
                clouds: CloudsDTO(all: 40 + (index % 30)),
                wind: WindDTO(speed: 4.0 + Double(index % 5), deg: 200 + (index * 10 % 360), gust: 7.0),
                visibility: 10000,
                pop: Double(index % 5) * 0.2,
                rain: nil,
                snow: nil,
                sys: ForecastSystemDTO(pod: index % 2 == 0 ? "d" : "n"),
                dtTxt: Formatters.iso8601.string(from: date)
            )
        }

        return ForecastResponseDTO(
            cod: "200",
            message: 0,
            cnt: 40,
            list: items,
            city: CityDTO(
                id: 2964574,
                name: "Dublin",
                coord: CoordinatesDTO(lon: -6.2603, lat: 53.3498),
                country: "IE",
                population: 1024027,
                timezone: 0,
                sunrise: Int(now.timeIntervalSince1970) - 3600,
                sunset: Int(now.timeIntervalSince1970) + 3600
            )
        )
    }
}

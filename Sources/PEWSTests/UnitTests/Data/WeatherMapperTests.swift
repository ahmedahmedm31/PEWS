// WeatherMapperTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class WeatherMapperTests: XCTestCase {

    // MARK: - Current Weather Mapping

    func testMapCurrentWeatherDTO() {
        let dto = CurrentWeatherResponseDTO(
            coord: CurrentWeatherResponseDTO.Coord(lon: -0.1257, lat: 51.5085),
            weather: [
                WeatherConditionDTO(
                    id: 800, main: "Clear", description: "clear sky", icon: "01d"
                )
            ],
            main: CurrentWeatherResponseDTO.Main(
                temp: 15.5, feelsLike: 14.2, tempMin: 13.0, tempMax: 17.0,
                pressure: 1013, humidity: 65
            ),
            wind: CurrentWeatherResponseDTO.Wind(speed: 5.2, deg: 180, gust: 8.1),
            clouds: CurrentWeatherResponseDTO.Clouds(all: 10),
            visibility: 10000,
            rain: nil,
            snow: nil,
            dt: Int(Date().timeIntervalSince1970),
            sys: CurrentWeatherResponseDTO.Sys(
                sunrise: Int(Date().timeIntervalSince1970),
                sunset: Int(Date().timeIntervalSince1970) + 3600
            ),
            timezone: 0,
            id: 2643743,
            name: "London"
        )

        let weatherData = WeatherMapper.mapToDomain(dto)

        XCTAssertEqual(weatherData.temperature, 15.5)
        XCTAssertEqual(weatherData.feelsLike, 14.2)
        XCTAssertEqual(weatherData.humidity, 65)
        XCTAssertEqual(weatherData.pressure, 1013)
        XCTAssertEqual(weatherData.windSpeed, 5.2)
        XCTAssertEqual(weatherData.windDirection, 180)
        XCTAssertEqual(weatherData.windGust, 8.1)
        XCTAssertEqual(weatherData.cloudCoverage, 10)
        XCTAssertEqual(weatherData.visibility, 10000)
        XCTAssertEqual(weatherData.condition, .clear)
        XCTAssertEqual(weatherData.iconCode, "01d")
    }

    func testMapCurrentWeatherWithRain() {
        let dto = CurrentWeatherResponseDTO(
            coord: CurrentWeatherResponseDTO.Coord(lon: 0, lat: 0),
            weather: [
                WeatherConditionDTO(
                    id: 500, main: "Rain", description: "light rain", icon: "10d"
                )
            ],
            main: CurrentWeatherResponseDTO.Main(
                temp: 12.0, feelsLike: 10.0, tempMin: 10.0, tempMax: 14.0,
                pressure: 1005, humidity: 85
            ),
            wind: CurrentWeatherResponseDTO.Wind(speed: 8.0, deg: 270, gust: nil),
            clouds: CurrentWeatherResponseDTO.Clouds(all: 90),
            visibility: 5000,
            rain: CurrentWeatherResponseDTO.Precipitation(oneHour: 2.5),
            snow: nil,
            dt: Int(Date().timeIntervalSince1970),
            sys: CurrentWeatherResponseDTO.Sys(
                sunrise: Int(Date().timeIntervalSince1970),
                sunset: Int(Date().timeIntervalSince1970) + 3600
            ),
            timezone: 0,
            id: 1,
            name: "Test"
        )

        let weatherData = WeatherMapper.mapToDomain(dto)

        XCTAssertEqual(weatherData.precipitation, 2.5)
        XCTAssertEqual(weatherData.condition, .rain)
    }

    // MARK: - Weather Condition Mapping

    func testWeatherConditionMapping() {
        let testCases: [(Int, WeatherCondition)] = [
            (200, .thunderstorm),
            (300, .drizzle),
            (500, .rain),
            (600, .snow),
            (701, .mist),
            (741, .fog),
            (800, .clear),
            (801, .partlyCloudy),
            (804, .overcast),
            (999, .unknown)
        ]

        for (code, expected) in testCases {
            let dto = WeatherConditionDTO(
                id: code, main: "Test", description: "test", icon: "01d"
            )
            let condition = WeatherMapper.mapWeatherCondition(dto)
            XCTAssertEqual(condition, expected, "Code \(code) should map to \(expected)")
        }
    }
}

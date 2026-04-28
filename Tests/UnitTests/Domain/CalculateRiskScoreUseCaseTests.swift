// CalculateRiskScoreUseCaseTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class CalculateRiskScoreUseCaseTests: XCTestCase {

    private var sut: CalculateRiskScoreUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateRiskScoreUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Low Risk Tests

    func testNormalConditionsReturnLowRisk() {
        let weather = WeatherData.mock()
        let score = sut.execute(weatherData: weather)

        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 25, "Normal conditions should produce low risk score")
    }

    // MARK: - High Risk Tests

    func testExtremeConditionsReturnHighRisk() {
        let weather = WeatherData.mockExtreme()
        let score = sut.execute(weatherData: weather)

        XCTAssertGreaterThan(score, 50, "Extreme conditions should produce high risk score")
    }

    // MARK: - Temperature Risk Tests

    func testExtremeHeatIncreasesRisk() {
        let hotWeather = WeatherData(
            id: "test", location: Location.mock(),
            temperature: 42, feelsLike: 45, tempMin: 38, tempMax: 44,
            humidity: 50, pressure: 1013, windSpeed: 5, windDirection: 180,
            windGust: nil, cloudCoverage: 20, visibility: 10000,
            precipitation: 0, uvIndex: 8, condition: .clear, iconCode: "01d",
            sunrise: Date(), sunset: Date().addingTimeInterval(3600),
            timestamp: Date(), timezone: 0
        )

        let normalWeather = WeatherData.mock()
        let hotScore = sut.execute(weatherData: hotWeather)
        let normalScore = sut.execute(weatherData: normalWeather)

        XCTAssertGreaterThan(hotScore, normalScore, "Extreme heat should increase risk score")
    }

    func testExtremeColdIncreasesRisk() {
        let coldWeather = WeatherData(
            id: "test", location: Location.mock(),
            temperature: -25, feelsLike: -30, tempMin: -28, tempMax: -22,
            humidity: 50, pressure: 1013, windSpeed: 5, windDirection: 180,
            windGust: nil, cloudCoverage: 20, visibility: 10000,
            precipitation: 0, uvIndex: 1, condition: .clear, iconCode: "01d",
            sunrise: Date(), sunset: Date().addingTimeInterval(3600),
            timestamp: Date(), timezone: 0
        )

        let score = sut.execute(weatherData: coldWeather)
        XCTAssertGreaterThan(score, 10, "Extreme cold should increase risk score")
    }

    // MARK: - Wind Risk Tests

    func testHighWindIncreasesRisk() {
        let windyWeather = WeatherData(
            id: "test", location: Location.mock(),
            temperature: 15, feelsLike: 12, tempMin: 13, tempMax: 17,
            humidity: 50, pressure: 1013, windSpeed: 35, windDirection: 180,
            windGust: 50, cloudCoverage: 20, visibility: 10000,
            precipitation: 0, uvIndex: 3, condition: .clear, iconCode: "01d",
            sunrise: Date(), sunset: Date().addingTimeInterval(3600),
            timestamp: Date(), timezone: 0
        )

        let normalWeather = WeatherData.mock()
        let windyScore = sut.execute(weatherData: windyWeather)
        let normalScore = sut.execute(weatherData: normalWeather)

        XCTAssertGreaterThan(windyScore, normalScore, "High wind should increase risk score")
    }

    // MARK: - Score Range Tests

    func testScoreIsAlwaysBetween0And100() {
        let testCases: [WeatherData] = [
            WeatherData.mock(),
            WeatherData.mockExtreme()
        ]

        for weather in testCases {
            let score = sut.execute(weatherData: weather)
            XCTAssertGreaterThanOrEqual(score, 0, "Score should be >= 0")
            XCTAssertLessThanOrEqual(score, 100, "Score should be <= 100")
        }
    }

    // MARK: - Thunderstorm Multiplier

    func testThunderstormConditionIncreasesRisk() {
        let stormWeather = WeatherData(
            id: "test", location: Location.mock(),
            temperature: 20, feelsLike: 20, tempMin: 18, tempMax: 22,
            humidity: 90, pressure: 980, windSpeed: 20, windDirection: 180,
            windGust: 30, cloudCoverage: 100, visibility: 2000,
            precipitation: 15, uvIndex: 0, condition: .thunderstorm, iconCode: "11d",
            sunrise: Date(), sunset: Date().addingTimeInterval(3600),
            timestamp: Date(), timezone: 0
        )

        let score = sut.execute(weatherData: stormWeather)
        XCTAssertGreaterThan(score, 30, "Thunderstorm should produce elevated risk")
    }
}

// FeatureExtractorTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class FeatureExtractorTests: XCTestCase {

    // MARK: - Normalization Tests

    func testNormalizeReturnsZeroForMinValue() {
        let result = FeatureExtractor.normalize(0, min: 0, max: 100)
        XCTAssertEqual(result, 0.0, accuracy: 0.001)
    }

    func testNormalizeReturnsOneForMaxValue() {
        let result = FeatureExtractor.normalize(100, min: 0, max: 100)
        XCTAssertEqual(result, 1.0, accuracy: 0.001)
    }

    func testNormalizeReturnsMidpointForMiddleValue() {
        let result = FeatureExtractor.normalize(50, min: 0, max: 100)
        XCTAssertEqual(result, 0.5, accuracy: 0.001)
    }

    func testNormalizeClampsBelowMin() {
        let result = FeatureExtractor.normalize(-10, min: 0, max: 100)
        XCTAssertEqual(result, 0.0, accuracy: 0.001)
    }

    func testNormalizeClampsAboveMax() {
        let result = FeatureExtractor.normalize(150, min: 0, max: 100)
        XCTAssertEqual(result, 1.0, accuracy: 0.001)
    }

    func testNormalizeHandlesNegativeRange() {
        let result = FeatureExtractor.normalize(0, min: -40, max: 50)
        XCTAssertEqual(result, 40.0 / 90.0, accuracy: 0.001)
    }

    func testNormalizeHandlesEqualMinMax() {
        let result = FeatureExtractor.normalize(5, min: 5, max: 5)
        XCTAssertEqual(result, 0.0, "Should return 0 when min equals max")
    }

    // MARK: - Dew Point Tests

    func testDewPointCalculation() {
        // At 20°C and 50% humidity, dew point should be approximately 9.3°C
        let dewPoint = FeatureExtractor.calculateDewPoint(temperature: 20, humidity: 50)
        XCTAssertEqual(dewPoint, 9.3, accuracy: 1.0)
    }

    func testDewPointAtHighHumidity() {
        // At 100% humidity, dew point should equal temperature
        let dewPoint = FeatureExtractor.calculateDewPoint(temperature: 25, humidity: 100)
        XCTAssertEqual(dewPoint, 25.0, accuracy: 0.5)
    }

    // MARK: - Heat Index Tests

    func testHeatIndexBelowThreshold() {
        // Below 27°C, heat index should equal temperature
        let heatIndex = FeatureExtractor.calculateHeatIndex(temperature: 20, humidity: 50)
        XCTAssertEqual(heatIndex, 20.0, accuracy: 0.001)
    }

    func testHeatIndexAboveThreshold() {
        // At 35°C and 80% humidity, heat index should be significantly higher
        let heatIndex = FeatureExtractor.calculateHeatIndex(temperature: 35, humidity: 80)
        XCTAssertGreaterThan(heatIndex, 35, "Heat index should exceed actual temperature at high humidity")
    }

    // MARK: - Wind Chill Tests

    func testWindChillBelowThreshold() {
        // At 5°C and 20 m/s wind, wind chill should be lower than temperature
        let windChill = FeatureExtractor.calculateWindChill(temperature: 5, windSpeed: 20)
        XCTAssertLessThan(windChill, 5, "Wind chill should be lower than actual temperature")
    }

    func testWindChillAboveThreshold() {
        // Above 10°C, wind chill should equal temperature
        let windChill = FeatureExtractor.calculateWindChill(temperature: 15, windSpeed: 20)
        XCTAssertEqual(windChill, 15.0, accuracy: 0.001)
    }

    func testWindChillWithLowWind() {
        // With very low wind, wind chill should equal temperature
        let windChill = FeatureExtractor.calculateWindChill(temperature: 5, windSpeed: 0.5)
        XCTAssertEqual(windChill, 5.0, accuracy: 0.001)
    }

    // MARK: - Feature Extraction Tests

    func testExtractFeaturesReturnsNormalizedValues() {
        let weather = WeatherData.mock()
        let features = FeatureExtractor.extractFeatures(from: weather)

        // All normalized values should be between 0 and 1
        XCTAssertGreaterThanOrEqual(features.temperature, 0)
        XCTAssertLessThanOrEqual(features.temperature, 1)
        XCTAssertGreaterThanOrEqual(features.humidity, 0)
        XCTAssertLessThanOrEqual(features.humidity, 1)
        XCTAssertGreaterThanOrEqual(features.pressure, 0)
        XCTAssertLessThanOrEqual(features.pressure, 1)
        XCTAssertGreaterThanOrEqual(features.windSpeed, 0)
        XCTAssertLessThanOrEqual(features.windSpeed, 1)
    }

    func testFeatureArrayHasCorrectCount() {
        let weather = WeatherData.mock()
        let features = FeatureExtractor.extractFeatures(from: weather)

        XCTAssertEqual(features.featureArray.count, 15, "Feature array should have 15 elements")
    }

    func testFeatureDictHasCorrectKeys() {
        let weather = WeatherData.mock()
        let features = FeatureExtractor.extractFeatures(from: weather)
        let dict = features.featureDict

        let expectedKeys = [
            "temperature", "humidity", "pressure", "windSpeed", "windDirection",
            "cloudCoverage", "visibility", "precipitation",
            "tempChange", "pressureChange", "humidityChange", "windSpeedChange",
            "dewPoint", "heatIndex", "windChill"
        ]

        for key in expectedKeys {
            XCTAssertNotNil(dict[key], "Feature dict should contain key: \(key)")
        }
    }

    // MARK: - Features With History Tests

    func testExtractFeaturesWithHistoryCalculatesRateOfChange() {
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)

        let current = WeatherData(
            id: "current", location: Location.mock(),
            temperature: 25, feelsLike: 25, tempMin: 22, tempMax: 28,
            humidity: 60, pressure: 1010, windSpeed: 10, windDirection: 180,
            windGust: nil, cloudCoverage: 50, visibility: 10000,
            precipitation: 0, uvIndex: 5, condition: .clear, iconCode: "01d",
            sunrise: now, sunset: now.addingTimeInterval(3600),
            timestamp: now, timezone: 0
        )

        let previous = WeatherData(
            id: "previous", location: Location.mock(),
            temperature: 20, feelsLike: 20, tempMin: 18, tempMax: 22,
            humidity: 70, pressure: 1015, windSpeed: 5, windDirection: 180,
            windGust: nil, cloudCoverage: 50, visibility: 10000,
            precipitation: 0, uvIndex: 5, condition: .clear, iconCode: "01d",
            sunrise: oneHourAgo, sunset: oneHourAgo.addingTimeInterval(3600),
            timestamp: oneHourAgo, timezone: 0
        )

        let features = FeatureExtractor.extractFeaturesWithHistory(
            current: current,
            history: [previous]
        )

        // Rate of change should be non-zero since values changed
        XCTAssertNotEqual(features.tempChange, 0, "Temperature change should be non-zero")
        XCTAssertNotEqual(features.pressureChange, 0, "Pressure change should be non-zero")
    }
}

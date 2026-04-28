// PredictionEngineTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class PredictionEngineTests: XCTestCase {

    private var sut: PredictionEngine!

    override func setUp() {
        super.setUp()
        sut = PredictionEngine()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Rule-Based Prediction Tests

    func testPredictWithNormalConditions() async throws {
        let features = WeatherFeatures(
            temperature: 0.5, humidity: 0.5, pressure: 0.63,
            windSpeed: 0.1, windDirection: 0.5, cloudCoverage: 0.3,
            visibility: 0.8, precipitation: 0.0,
            tempChange: 0.5, pressureChange: 0.5,
            humidityChange: 0.5, windSpeedChange: 0.5,
            dewPoint: 0.5, heatIndex: 0.5, windChill: 0.5
        )

        let result = try await sut.predict(features: features)

        XCTAssertGreaterThanOrEqual(result.crisisProbability, 0)
        XCTAssertLessThanOrEqual(result.crisisProbability, 1)
        XCTAssertGreaterThan(result.confidence, 0)
        XCTAssertGreaterThan(result.processingTime, 0)
    }

    func testPredictWithExtremeConditions() async throws {
        let features = WeatherFeatures(
            temperature: 0.95, humidity: 0.95, pressure: 0.1,
            windSpeed: 0.9, windDirection: 0.5, cloudCoverage: 1.0,
            visibility: 0.05, precipitation: 0.9,
            tempChange: 0.9, pressureChange: 0.1,
            humidityChange: 0.9, windSpeedChange: 0.9,
            dewPoint: 0.8, heatIndex: 0.9, windChill: 0.1
        )

        let result = try await sut.predict(features: features)

        XCTAssertGreaterThan(result.crisisProbability, 0.3, "Extreme conditions should produce higher probability")
    }

    func testPredictResultProbabilityIsClamped() async throws {
        let features = WeatherFeatures(
            temperature: 1.0, humidity: 1.0, pressure: 0.0,
            windSpeed: 1.0, windDirection: 0.5, cloudCoverage: 1.0,
            visibility: 0.0, precipitation: 1.0,
            tempChange: 1.0, pressureChange: 0.0,
            humidityChange: 1.0, windSpeedChange: 1.0,
            dewPoint: 1.0, heatIndex: 1.0, windChill: 0.0
        )

        let result = try await sut.predict(features: features)

        XCTAssertGreaterThanOrEqual(result.crisisProbability, 0, "Probability should be >= 0")
        XCTAssertLessThanOrEqual(result.crisisProbability, 1, "Probability should be <= 1")
    }

    // MARK: - Model State Tests

    func testModelNotLoadedUsesRuleBasedFallback() async throws {
        // Without a CoreML model in test bundle, should use rule-based
        XCTAssertFalse(sut.isModelLoaded, "Model should not be loaded in test environment")

        let features = WeatherFeatures(
            temperature: 0.5, humidity: 0.5, pressure: 0.5,
            windSpeed: 0.5, windDirection: 0.5, cloudCoverage: 0.5,
            visibility: 0.5, precipitation: 0.5,
            tempChange: 0.5, pressureChange: 0.5,
            humidityChange: 0.5, windSpeedChange: 0.5,
            dewPoint: 0.5, heatIndex: 0.5, windChill: 0.5
        )

        let result = try await sut.predict(features: features)

        // Rule-based confidence is 0.65
        XCTAssertEqual(result.confidence, 0.65, accuracy: 0.01, "Rule-based fallback should have 0.65 confidence")
    }

    // MARK: - Processing Time Tests

    func testPredictReturnsPositiveProcessingTime() async throws {
        let features = WeatherFeatures(
            temperature: 0.5, humidity: 0.5, pressure: 0.5,
            windSpeed: 0.5, windDirection: 0.5, cloudCoverage: 0.5,
            visibility: 0.5, precipitation: 0.5,
            tempChange: 0.5, pressureChange: 0.5,
            humidityChange: 0.5, windSpeedChange: 0.5,
            dewPoint: 0.5, heatIndex: 0.5, windChill: 0.5
        )

        let result = try await sut.predict(features: features)

        XCTAssertGreaterThan(result.processingTime, 0, "Processing time should be positive")
    }
}

// MockPredictionEngine.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
@testable import PEWS

/// Mock implementation of PredictionEngineProtocol for unit testing.
final class MockPredictionEngine: PredictionEngineProtocol {

    var predictCallCount = 0
    var stubbedResult: PredictionResult?
    var stubbedError: Error?
    var isModelLoaded: Bool = true

    func predict(features: WeatherFeatures) async throws -> PredictionResult {
        predictCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedResult ?? PredictionResult(
            crisisProbability: 0.35,
            confidence: 0.82,
            processingTime: 0.01
        )
    }
}

/// Mock implementation of PredictionRepositoryInterface for unit testing.
final class MockPredictionRepository: PredictionRepositoryInterface {

    var predictCrisisCallCount = 0
    var predictTimelineCallCount = 0
    var stubbedPrediction: Prediction?
    var stubbedTimeline: [Prediction] = []
    var stubbedError: Error?

    func predictCrisis(for weatherData: WeatherData) async throws -> Prediction {
        predictCrisisCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedPrediction ?? Prediction.mock()
    }

    func predictTimeline(for location: Location, using forecasts: [Forecast]) async throws -> [Prediction] {
        predictTimelineCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedTimeline
    }
}

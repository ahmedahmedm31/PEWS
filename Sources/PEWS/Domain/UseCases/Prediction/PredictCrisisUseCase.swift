// PredictCrisisUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for generating crisis predictions using ML model.
final class PredictCrisisUseCase {

    // MARK: - Properties

    private let repository: PredictionRepositoryInterface

    // MARK: - Initialization

    init(repository: PredictionRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Execute

    /// Generates a crisis prediction for the given weather data.
    /// - Parameter weatherData: Current weather conditions to analyze.
    /// - Returns: A Prediction with risk score and contributing factors.
    func execute(weatherData: WeatherData) async throws -> Prediction {
        Logger.info("Predicting crisis for \(weatherData.location.name)")
        return try await repository.predictCrisis(for: weatherData)
    }
}

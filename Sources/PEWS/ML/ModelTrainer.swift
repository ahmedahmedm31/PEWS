// ModelTrainer.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CoreML

/// Manages on-device model updates and retraining using CoreML's updatable model support.
/// Collects feedback data and periodically updates the model for improved predictions.
final class ModelTrainer {

    // MARK: - Properties

    private let modelURL: URL?
    private var trainingData: [TrainingDataPoint] = []
    private let maxTrainingPoints = 1000
    private let minTrainingPointsForUpdate = 50

    // MARK: - Training Data Point

    struct TrainingDataPoint {
        let features: WeatherFeatures
        let actualOutcome: Double // 0.0 = no crisis, 1.0 = crisis occurred
        let timestamp: Date
    }

    // MARK: - Initialization

    init() {
        modelURL = Bundle.main.url(
            forResource: AppConfig.ML.modelName,
            withExtension: "mlmodelc"
        )
    }

    // MARK: - Data Collection

    /// Records a training data point for future model updates.
    /// - Parameters:
    ///   - features: The weather features that were used for prediction.
    ///   - actualOutcome: The actual outcome (0.0 or 1.0).
    func recordOutcome(features: WeatherFeatures, actualOutcome: Double) {
        let dataPoint = TrainingDataPoint(
            features: features,
            actualOutcome: actualOutcome,
            timestamp: Date()
        )

        trainingData.append(dataPoint)

        // Trim old data if exceeding limit
        if trainingData.count > maxTrainingPoints {
            trainingData = Array(trainingData.suffix(maxTrainingPoints))
        }

        Logger.ml("Training data recorded: \(trainingData.count) points")
    }

    // MARK: - Model Update

    /// Checks if enough data has been collected for a model update.
    var canUpdate: Bool {
        trainingData.count >= minTrainingPointsForUpdate
    }

    /// Performs an on-device model update using collected training data.
    /// - Returns: True if the update was successful.
    func updateModel() async throws -> Bool {
        guard canUpdate else {
            Logger.ml("Insufficient training data for model update (\(trainingData.count)/\(minTrainingPointsForUpdate))")
            return false
        }

        guard let modelURL = modelURL else {
            Logger.warning("Model URL not available for update")
            return false
        }

        Logger.ml("Starting model update with \(trainingData.count) data points...")

        // Create batch provider from training data
        let batchProvider = try createBatchProvider()

        // Perform update
        let updateTask = try MLUpdateTask(
            forModelAt: modelURL,
            trainingData: batchProvider,
            configuration: nil,
            completionHandler: { context in
                if context.task.error != nil {
                    Logger.error("Model update failed: \(context.task.error?.localizedDescription ?? "unknown")")
                } else {
                    Logger.ml("Model update completed successfully")
                    // Save updated model
                    let updatedModelURL = context.model.modelDescription
                    Logger.ml("Updated model description: \(updatedModelURL)")
                }
            }
        )

        updateTask.resume()
        return true
    }

    // MARK: - Private Helpers

    private func createBatchProvider() throws -> MLBatchProvider {
        let featureProviders: [MLFeatureProvider] = try trainingData.map { point in
            var dict: [String: MLFeatureValue] = [:]
            for (key, value) in point.features.featureDict {
                dict[key] = MLFeatureValue(double: value)
            }
            dict["crisis_outcome"] = MLFeatureValue(double: point.actualOutcome)
            return try MLDictionaryFeatureProvider(dictionary: dict)
        }

        return MLArrayBatchProvider(array: featureProviders)
    }

    /// Clears all collected training data.
    func clearTrainingData() {
        trainingData.removeAll()
        Logger.ml("Training data cleared")
    }

    /// Returns the count of collected training data points.
    var trainingDataCount: Int {
        trainingData.count
    }
}

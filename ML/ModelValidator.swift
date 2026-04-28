// ModelValidator.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Validates ML model predictions against actual outcomes and tracks accuracy metrics.
/// Implemented as an actor to guarantee thread-safe access to mutable validation records.
actor ModelValidator {

    // MARK: - Validation Record

    struct ValidationRecord: Sendable {
        let predictedProbability: Double
        let actualOutcome: Bool
        let timestamp: Date
    }

    // MARK: - Properties

    private var records: [ValidationRecord] = []
    private let maxRecords = 500
    private let minimumAccuracy: Double

    init(minimumAccuracy: Double = 0.7) {
        self.minimumAccuracy = minimumAccuracy
    }

    // MARK: - Recording

    /// Records a prediction-outcome pair for validation.
    func record(predicted: Double, actual: Bool) {
        let record = ValidationRecord(
            predictedProbability: predicted,
            actualOutcome: actual,
            timestamp: Date()
        )
        records.append(record)

        if records.count > maxRecords {
            records = Array(records.suffix(maxRecords))
        }
    }

    // MARK: - Metrics

    var accuracy: Double {
        guard !records.isEmpty else { return 0 }

        let correct = records.filter { record in
            let predicted = record.predictedProbability >= 0.5
            return predicted == record.actualOutcome
        }.count

        return Double(correct) / Double(records.count)
    }

    var precision: Double {
        let predictedPositive = records.filter { $0.predictedProbability >= 0.5 }
        guard !predictedPositive.isEmpty else { return 0 }

        let truePositive = predictedPositive.filter { $0.actualOutcome }.count
        return Double(truePositive) / Double(predictedPositive.count)
    }

    var recall: Double {
        let actualPositive = records.filter { $0.actualOutcome }
        guard !actualPositive.isEmpty else { return 0 }

        let truePositive = actualPositive.filter { $0.predictedProbability >= 0.5 }.count
        return Double(truePositive) / Double(actualPositive.count)
    }

    var f1Score: Double {
        let p = precision
        let r = recall
        guard p + r > 0 else { return 0 }
        return 2 * (p * r) / (p + r)
    }

    var meanAbsoluteError: Double {
        guard !records.isEmpty else { return 0 }

        let totalError = records.reduce(0.0) { sum, record in
            let actual = record.actualOutcome ? 1.0 : 0.0
            return sum + abs(record.predictedProbability - actual)
        }

        return totalError / Double(records.count)
    }

    var metricsSummary: [String: Double] {
        [
            "accuracy": accuracy,
            "precision": precision,
            "recall": recall,
            "f1Score": f1Score,
            "meanAbsoluteError": meanAbsoluteError,
            "recordCount": Double(records.count)
        ]
    }

    var needsRetraining: Bool {
        records.count >= 50 && accuracy < minimumAccuracy
    }

    func clearRecords() {
        records.removeAll()
    }

    var recordCount: Int {
        records.count
    }
}

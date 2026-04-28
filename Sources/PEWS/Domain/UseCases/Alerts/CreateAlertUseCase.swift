// CreateAlertUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for creating alerts when risk thresholds are exceeded.
final class CreateAlertUseCase {

    // MARK: - Properties

    private let repository: AlertRepositoryInterface

    // MARK: - Initialization

    init(repository: AlertRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Execute

    /// Creates an alert if the prediction risk score exceeds the configured threshold.
    /// - Parameter prediction: The crisis prediction to evaluate.
    /// - Returns: The created Alert if threshold was exceeded, nil otherwise.
    @discardableResult
    func execute(prediction: Prediction) async throws -> Alert? {
        let threshold = repository.getAlertThreshold()

        guard prediction.riskScore >= threshold else {
            Logger.info("Risk score \(prediction.riskScore) below threshold \(threshold), no alert created")
            return nil
        }

        let alert = Alert(
            id: UUID().uuidString,
            locationID: prediction.locationID,
            locationName: prediction.locationName,
            riskScore: prediction.riskScore,
            riskLevel: prediction.riskLevel,
            title: "\(prediction.riskLevel.displayName) Risk: \(prediction.locationName)",
            message: buildAlertMessage(prediction: prediction),
            timestamp: Date(),
            isRead: false,
            isAcknowledged: false
        )

        try await repository.createAlert(alert)
        Logger.info("Alert created: \(alert.title)")
        return alert
    }

    // MARK: - Private Helpers

    private func buildAlertMessage(prediction: Prediction) -> String {
        var message = "Risk score: \(prediction.riskScore)/100. "
        message += prediction.riskLevel.description

        if !prediction.contributingFactors.isEmpty {
            let factorNames = prediction.contributingFactors.map(\.name).joined(separator: ", ")
            message += " Contributing factors: \(factorNames)."
        }

        return message
    }
}

// UpdateAlertThresholdUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for updating the alert risk threshold.
final class UpdateAlertThresholdUseCase {

    // MARK: - Properties

    private let repository: AlertRepositoryInterface

    // MARK: - Initialization

    init(repository: AlertRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Execute

    /// Updates the alert threshold to the specified value.
    /// - Parameter threshold: The new threshold value (0-100).
    func execute(threshold: Int) {
        let clamped = max(0, min(100, threshold))
        repository.updateAlertThreshold(clamped)
        Logger.info("Alert threshold updated to \(clamped)")
    }

    /// Returns the current alert threshold.
    func currentThreshold() -> Int {
        repository.getAlertThreshold()
    }
}

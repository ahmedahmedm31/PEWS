// AlertRepositoryInterface.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol defining the contract for alert data access.
/// Implemented by AlertRepository in the data layer.
protocol AlertRepositoryInterface: AnyObject {
    /// Fetches alerts, optionally filtered by location.
    func fetchAlerts(for locationID: String?) async throws -> [Alert]

    /// Fetches recent alerts within the specified hours.
    func fetchRecentAlerts(withinHours hours: Int) async throws -> [Alert]

    /// Creates a new alert.
    func createAlert(_ alert: Alert) async throws

    /// Marks an alert as read.
    func markAlertAsRead(_ id: String) async throws

    /// Marks an alert as acknowledged.
    func acknowledgeAlert(_ id: String) async throws

    /// Gets the current alert threshold.
    func getAlertThreshold() -> Int

    /// Updates the alert threshold.
    func updateAlertThreshold(_ threshold: Int)

    /// Deletes an alert.
    func deleteAlert(_ id: String) async throws

    /// Deletes all alerts.
    func deleteAllAlerts() async throws
}

// FetchAlertsUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for fetching and managing alerts through the repository.
final class FetchAlertsUseCase {

    private let repository: AlertRepositoryInterface

    init(repository: AlertRepositoryInterface) {
        self.repository = repository
    }

    // MARK: - Queries

    /// Fetches all alerts, optionally filtered by location.
    func execute(locationID: String? = nil) async throws -> [Alert] {
        try await repository.fetchAlerts(for: locationID)
    }

    /// Fetches alerts created within the specified number of hours.
    func executeRecent(withinHours hours: Int = 24) async throws -> [Alert] {
        try await repository.fetchRecentAlerts(withinHours: hours)
    }

    /// Returns the count of unread alerts.
    func unreadCount() async throws -> Int {
        let alerts = try await repository.fetchAlerts(for: nil)
        return alerts.filter { !$0.isRead }.count
    }

    // MARK: - Mutations

    func markAsRead(_ alertID: String) async throws {
        try await repository.markAlertAsRead(alertID)
    }

    func acknowledge(_ alertID: String) async throws {
        try await repository.acknowledgeAlert(alertID)
    }

    func delete(_ alertID: String) async throws {
        try await repository.deleteAlert(alertID)
    }

    func deleteAll() async throws {
        try await repository.deleteAllAlerts()
    }
}

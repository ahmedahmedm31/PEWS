// AlertsViewModel.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI

/// ViewModel managing the Alerts screen state and interactions.
@MainActor
final class AlertsViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var alerts: [Alert] = []
    @Published private(set) var unreadCount: Int = 0
    @Published var alertThreshold: Double = 50
    @Published var showThresholdEditor = false
    @Published var filterOption: AlertFilter = .all

    // MARK: - Filter

    enum AlertFilter: String, CaseIterable, Sendable {
        case all = "All"
        case unread = "Unread"
        case critical = "Critical"
        case high = "High"
        case recent = "Recent"
    }

    // MARK: - Dependencies

    private let fetchAlertsUseCase: FetchAlertsUseCase
    private let createAlertUseCase: CreateAlertUseCase
    private let updateThresholdUseCase: UpdateAlertThresholdUseCase

    // MARK: - Initialization

    init(
        fetchAlertsUseCase: FetchAlertsUseCase,
        createAlertUseCase: CreateAlertUseCase,
        updateThresholdUseCase: UpdateAlertThresholdUseCase
    ) {
        self.fetchAlertsUseCase = fetchAlertsUseCase
        self.createAlertUseCase = createAlertUseCase
        self.updateThresholdUseCase = updateThresholdUseCase
        self.alertThreshold = Double(updateThresholdUseCase.currentThreshold())
    }

    // MARK: - Data Loading

    func loadAlerts() async {
        state = .loading

        do {
            let allAlerts = try await fetchAlertsUseCase.execute()
            alerts = applyFilter(allAlerts)
            unreadCount = allAlerts.filter { !$0.isRead }.count
            state = alerts.isEmpty ? .empty : .loaded
        } catch {
            Logger.error("Alerts load failed", error: error)
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Actions

    func markAsRead(_ alert: Alert) async {
        do {
            try await fetchAlertsUseCase.markAsRead(alert.id)
            await loadAlerts()
        } catch {
            Logger.error("Failed to mark alert as read", error: error)
        }
    }

    func acknowledge(_ alert: Alert) async {
        do {
            try await fetchAlertsUseCase.acknowledge(alert.id)
            await loadAlerts()
        } catch {
            Logger.error("Failed to acknowledge alert", error: error)
        }
    }

    func delete(_ alert: Alert) async {
        do {
            try await fetchAlertsUseCase.delete(alert.id)
            await loadAlerts()
        } catch {
            Logger.error("Failed to delete alert", error: error)
        }
    }

    func deleteAll() async {
        do {
            try await fetchAlertsUseCase.deleteAll()
            await loadAlerts()
        } catch {
            Logger.error("Failed to delete all alerts", error: error)
        }
    }

    func updateThreshold() {
        updateThresholdUseCase.execute(threshold: Int(alertThreshold))
    }

    // MARK: - Filtering

    func applyCurrentFilter() async {
        await loadAlerts()
    }

    private func applyFilter(_ allAlerts: [Alert]) -> [Alert] {
        switch filterOption {
        case .all:
            return allAlerts
        case .unread:
            return allAlerts.filter { !$0.isRead }
        case .critical:
            return allAlerts.filter { $0.riskLevel == .critical }
        case .high:
            return allAlerts.filter { [.high, .critical].contains($0.riskLevel) }
        case .recent:
            let cutoff = Date().addingTimeInterval(-24 * 3600)
            return allAlerts.filter { $0.timestamp >= cutoff }
        }
    }

    // MARK: - Computed Properties

    var filteredAlerts: [Alert] { alerts }
    var hasUnreadAlerts: Bool { unreadCount > 0 }
}

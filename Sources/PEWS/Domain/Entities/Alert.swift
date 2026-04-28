// Alert.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Domain entity representing a crisis alert triggered by risk threshold exceedance.
struct Alert: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let locationID: String
    let locationName: String
    let riskScore: Int
    let riskLevel: RiskLevel
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    var isAcknowledged: Bool

    /// Notification priority derived from the risk level.
    var notificationPriority: NotificationPriority {
        switch riskLevel {
        case .critical:                return .timeSensitive
        case .high:                    return .active
        case .moderate, .low, .unknown: return .passive
        }
    }

    /// Relative time description for display (e.g., "5 minutes ago").
    var relativeTime: String {
        timestamp.relativeDescription
    }

    /// Category identifier used for notification grouping.
    var categoryIdentifier: String {
        switch riskLevel {
        case .critical: return Constants.Notifications.criticalAlertCategory
        case .high:     return Constants.Notifications.highAlertCategory
        default:        return Constants.Notifications.warningCategory
        }
    }
}

/// Notification priority levels aligned with UNNotificationInterruptionLevel.
enum NotificationPriority: String, Codable, Sendable {
    case timeSensitive
    case active
    case passive
}

// MARK: - Mock Data

#if DEBUG
extension Alert: Mockable {
    static func mock() -> Alert {
        Alert(
            id: UUID().uuidString,
            locationID: "dublin-001",
            locationName: "Dublin",
            riskScore: 78,
            riskLevel: .critical,
            title: "Critical Risk Alert",
            message: "Storm conditions detected in Dublin. Risk score: 78/100.",
            timestamp: Date(),
            isRead: false,
            isAcknowledged: false
        )
    }

    static func mockList() -> [Alert] {
        [
            Alert(
                id: UUID().uuidString,
                locationID: "dublin-001",
                locationName: "Dublin",
                riskScore: 82,
                riskLevel: .critical,
                title: "Critical: Severe Storm Warning",
                message: "Extreme storm conditions approaching Dublin area.",
                timestamp: Date().addingTimeInterval(-300),
                isRead: false,
                isAcknowledged: false
            ),
            Alert(
                id: UUID().uuidString,
                locationID: "london-001",
                locationName: "London",
                riskScore: 65,
                riskLevel: .high,
                title: "High Risk: Heavy Rainfall",
                message: "Significant rainfall expected in London over the next 12 hours.",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true,
                isAcknowledged: false
            ),
            Alert(
                id: UUID().uuidString,
                locationID: "dublin-001",
                locationName: "Dublin",
                riskScore: 35,
                riskLevel: .moderate,
                title: "Warning: Temperature Rising",
                message: "Above-average temperatures expected this week.",
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true,
                isAcknowledged: true
            )
        ]
    }
}
#endif

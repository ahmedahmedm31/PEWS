// NotificationManager.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import UserNotifications

/// Manages local notifications for weather alerts and crisis warnings.
final class NotificationManager: NSObject {

    // MARK: - Properties

    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    // MARK: - Initialization

    override init() {
        super.init()
        center.delegate = self
        registerCategories()
    }

    // MARK: - Permission

    /// Requests notification permission from the user.
    /// - Returns: True if permission was granted.
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            Logger.info("Notification permission: \(granted ? "granted" : "denied")")
            return granted
        } catch {
            Logger.error("Notification permission request failed", error: error)
            return false
        }
    }

    /// Checks the current notification authorization status.
    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Categories

    private func registerCategories() {
        let acknowledgeAction = UNNotificationAction(
            identifier: "ACKNOWLEDGE",
            title: "Acknowledge",
            options: .foreground
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: .destructive
        )

        let viewDetailsAction = UNNotificationAction(
            identifier: "VIEW_DETAILS",
            title: "View Details",
            options: .foreground
        )

        let criticalCategory = UNNotificationCategory(
            identifier: Constants.Notifications.criticalAlertCategory,
            actions: [acknowledgeAction, viewDetailsAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let highCategory = UNNotificationCategory(
            identifier: Constants.Notifications.highAlertCategory,
            actions: [acknowledgeAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let warningCategory = UNNotificationCategory(
            identifier: Constants.Notifications.warningCategory,
            actions: [viewDetailsAction, dismissAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([criticalCategory, highCategory, warningCategory])
    }

    // MARK: - Schedule Notifications

    /// Schedules a local notification for a weather alert.
    /// - Parameter alert: The alert to notify about.
    func scheduleAlertNotification(_ alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.categoryIdentifier = alert.categoryIdentifier
        content.userInfo = [
            "alertID": alert.id,
            "locationID": alert.locationID,
            "riskScore": alert.riskScore
        ]

        // Set sound based on risk level
        switch alert.riskLevel {
        case .critical:
            content.sound = .defaultCritical
            content.interruptionLevel = .critical
        case .high:
            content.sound = .default
            content.interruptionLevel = .timeSensitive
        default:
            content.sound = .default
            content.interruptionLevel = .active
        }

        // Badge count
        content.badge = NSNumber(value: 1)

        // Immediate trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: alert.id,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                Logger.error("Failed to schedule notification", error: error)
            } else {
                Logger.info("Notification scheduled: \(alert.title)")
            }
        }
    }

    // MARK: - Remove Notifications

    /// Removes a pending notification.
    func removePendingNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Removes all pending notifications.
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    /// Clears the badge count.
    func clearBadge() {
        center.setBadgeCount(0) { error in
            if let error = error {
                Logger.error("Failed to clear badge", error: error)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "ACKNOWLEDGE":
            if let alertID = userInfo["alertID"] as? String {
                Logger.info("Alert acknowledged via notification: \(alertID)")
                NotificationCenter.default.post(
                    name: .alertAcknowledged,
                    object: nil,
                    userInfo: ["alertID": alertID]
                )
            }

        case "VIEW_DETAILS":
            if let alertID = userInfo["alertID"] as? String {
                Logger.info("View details requested for alert: \(alertID)")
                NotificationCenter.default.post(
                    name: .alertViewDetails,
                    object: nil,
                    userInfo: ["alertID": alertID]
                )
            }

        default:
            break
        }

        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let alertAcknowledged = Notification.Name("com.pews.alertAcknowledged")
    static let alertViewDetails = Notification.Name("com.pews.alertViewDetails")
}

// AlertRepository.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CoreData

/// Repository managing alert data persistence and threshold settings.
/// Implements the AlertRepositoryInterface protocol from the domain layer.
final class AlertRepository: AlertRepositoryInterface {

    // MARK: - Properties

    private let coreDataManager: CoreDataManager
    private let userDefaultsManager: UserDefaultsManager

    // MARK: - Initialization

    init(
        coreDataManager: CoreDataManager,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.coreDataManager = coreDataManager
        self.userDefaultsManager = userDefaultsManager
    }

    // MARK: - Fetch Alerts

    /// Fetches all alerts, optionally filtered by location.
    /// - Parameter locationID: Optional location ID to filter by.
    /// - Returns: Array of Alert domain entities.
    func fetchAlerts(for locationID: String?) async throws -> [Alert] {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.alertEntityName)

        if let locationID = locationID {
            request.predicate = NSPredicate(format: "locationID == %@", locationID)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        let results = try context.fetch(request)
        return results.compactMap { mapToAlert($0) }
    }

    /// Fetches recent alerts within the specified time interval.
    /// - Parameter hours: Number of hours to look back.
    /// - Returns: Array of recent Alert entities.
    func fetchRecentAlerts(withinHours hours: Int) async throws -> [Alert] {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.alertEntityName)
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(hours * 3600))
        request.predicate = NSPredicate(format: "timestamp >= %@", cutoffDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        let results = try context.fetch(request)
        return results.compactMap { mapToAlert($0) }
    }

    // MARK: - Create Alert

    /// Creates and persists a new alert.
    /// - Parameter alert: The alert to create.
    func createAlert(_ alert: Alert) async throws {
        let context = coreDataManager.viewContext

        guard let entity = NSEntityDescription.entity(
            forEntityName: Constants.CoreData.alertEntityName,
            in: context
        ) else { return }

        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        managedObject.setValue(alert.id, forKey: "id")
        managedObject.setValue(alert.locationID, forKey: "locationID")
        managedObject.setValue(alert.locationName, forKey: "locationName")
        managedObject.setValue(alert.riskScore, forKey: "riskScore")
        managedObject.setValue(alert.riskLevel.rawValue, forKey: "riskLevel")
        managedObject.setValue(alert.title, forKey: "title")
        managedObject.setValue(alert.message, forKey: "message")
        managedObject.setValue(alert.timestamp, forKey: "timestamp")
        managedObject.setValue(alert.isRead, forKey: "isRead")
        managedObject.setValue(alert.isAcknowledged, forKey: "isAcknowledged")

        coreDataManager.saveContext()
        Logger.data("Alert created: \(alert.title)")
    }

    // MARK: - Update Alert

    /// Marks an alert as read.
    /// - Parameter id: The alert identifier.
    func markAlertAsRead(_ id: String) async throws {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.alertEntityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        if let result = try context.fetch(request).first {
            result.setValue(true, forKey: "isRead")
            coreDataManager.saveContext()
        }
    }

    /// Marks an alert as acknowledged.
    /// - Parameter id: The alert identifier.
    func acknowledgeAlert(_ id: String) async throws {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.alertEntityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        if let result = try context.fetch(request).first {
            result.setValue(true, forKey: "isAcknowledged")
            coreDataManager.saveContext()
        }
    }

    // MARK: - Threshold

    /// Gets the current alert threshold.
    /// - Returns: The risk score threshold (0-100).
    func getAlertThreshold() -> Int {
        userDefaultsManager.alertThreshold
    }

    /// Updates the alert threshold.
    /// - Parameter threshold: The new threshold value (0-100).
    func updateAlertThreshold(_ threshold: Int) {
        let clampedThreshold = max(0, min(100, threshold))
        userDefaultsManager.alertThreshold = clampedThreshold
        Logger.data("Alert threshold updated to \(clampedThreshold)")
    }

    // MARK: - Delete

    /// Deletes an alert by ID.
    /// - Parameter id: The alert identifier.
    func deleteAlert(_ id: String) async throws {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.alertEntityName)
        request.predicate = NSPredicate(format: "id == %@", id)

        let results = try context.fetch(request)
        for object in results {
            context.delete(object)
        }
        coreDataManager.saveContext()
    }

    /// Deletes all alerts.
    func deleteAllAlerts() async throws {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.CoreData.alertEntityName)
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(batchDelete)
        coreDataManager.saveContext()
        Logger.data("All alerts deleted")
    }

    // MARK: - Refresh

    func refresh() async throws {
        // Alerts are local-only
    }

    // MARK: - Private Helpers

    private func mapToAlert(_ managedObject: NSManagedObject) -> Alert? {
        guard let id = managedObject.value(forKey: "id") as? String,
              let title = managedObject.value(forKey: "title") as? String,
              let message = managedObject.value(forKey: "message") as? String,
              let timestamp = managedObject.value(forKey: "timestamp") as? Date,
              let riskLevelRaw = managedObject.value(forKey: "riskLevel") as? String else {
            return nil
        }

        return Alert(
            id: id,
            locationID: managedObject.value(forKey: "locationID") as? String ?? "",
            locationName: managedObject.value(forKey: "locationName") as? String ?? "",
            riskScore: managedObject.value(forKey: "riskScore") as? Int ?? 0,
            riskLevel: RiskLevel(rawValue: riskLevelRaw) ?? .unknown,
            title: title,
            message: message,
            timestamp: timestamp,
            isRead: managedObject.value(forKey: "isRead") as? Bool ?? false,
            isAcknowledged: managedObject.value(forKey: "isAcknowledged") as? Bool ?? false
        )
    }
}

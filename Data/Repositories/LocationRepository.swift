// LocationRepository.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CoreData

/// Repository managing location data persistence using Core Data.
/// Implements the LocationRepositoryInterface protocol from the domain layer.
final class LocationRepository: LocationRepositoryInterface {

    // MARK: - Properties

    private let coreDataManager: CoreDataManager

    // MARK: - Initialization

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    // MARK: - Fetch

    /// Fetches all saved locations.
    /// - Returns: Array of Location domain entities.
    func fetchLocations() async throws -> [Location] {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let results = try context.fetch(request)
            return results.compactMap { mapToLocation($0) }
        } catch {
            Logger.error("Failed to fetch locations", error: error)
            throw error
        }
    }

    /// Fetches a single location by ID.
    /// - Parameter id: The location identifier.
    /// - Returns: The Location if found, nil otherwise.
    func fetchLocation(byID id: String) async throws -> Location? {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        let results = try context.fetch(request)
        return results.first.flatMap { mapToLocation($0) }
    }

    // MARK: - Add

    /// Adds a new location to persistent storage.
    /// - Parameter location: The location to add.
    /// - Throws: WeatherError.maxLocationsReached if limit is exceeded.
    func addLocation(_ location: Location) async throws {
        let context = coreDataManager.viewContext

        // Check location limit
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        let count = try context.count(for: request)
        guard count < AppConfig.DataConstraints.maxLocations else {
            throw WeatherError.maxLocationsReached
        }

        // Check for duplicates
        let duplicateRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        duplicateRequest.predicate = NSPredicate(
            format: "latitude == %lf AND longitude == %lf",
            location.latitude,
            location.longitude
        )
        let duplicates = try context.count(for: duplicateRequest)
        guard duplicates == 0 else {
            Logger.warning("Location already exists: \(location.name)")
            return
        }

        guard let entity = NSEntityDescription.entity(
            forEntityName: Constants.CoreData.locationEntityName,
            in: context
        ) else { return }

        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        managedObject.setValue(location.id, forKey: "id")
        managedObject.setValue(location.name, forKey: "name")
        managedObject.setValue(location.latitude, forKey: "latitude")
        managedObject.setValue(location.longitude, forKey: "longitude")
        managedObject.setValue(location.country, forKey: "country")
        managedObject.setValue(location.state, forKey: "state")
        managedObject.setValue(Date(), forKey: "createdAt")

        coreDataManager.saveContext()
        Logger.data("Location added: \(location.name)")
    }

    // MARK: - Remove

    /// Removes a location from persistent storage.
    /// - Parameter id: The identifier of the location to remove.
    func removeLocation(byID id: String) async throws {
        let context = coreDataManager.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        request.predicate = NSPredicate(format: "id == %@", id)

        let results = try context.fetch(request)
        for object in results {
            context.delete(object)
        }

        coreDataManager.saveContext()
        Logger.data("Location removed: \(id)")
    }

    // MARK: - Count

    /// Returns the number of saved locations.
    func locationCount() async throws -> Int {
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.CoreData.locationEntityName)
        return try coreDataManager.viewContext.count(for: request)
    }

    // MARK: - Refresh

    func refresh() async throws {
        // Locations are local-only, no refresh needed
    }

    // MARK: - Private Helpers

    private func mapToLocation(_ managedObject: NSManagedObject) -> Location? {
        guard let id = managedObject.value(forKey: "id") as? String,
              let name = managedObject.value(forKey: "name") as? String,
              let latitude = managedObject.value(forKey: "latitude") as? Double,
              let longitude = managedObject.value(forKey: "longitude") as? Double else {
            return nil
        }

        return Location(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            country: managedObject.value(forKey: "country") as? String ?? "",
            state: managedObject.value(forKey: "state") as? String
        )
    }
}

// CoreDataManager.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import CoreData
import Foundation

/// Manages the Core Data stack and provides convenience methods for data operations.
final class CoreDataManager {

    // MARK: - Properties

    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.CoreData.containerName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                Logger.error("Core Data failed to load: \(error.localizedDescription)")
            } else {
                Logger.data("Core Data store loaded: \(storeDescription.url?.absoluteString ?? "unknown")")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Initialization

    init() {}

    // MARK: - Setup

    func setup() {
        _ = persistentContainer
        Logger.data("CoreDataManager initialized")
    }

    // MARK: - CRUD Operations

    /// Creates a new background context for write operations.
    func newBackgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    /// Saves the view context if there are changes.
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
                Logger.data("Context saved successfully")
            } catch {
                Logger.error("Failed to save context", error: error)
            }
        }
    }

    /// Saves a background context.
    func save(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
            Logger.data("Background context saved successfully")
        }
    }

    /// Fetches entities matching the given predicate.
    func fetch<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        limit: Int? = nil,
        context: NSManagedObjectContext? = nil
    ) throws -> [T] {
        let ctx = context ?? viewContext
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let limit = limit {
            request.fetchLimit = limit
        }
        guard let results = try ctx.fetch(request) as? [T] else {
            return []
        }
        return results
    }

    /// Deletes an entity from the context.
    func delete(_ object: NSManagedObject, context: NSManagedObjectContext? = nil) {
        let ctx = context ?? viewContext
        ctx.delete(object)
    }

    /// Deletes all entities of a given type.
    func deleteAll<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) throws {
        let ctx = context ?? viewContext
        let request = T.fetchRequest()
        request.predicate = predicate
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        batchDelete.resultType = .resultTypeObjectIDs
        let result = try ctx.execute(batchDelete) as? NSBatchDeleteResult
        if let objectIDs = result?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [viewContext]
            )
        }
    }

    /// Returns the count of entities matching the predicate.
    func count<T: NSManagedObject>(
        _ entityType: T.Type,
        predicate: NSPredicate? = nil
    ) throws -> Int {
        let request = T.fetchRequest()
        request.predicate = predicate
        return try viewContext.count(for: request)
    }
}

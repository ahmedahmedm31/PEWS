// Repository.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Base protocol for all repositories in the data layer.
/// Repositories coordinate data from multiple sources (remote, local, cache).
protocol RepositoryProtocol: AnyObject, Sendable {
    /// The type of entity this repository manages.
    associatedtype Entity

    /// Refreshes data from the remote source.
    func refresh() async throws
}

/// Protocol for repositories that support CRUD operations.
protocol CRUDRepository: RepositoryProtocol {
    /// Fetches all entities.
    func fetchAll() async throws -> [Entity]

    /// Fetches a single entity by its identifier.
    func fetch(byID id: String) async throws -> Entity?

    /// Saves an entity.
    func save(_ entity: Entity) async throws

    /// Deletes an entity by its identifier.
    func delete(byID id: String) async throws
}

/// Protocol for repositories that support paginated fetching.
protocol PaginatedRepository: RepositoryProtocol {
    /// Fetches a page of entities.
    func fetch(page: Int, pageSize: Int) async throws -> [Entity]
}

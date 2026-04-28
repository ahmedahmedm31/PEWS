// FetchLocationsUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for fetching all monitored locations.
final class FetchLocationsUseCase {

    private let repository: LocationRepositoryInterface

    init(repository: LocationRepositoryInterface) {
        self.repository = repository
    }

    /// Fetches all saved locations.
    /// - Returns: Array of Location entities.
    func execute() async throws -> [Location] {
        let locations = try await repository.fetchLocations()
        Logger.info("Fetched \(locations.count) locations")
        return locations
    }
}

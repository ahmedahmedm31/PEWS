// RemoveLocationUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for removing a monitored location.
final class RemoveLocationUseCase {

    private let repository: LocationRepositoryInterface

    init(repository: LocationRepositoryInterface) {
        self.repository = repository
    }

    /// Removes a location from the monitored locations list.
    /// - Parameter id: The identifier of the location to remove.
    func execute(id: String) async throws {
        try await repository.removeLocation(byID: id)
        Logger.info("Location removed: \(id)")
    }
}

// AddLocationUseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Use case for adding a new monitored location.
final class AddLocationUseCase {

    private let repository: LocationRepositoryInterface

    init(repository: LocationRepositoryInterface) {
        self.repository = repository
    }

    /// Adds a new location to the monitored locations list.
    /// - Parameter location: The location to add.
    /// - Throws: WeatherError.maxLocationsReached if limit exceeded.
    func execute(location: Location) async throws {
        guard location.isValid else {
            throw WeatherError.invalidCoordinates
        }

        let count = try await repository.locationCount()
        guard count < AppConfig.DataConstraints.maxLocations else {
            throw WeatherError.maxLocationsReached
        }

        try await repository.addLocation(location)
        Logger.info("Location added: \(location.name)")
    }
}

// LocationRepositoryInterface.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol defining the contract for location data access.
/// Implemented by LocationRepository in the data layer.
protocol LocationRepositoryInterface: AnyObject {
    /// Fetches all saved locations.
    func fetchLocations() async throws -> [Location]

    /// Fetches a single location by ID.
    func fetchLocation(byID id: String) async throws -> Location?

    /// Adds a new location.
    func addLocation(_ location: Location) async throws

    /// Removes a location by ID.
    func removeLocation(byID id: String) async throws

    /// Returns the count of saved locations.
    func locationCount() async throws -> Int
}

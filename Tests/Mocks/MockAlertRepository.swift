// MockAlertRepository.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
@testable import PEWS

/// Mock implementation of AlertRepositoryInterface for unit testing.
final class MockAlertRepository: AlertRepositoryInterface {

    var fetchAlertsCallCount = 0
    var fetchRecentAlertsCallCount = 0
    var createAlertCallCount = 0
    var markAsReadCallCount = 0
    var acknowledgeCallCount = 0
    var deleteAlertCallCount = 0
    var deleteAllCallCount = 0

    var stubbedAlerts: [Alert] = []
    var stubbedThreshold: Int = 50
    var stubbedError: Error?
    var createdAlerts: [Alert] = []

    func fetchAlerts(for locationID: String?) async throws -> [Alert] {
        fetchAlertsCallCount += 1
        if let error = stubbedError { throw error }
        if let locationID = locationID {
            return stubbedAlerts.filter { $0.locationID == locationID }
        }
        return stubbedAlerts
    }

    func fetchRecentAlerts(withinHours hours: Int) async throws -> [Alert] {
        fetchRecentAlertsCallCount += 1
        if let error = stubbedError { throw error }
        let cutoff = Date().addingTimeInterval(-TimeInterval(hours * 3600))
        return stubbedAlerts.filter { $0.timestamp >= cutoff }
    }

    func createAlert(_ alert: Alert) async throws {
        createAlertCallCount += 1
        if let error = stubbedError { throw error }
        createdAlerts.append(alert)
        stubbedAlerts.append(alert)
    }

    func markAlertAsRead(_ id: String) async throws {
        markAsReadCallCount += 1
        if let error = stubbedError { throw error }
    }

    func acknowledgeAlert(_ id: String) async throws {
        acknowledgeCallCount += 1
        if let error = stubbedError { throw error }
    }

    func getAlertThreshold() -> Int {
        stubbedThreshold
    }

    func updateAlertThreshold(_ threshold: Int) {
        stubbedThreshold = threshold
    }

    func deleteAlert(_ id: String) async throws {
        deleteAlertCallCount += 1
        if let error = stubbedError { throw error }
        stubbedAlerts.removeAll { $0.id == id }
    }

    func deleteAllAlerts() async throws {
        deleteAllCallCount += 1
        if let error = stubbedError { throw error }
        stubbedAlerts.removeAll()
    }
}

/// Mock implementation of LocationRepositoryInterface for unit testing.
final class MockLocationRepository: LocationRepositoryInterface {

    var fetchLocationsCallCount = 0
    var fetchLocationByIDCallCount = 0
    var addLocationCallCount = 0
    var removeLocationCallCount = 0
    var locationCountCallCount = 0

    var stubbedLocations: [Location] = []
    var stubbedError: Error?

    func fetchLocations() async throws -> [Location] {
        fetchLocationsCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedLocations
    }

    func fetchLocation(byID id: String) async throws -> Location? {
        fetchLocationByIDCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedLocations.first { $0.id == id }
    }

    func addLocation(_ location: Location) async throws {
        addLocationCallCount += 1
        if let error = stubbedError { throw error }
        stubbedLocations.append(location)
    }

    func removeLocation(byID id: String) async throws {
        removeLocationCallCount += 1
        if let error = stubbedError { throw error }
        stubbedLocations.removeAll { $0.id == id }
    }

    func locationCount() async throws -> Int {
        locationCountCallCount += 1
        return stubbedLocations.count
    }
}

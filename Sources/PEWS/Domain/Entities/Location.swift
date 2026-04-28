// Location.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CoreLocation

/// Domain entity representing a geographic location being monitored.
struct Location: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let state: String?
    let isDefault: Bool

    init(
        id: String,
        name: String,
        latitude: Double,
        longitude: Double,
        country: String,
        state: String?,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
        self.state = state
        self.isDefault = isDefault
    }

    /// MapKit-compatible coordinate.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Short display string such as "Dublin, IE".
    var displayName: String {
        country.isEmpty ? name : "\(name), \(country)"
    }

    /// Full display string including state when available.
    var fullDisplayName: String {
        if let state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return displayName
    }

    /// Formatted coordinate string for display.
    var coordinateString: String {
        String(format: "%.4f, %.4f", latitude, longitude)
    }

    /// Whether the coordinates fall within valid geographic bounds.
    var isValid: Bool {
        latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Equatable

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Default Location

    static func defaultLocation() -> Location {
        Location(
            id: "default",
            name: Constants.DefaultLocation.name,
            latitude: Constants.DefaultLocation.latitude,
            longitude: Constants.DefaultLocation.longitude,
            country: Constants.DefaultLocation.country,
            state: nil,
            isDefault: true
        )
    }
}

// MARK: - Mock Data

#if DEBUG
extension Location: Mockable {
    static func mock() -> Location {
        Location(
            id: UUID().uuidString,
            name: "Dublin",
            latitude: Constants.DefaultLocation.latitude,
            longitude: Constants.DefaultLocation.longitude,
            country: Constants.DefaultLocation.country,
            state: "Leinster",
            isDefault: true
        )
    }

    static func mockLondon() -> Location {
        Location(
            id: UUID().uuidString,
            name: "London",
            latitude: 51.5074,
            longitude: -0.1278,
            country: "GB",
            state: "England"
        )
    }

    static func mockNewYork() -> Location {
        Location(
            id: UUID().uuidString,
            name: "New York",
            latitude: 40.7128,
            longitude: -74.0060,
            country: "US",
            state: "New York"
        )
    }
}
#endif

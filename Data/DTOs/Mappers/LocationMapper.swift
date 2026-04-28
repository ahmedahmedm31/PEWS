// LocationMapper.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Maps geocoding API response DTOs to Location domain entities.
enum LocationMapper {

    /// Maps a GeocodingResponseDTO to a Location domain entity.
    /// The identifier is derived deterministically from the coordinates so that
    /// the same physical location always produces the same entity ID.
    static func mapToDomain(_ dto: GeocodingResponseDTO) -> Location {
        let stableID = Self.stableIdentifier(
            latitude: dto.lat,
            longitude: dto.lon,
            name: dto.name
        )
        return Location(
            id: stableID,
            name: dto.name,
            latitude: dto.lat,
            longitude: dto.lon,
            country: dto.country,
            state: dto.state
        )
    }

    static func mapToDomain(_ dtos: [GeocodingResponseDTO]) -> [Location] {
        dtos.map { mapToDomain($0) }
    }

    /// Builds a display string such as "Dublin, Leinster, IE".
    static func displayString(for location: Location) -> String {
        var components: [String] = [location.name]
        if let state = location.state, !state.isEmpty {
            components.append(state)
        }
        if !location.country.isEmpty {
            components.append(location.country)
        }
        return components.joined(separator: ", ")
    }

    /// Builds a coordinate string such as "53.3498°N, 6.2603°W".
    static func coordinateString(for location: Location) -> String {
        let latDirection = location.latitude >= 0 ? "N" : "S"
        let lonDirection = location.longitude >= 0 ? "E" : "W"
        return String(
            format: "%.4f°%@, %.4f°%@",
            abs(location.latitude), latDirection,
            abs(location.longitude), lonDirection
        )
    }

    // MARK: - Private

    /// Produces a stable, deterministic identifier from coordinates and name.
    private static func stableIdentifier(latitude: Double, longitude: Double, name: String) -> String {
        let normalized = String(format: "%.4f:%.4f:%@", latitude, longitude, name.lowercased())
        return normalized
            .data(using: .utf8)
            .map { data in
                data.map { String(format: "%02x", $0) }.joined()
            } ?? UUID().uuidString
    }
}

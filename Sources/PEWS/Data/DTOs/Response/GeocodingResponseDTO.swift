// GeocodingResponseDTO.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// DTO matching the OpenWeatherMap Geocoding API response.
/// The API returns an array of these objects.
struct GeocodingResponseDTO: Codable, Equatable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

// MARK: - Mock Data

extension GeocodingResponseDTO: Mockable {
    static func mock() -> GeocodingResponseDTO {
        GeocodingResponseDTO(
            name: "Dublin",
            localNames: ["en": "Dublin", "ga": "Baile Átha Cliath"],
            lat: 53.3498,
            lon: -6.2603,
            country: "IE",
            state: "Leinster"
        )
    }
}

extension Array where Element == GeocodingResponseDTO {
    static func mock() -> [GeocodingResponseDTO] {
        [
            GeocodingResponseDTO(
                name: "Dublin",
                localNames: ["en": "Dublin"],
                lat: 53.3498,
                lon: -6.2603,
                country: "IE",
                state: "Leinster"
            ),
            GeocodingResponseDTO(
                name: "Dublin",
                localNames: ["en": "Dublin"],
                lat: 39.8681,
                lon: -83.1141,
                country: "US",
                state: "Ohio"
            )
        ]
    }
}

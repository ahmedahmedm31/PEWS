// HistoricalWeatherRequestDTO.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// DTO for historical weather API requests.
struct HistoricalWeatherRequestDTO: Encodable {
    let latitude: Double
    let longitude: Double
    let date: Date

    var timestamp: Int {
        Int(date.timeIntervalSince1970)
    }
}

/// DTO for geocoding API requests.
struct GeocodingRequestDTO: Encodable {
    let query: String
    let limit: Int = 5
}

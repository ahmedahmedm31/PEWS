// UnitTypes.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Temperature unit options.
enum TemperatureUnit: String, CaseIterable, Codable {
    case celsius
    case fahrenheit

    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }

    var displayName: String {
        switch self {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        }
    }
}

/// Wind speed unit options.
enum SpeedUnit: String, CaseIterable, Codable {
    case metersPerSecond
    case kilometersPerHour
    case milesPerHour
    case knots

    var symbol: String {
        switch self {
        case .metersPerSecond: return "m/s"
        case .kilometersPerHour: return "km/h"
        case .milesPerHour: return "mph"
        case .knots: return "kn"
        }
    }

    var displayName: String {
        switch self {
        case .metersPerSecond: return "Meters/Second"
        case .kilometersPerHour: return "Kilometers/Hour"
        case .milesPerHour: return "Miles/Hour"
        case .knots: return "Knots"
        }
    }
}

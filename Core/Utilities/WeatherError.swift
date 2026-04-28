// WeatherError.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Domain-specific error types for the PEWS application.
enum WeatherError: LocalizedError {
    case invalidCoordinates
    case maxLocationsReached
    case networkUnavailable
    case apiRateLimited
    case dataParsingFailed
    case cacheExpired
    case predictionFailed(String)
    case locationNotFound
    case notificationPermissionDenied
    case exportFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCoordinates:
            return "Invalid location coordinates provided."
        case .maxLocationsReached:
            return "Maximum number of monitored locations reached."
        case .networkUnavailable:
            return "Network connection is unavailable. Please check your internet connection."
        case .apiRateLimited:
            return "API rate limit exceeded. Please try again later."
        case .dataParsingFailed:
            return "Failed to parse weather data."
        case .cacheExpired:
            return "Cached data has expired."
        case .predictionFailed(let reason):
            return "Prediction failed: \(reason)"
        case .locationNotFound:
            return "Location not found."
        case .notificationPermissionDenied:
            return "Notification permission was denied."
        case .exportFailed(let reason):
            return "Export failed: \(reason)"
        case .unknown(let message):
            return "An unexpected error occurred: \(message)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .apiRateLimited:
            return "Wait a few minutes before making another request."
        case .maxLocationsReached:
            return "Remove an existing location before adding a new one."
        case .notificationPermissionDenied:
            return "Enable notifications in Settings to receive alerts."
        default:
            return "Please try again."
        }
    }
}

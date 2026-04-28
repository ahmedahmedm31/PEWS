// APIError.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Comprehensive error types for API and data operations.
enum APIError: Error, Equatable, LocalizedError {
    case invalidURL
    case networkFailure(String)
    case invalidResponse(statusCode: Int)
    case decodingFailed(String)
    case rateLimited
    case serverError(statusCode: Int)
    case unauthorized
    case notFound
    case timeout
    case noInternetConnection
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .networkFailure(let message):
            return "Network error: \(message)"
        case .invalidResponse(let statusCode):
            return "Invalid response from server (status: \(statusCode))."
        case .decodingFailed(let message):
            return "Failed to process server response: \(message)"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let statusCode):
            return "Server error (status: \(statusCode)). Please try again later."
        case .unauthorized:
            return "API key is invalid or expired."
        case .notFound:
            return "The requested resource was not found."
        case .timeout:
            return "The request timed out. Please check your connection."
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .cancelled:
            return "The request was cancelled."
        }
    }

    /// Returns a user-friendly message suitable for display in the UI.
    var userFriendlyMessage: String {
        switch self {
        case .invalidURL, .decodingFailed:
            return "Something went wrong. Please try again."
        case .networkFailure, .noInternetConnection:
            return "Unable to connect. Please check your internet connection."
        case .invalidResponse, .serverError:
            return "The weather service is temporarily unavailable. Please try again later."
        case .rateLimited:
            return "Too many requests. Please wait a moment before trying again."
        case .unauthorized:
            return "Authentication error. Please check your API configuration."
        case .notFound:
            return "Location not found. Please try a different search."
        case .timeout:
            return "The request took too long. Please try again."
        case .cancelled:
            return "Request was cancelled."
        }
    }
}

/// Weather-specific domain errors.
enum WeatherError: Error, Equatable, LocalizedError {
    case locationNotFound
    case dataUnavailable
    case predictionFailed(String)
    case staleData
    case invalidCoordinates
    case maxLocationsReached

    var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "The specified location could not be found."
        case .dataUnavailable:
            return "Weather data is currently unavailable."
        case .predictionFailed(let reason):
            return "Crisis prediction failed: \(reason)"
        case .staleData:
            return "The cached data is outdated."
        case .invalidCoordinates:
            return "The provided coordinates are invalid."
        case .maxLocationsReached:
            return "Maximum number of locations (\(AppConfig.DataConstraints.maxLocations)) reached."
        }
    }
}

/// View-level errors for UI display.
enum ViewError: Error, Equatable, LocalizedError {
    case weatherUnavailable
    case locationPermissionDenied
    case networkOffline
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .weatherUnavailable:
            return "Weather data is not available right now."
        case .locationPermissionDenied:
            return "Location access is required. Please enable it in Settings."
        case .networkOffline:
            return "You appear to be offline. Showing cached data."
        case .unknownError(let message):
            return message
        }
    }
}

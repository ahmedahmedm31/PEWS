// APIKeys.example.swift
// PEWS - Predictive Early Warning System
//
// Copy this file to APIKeys.swift and replace placeholder values with your real API keys.
// APIKeys.swift is gitignored and will not be committed.
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// API keys for external services.
/// 1. Copy this file: `cp APIKeys.example.swift APIKeys.swift`
/// 2. Replace placeholder values below with your real API keys
/// 3. Never commit APIKeys.swift to version control
enum APIKeys {
    /// Get your free key at: https://openweathermap.org/api
    static let openWeatherMapKey = "YOUR_OPENWEATHERMAP_API_KEY"

    /// Get your free key at: https://www.visualcrossing.com/weather-api
    static let visualCrossingKey = "YOUR_VISUAL_CROSSING_API_KEY"
}

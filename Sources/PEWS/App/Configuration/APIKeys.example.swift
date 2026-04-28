// APIKeys.example.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.
//
// SETUP INSTRUCTIONS (choose one method):
//
// METHOD 1 — .xcconfig (Recommended):
//   1. Copy Configuration/Debug.xcconfig.example → Configuration/Debug.xcconfig
//   2. Replace YOUR_API_KEY_HERE with your real OpenWeatherMap key
//   3. In Xcode, set the project's Debug configuration to use Debug.xcconfig
//   4. Add OPENWEATHERMAP_API_KEY = $(OPENWEATHERMAP_API_KEY) to Info.plist
//   5. The key is read automatically at runtime via Bundle.main
//
// METHOD 2 — Direct file (Quick start):
//   1. Copy this file: cp APIKeys.example.swift APIKeys.swift
//   2. Replace the placeholder values below with your real API keys
//   3. APIKeys.swift is gitignored and will not be committed
//
// Get a free OpenWeatherMap key at: https://openweathermap.org/api

import Foundation

enum APIKeys {
    /// OpenWeatherMap API key.
    /// Get yours at: https://openweathermap.org/api
    static let openWeatherMapKey = "YOUR_OPENWEATHERMAP_API_KEY"

    /// Visual Crossing API key (optional, for historical data).
    /// Get yours at: https://www.visualcrossing.com/weather-api
    static let visualCrossingKey = "YOUR_VISUAL_CROSSING_API_KEY"
}

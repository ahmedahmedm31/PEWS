// AppConfig.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Central application configuration containing all app-wide constants and settings.
enum AppConfig {

    // MARK: - App Info

    static let appName = "PEWS"
    static let appFullName = "Predictive Early Warning System"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - API Configuration

    enum API {
        static let openWeatherMapBaseURL = "https://api.openweathermap.org"
        static let visualCrossingBaseURL = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services"
        static let requestTimeoutInterval: TimeInterval = 30
        static let maxRetryAttempts = 3
        static let retryDelay: TimeInterval = 2.0
    }

    // MARK: - Data Constraints

    enum DataConstraints {
        static let maxLocations = 10
        static let historicalDataYears = 5
        static let forecastDays = 7
        static let predictionHorizonHours = 48
        static let minimumRefreshIntervalSeconds: TimeInterval = 900
        static let offlineCacheHours = 24
        static let maxAPICallsPerDay = 1000
    }

    // MARK: - Cache Durations

    enum CacheDuration {
        static let currentWeather: TimeInterval = 900
        static let forecast: TimeInterval = 3600
        static let historicalData: TimeInterval = 86400
    }

    // MARK: - ML Configuration

    enum ML {
        static let modelName = "CrisisPredictionModel"
        static let maxModelSizeMB = 50
        static let maxInferenceTimeMS = 100
        static let minimumAccuracy = 0.70
        static let inputFeatureCount = 11
    }

    /// Backward-compatible alias.
    typealias MLConfig = ML

    // MARK: - Risk Thresholds

    enum RiskThresholds {
        static let low = 0...25
        static let moderate = 26...50
        static let high = 51...75
        static let critical = 76...100
        static let defaultAlertThreshold = 51
    }

    // MARK: - Performance Targets

    enum Performance {
        static let coldStartMaxSeconds: TimeInterval = 3.0
        static let dataRefreshMaxSeconds: TimeInterval = 2.0
        static let targetFrameRate = 60
        static let maxMemoryUsageMB = 100
        static let maxBatteryPercentPerHour = 5
    }

    // MARK: - UI Configuration

    enum UI {
        static let minimumTouchTarget: CGFloat = 44
        static let defaultAnimationDuration: TimeInterval = 0.3
        static let pullToRefreshThreshold: CGFloat = 80
        static let maxForecastRowsVisible = 7
    }
}

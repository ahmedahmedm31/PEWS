// Constants.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Application-wide constants organized by domain.
enum Constants {

    // MARK: - UserDefaults Keys

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedLocationID = "selectedLocationID"
        static let temperatureUnit = "temperatureUnit"
        static let speedUnit = "speedUnit"
        static let alertThreshold = "alertThreshold"
        static let notificationsEnabled = "notificationsEnabled"
        static let lastRefreshDate = "lastRefreshDate"
        static let selectedTheme = "selectedTheme"
        static let autoRefreshEnabled = "autoRefreshEnabled"
    }

    // MARK: - Core Data

    enum CoreData {
        static let containerName = "PEWS"
        static let locationEntityName = "CDLocation"
        static let alertEntityName = "CDAlert"
        static let weatherCacheEntityName = "CDWeatherCache"
    }

    // MARK: - Background Tasks

    enum BackgroundTasks {
        static let weatherRefresh = "com.pews.weather.refresh"
        static let predictionUpdate = "com.pews.prediction.update"
    }

    // MARK: - Notification

    enum Notifications {
        static let criticalAlertCategory = "CRITICAL_ALERT"
        static let highAlertCategory = "HIGH_ALERT"
        static let warningCategory = "WARNING_ALERT"
        static let viewAction = "VIEW_ACTION"
        static let dismissAction = "DISMISS_ACTION"
    }

    // MARK: - Animation

    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
        static let gaugeAnimationDuration: Double = 1.0
        static let chartAnimationDuration: Double = 0.8
    }

    // MARK: - Formatting

    enum Formatting {
        static let temperatureFormat = "%.1f"
        static let percentageFormat = "%.0f"
        static let pressureFormat = "%.0f"
        static let windSpeedFormat = "%.1f"
        static let coordinateFormat = "%.4f"
    }

    // MARK: - Weather Icons

    enum WeatherIcons {
        static let clearDay = "sun.max.fill"
        static let clearNight = "moon.stars.fill"
        static let cloudy = "cloud.fill"
        static let partlyCloudyDay = "cloud.sun.fill"
        static let partlyCloudyNight = "cloud.moon.fill"
        static let rain = "cloud.rain.fill"
        static let heavyRain = "cloud.heavyrain.fill"
        static let thunderstorm = "cloud.bolt.rain.fill"
        static let snow = "cloud.snow.fill"
        static let fog = "cloud.fog.fill"
        static let wind = "wind"
        static let tornado = "tornado"
        static let humidity = "humidity.fill"
        static let pressure = "gauge.medium"
        static let visibility = "eye.fill"
        static let uvIndex = "sun.max.trianglebadge.exclamationmark"
    }

    // MARK: - Default Location

    enum DefaultLocation {
        static let name = "Dublin"
        static let latitude = 53.3498
        static let longitude = -6.2603
        static let country = "IE"
    }
}

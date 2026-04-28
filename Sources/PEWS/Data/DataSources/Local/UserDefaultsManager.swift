// UserDefaultsManager.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Manages UserDefaults storage for app preferences and lightweight settings.
final class UserDefaultsManager {

    // MARK: - Properties

    private let defaults: UserDefaults

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    // MARK: - Default Registration

    private func registerDefaults() {
        defaults.register(defaults: [
            Constants.UserDefaultsKeys.temperatureUnit: TemperatureUnit.celsius.rawValue,
            Constants.UserDefaultsKeys.speedUnit: SpeedUnit.metersPerSecond.rawValue,
            Constants.UserDefaultsKeys.alertThreshold: AppConfig.RiskThresholds.defaultAlertThreshold,
            Constants.UserDefaultsKeys.notificationsEnabled: true,
            Constants.UserDefaultsKeys.autoRefreshEnabled: true,
            Constants.UserDefaultsKeys.hasCompletedOnboarding: false
        ])
    }

    // MARK: - Temperature Unit

    var temperatureUnit: TemperatureUnit {
        get {
            guard let rawValue = defaults.string(forKey: Constants.UserDefaultsKeys.temperatureUnit),
                  let unit = TemperatureUnit(rawValue: rawValue) else {
                return .celsius
            }
            return unit
        }
        set {
            defaults.set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.temperatureUnit)
        }
    }

    // MARK: - Speed Unit

    var speedUnit: SpeedUnit {
        get {
            guard let rawValue = defaults.string(forKey: Constants.UserDefaultsKeys.speedUnit),
                  let unit = SpeedUnit(rawValue: rawValue) else {
                return .metersPerSecond
            }
            return unit
        }
        set {
            defaults.set(newValue.rawValue, forKey: Constants.UserDefaultsKeys.speedUnit)
        }
    }

    // MARK: - Alert Threshold

    var alertThreshold: Int {
        get { defaults.integer(forKey: Constants.UserDefaultsKeys.alertThreshold) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.alertThreshold) }
    }

    // MARK: - Notifications

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.notificationsEnabled) }
    }

    // MARK: - Auto Refresh

    var autoRefreshEnabled: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.autoRefreshEnabled) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.autoRefreshEnabled) }
    }

    // MARK: - Selected Location

    var selectedLocationID: String? {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.selectedLocationID) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.selectedLocationID) }
    }

    // MARK: - Last Refresh

    var lastRefreshDate: Date? {
        get { defaults.object(forKey: Constants.UserDefaultsKeys.lastRefreshDate) as? Date }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.lastRefreshDate) }
    }

    // MARK: - Theme

    var selectedTheme: String {
        get { defaults.string(forKey: Constants.UserDefaultsKeys.selectedTheme) ?? "system" }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.selectedTheme) }
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding) }
    }

    // MARK: - Reset

    /// Resets all user preferences to defaults.
    func resetAll() {
        let domain = Bundle.main.bundleIdentifier ?? "com.pews.app"
        defaults.removePersistentDomain(forName: domain)
        registerDefaults()
        Logger.data("UserDefaults reset to defaults")
    }
}

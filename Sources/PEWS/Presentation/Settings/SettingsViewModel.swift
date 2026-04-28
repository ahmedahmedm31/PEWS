// SettingsViewModel.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI

/// ViewModel managing the Settings screen state and user preferences.
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var temperatureUnit: TemperatureUnit {
        didSet { userDefaults.temperatureUnit = temperatureUnit }
    }
    @Published var speedUnit: SpeedUnit {
        didSet { userDefaults.speedUnit = speedUnit }
    }
    @Published var notificationsEnabled: Bool {
        didSet { userDefaults.notificationsEnabled = notificationsEnabled }
    }
    @Published var autoRefreshEnabled: Bool {
        didSet { userDefaults.autoRefreshEnabled = autoRefreshEnabled }
    }
    @Published var selectedTheme: String {
        didSet { userDefaults.selectedTheme = selectedTheme }
    }
    @Published var alertThreshold: Int {
        didSet { userDefaults.alertThreshold = alertThreshold }
    }
    @Published private(set) var cacheSizeString: String = "Calculating..."
    @Published var showResetConfirmation = false
    @Published var showAbout = false

    // MARK: - Dependencies

    private let userDefaults: UserDefaultsManager
    private let cacheManager: CacheManager

    // MARK: - Initialization

    init(userDefaults: UserDefaultsManager, cacheManager: CacheManager) {
        self.userDefaults = userDefaults
        self.cacheManager = cacheManager

        self.temperatureUnit = userDefaults.temperatureUnit
        self.speedUnit = userDefaults.speedUnit
        self.notificationsEnabled = userDefaults.notificationsEnabled
        self.autoRefreshEnabled = userDefaults.autoRefreshEnabled
        self.selectedTheme = userDefaults.selectedTheme
        self.alertThreshold = userDefaults.alertThreshold

        calculateCacheSize()
    }

    // MARK: - Actions

    /// Clears all cached data.
    func clearCache() {
        cacheManager.clearAll()
        calculateCacheSize()
        Logger.ui("Cache cleared by user")
    }

    /// Resets all settings to defaults.
    func resetSettings() {
        userDefaults.resetAll()
        temperatureUnit = .celsius
        speedUnit = .metersPerSecond
        notificationsEnabled = true
        autoRefreshEnabled = true
        selectedTheme = "system"
        alertThreshold = AppConfig.RiskThresholds.defaultAlertThreshold
        Logger.ui("Settings reset to defaults")
    }

    /// Opens the system notification settings.
    func openNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Private

    private func calculateCacheSize() {
        let bytes = cacheManager.diskCacheSize
        if bytes < 1024 {
            cacheSizeString = "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            cacheSizeString = String(format: "%.1f KB", Double(bytes) / 1024)
        } else {
            cacheSizeString = String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        }
    }

    /// App version string.
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

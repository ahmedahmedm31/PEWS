// SettingsView.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

/// Settings screen for configuring app preferences, units, notifications, and data management.
struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                unitsSection
                notificationsSection
                alertsSection
                appearanceSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $viewModel.showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetSettings()
                }
            } message: {
                Text("This will reset all settings to their default values. This action cannot be undone.")
            }
            .sheet(isPresented: $viewModel.showAbout) {
                AboutView()
            }
        }
    }

    // MARK: - Units Section

    private var unitsSection: some View {
        Section("Units") {
            Picker("Temperature", selection: $viewModel.temperatureUnit) {
                ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }

            Picker("Wind Speed", selection: $viewModel.speedUnit) {
                ForEach(SpeedUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)

            Button("Notification Settings") {
                viewModel.openNotificationSettings()
            }
        }
    }

    // MARK: - Alerts Section

    private var alertsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                HStack {
                    Text("Alert Threshold")
                    Spacer()
                    Text("\(viewModel.alertThreshold)")
                        .foregroundColor(RiskLevel.fromScore(viewModel.alertThreshold).color)
                        .fontWeight(.semibold)
                }

                Slider(
                    value: Binding(
                        get: { Double(viewModel.alertThreshold) },
                        set: { viewModel.alertThreshold = Int($0) }
                    ),
                    in: 10...90,
                    step: 5
                )
                .tint(RiskLevel.fromScore(viewModel.alertThreshold).color)

                Text("Alerts trigger when risk score exceeds this value")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }

            Toggle("Auto Refresh", isOn: $viewModel.autoRefreshEnabled)
        } header: {
            Text("Alerts & Monitoring")
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $viewModel.selectedTheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section("Data") {
            HStack {
                Text("Cache Size")
                Spacer()
                Text(viewModel.cacheSizeString)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Button("Clear Cache") {
                viewModel.clearCache()
            }

            Button("Reset All Settings", role: .destructive) {
                viewModel.showResetConfirmation = true
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(viewModel.appVersion)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Button("About PEWS") {
                viewModel.showAbout = true
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xLarge) {
                    // App icon and name
                    VStack(spacing: Theme.Spacing.medium) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.primaryFallback)

                        Text("PEWS")
                            .font(Theme.Typography.largeTitle)

                        Text("Predictive Early Warning System")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.xLarge)

                    // Description
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Text("About")
                            .font(Theme.Typography.title3)

                        Text("PEWS is a weather crisis prediction app that uses machine learning to analyze weather patterns and predict potential crises. It provides real-time risk assessments, forecasts, and customizable alerts to help you stay prepared.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal)

                    // Features
                    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                        Text("Features")
                            .font(Theme.Typography.title3)

                        FeatureRow(icon: "gauge.medium", title: "Risk Assessment", description: "Real-time crisis risk scoring")
                        FeatureRow(icon: "brain", title: "ML Predictions", description: "CoreML-powered weather analysis")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Trend Analysis", description: "Historical weather data charts")
                        FeatureRow(icon: "bell.badge", title: "Smart Alerts", description: "Customizable threshold notifications")
                    }
                    .padding(.horizontal)

                    // Credits
                    VStack(spacing: Theme.Spacing.small) {
                        Text("Created by Ahmed Magaji Ahmed")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textTertiary)

                        Text("Powered by OpenWeatherMap API")
                            .font(Theme.Typography.caption2)
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .padding(.top, Theme.Spacing.xLarge)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.Colors.primaryFallback)
                .frame(width: 30)

            VStack(alignment: .leading) {
                Text(title)
                    .font(Theme.Typography.subheadline)
                Text(description)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
    }
}

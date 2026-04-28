// PEWSApp.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import SwiftUI

@main
struct PEWSApp: App {
    @StateObject private var dependencyContainer = DependencyContainer()
    @StateObject private var appState = AppState()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(dependencyContainer)
                        .environmentObject(appState)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environmentObject(dependencyContainer)
                }
            }
            .task {
                await dependencyContainer.initialize()
            }
        }
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .dashboard
    @Published var isOffline: Bool = false

    enum AppTab: Int, CaseIterable {
        case dashboard = 0
        case alerts = 1
        case history = 2
        case settings = 3

        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .alerts:    return "Alerts"
            case .history:   return "History"
            case .settings:  return "Settings"
            }
        }

        var iconName: String {
            switch self {
            case .dashboard: return "gauge.with.dots.needle.33percent"
            case .alerts:    return "bell.badge"
            case .history:   return "chart.xyaxis.line"
            case .settings:  return "gearshape"
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var container: DependencyContainer

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView(
                viewModel: container.makeDashboardViewModel()
            )
            .tabItem {
                Label(
                    AppState.AppTab.dashboard.title,
                    systemImage: AppState.AppTab.dashboard.iconName
                )
            }
            .tag(AppState.AppTab.dashboard)

            AlertsView(
                viewModel: container.makeAlertsViewModel()
            )
            .tabItem {
                Label(
                    AppState.AppTab.alerts.title,
                    systemImage: AppState.AppTab.alerts.iconName
                )
            }
            .tag(AppState.AppTab.alerts)

            HistoryView(
                viewModel: container.makeHistoryViewModel()
            )
            .tabItem {
                Label(
                    AppState.AppTab.history.title,
                    systemImage: AppState.AppTab.history.iconName
                )
            }
            .tag(AppState.AppTab.history)

            SettingsView(
                viewModel: container.makeSettingsViewModel()
            )
            .tabItem {
                Label(
                    AppState.AppTab.settings.title,
                    systemImage: AppState.AppTab.settings.iconName
                )
            }
            .tag(AppState.AppTab.settings)
        }
        .tint(Theme.Colors.primaryFallback)
    }
}

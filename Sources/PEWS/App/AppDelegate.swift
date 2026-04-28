// AppDelegate.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import UIKit
import BackgroundTasks

/// App delegate handling lifecycle events and background task registration.
class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Logger.info("Application did finish launching")
        registerBackgroundTasks()
        return true
    }

    // MARK: - Background Tasks

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Constants.BackgroundTasks.weatherRefresh,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            self.handleWeatherRefresh(task: refreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Constants.BackgroundTasks.predictionUpdate,
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            self.handlePredictionUpdate(task: processingTask)
        }
    }

    private func handleWeatherRefresh(task: BGAppRefreshTask) {
        Logger.info("Handling background weather refresh")
        task.expirationHandler = {
            Logger.warning("Background weather refresh expired")
        }
        // Background fetch logic delegated to BackgroundFetchService
        task.setTaskCompleted(success: true)
    }

    private func handlePredictionUpdate(task: BGProcessingTask) {
        Logger.info("Handling background prediction update")
        task.expirationHandler = {
            Logger.warning("Background prediction update expired")
        }
        task.setTaskCompleted(success: true)
    }
}

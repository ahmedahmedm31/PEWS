// BackgroundTaskManager.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import BackgroundTasks

/// Manages background fetch tasks for periodic weather data updates and alert checking.
@MainActor
final class BackgroundTaskManager {

    // MARK: - Task Identifiers

    static let weatherRefreshIdentifier = "com.pews.weather.refresh"
    static let alertCheckIdentifier = "com.pews.alert.check"

    // MARK: - Properties

    static let shared = BackgroundTaskManager()
    private var weatherRepository: WeatherRepositoryInterface?
    private var predictionRepository: PredictionRepositoryInterface?
    private var alertRepository: AlertRepositoryInterface?

    private init() {}

    // MARK: - Setup

    /// Configures the background task manager with required dependencies.
    func configure(
        weatherRepository: WeatherRepositoryInterface,
        predictionRepository: PredictionRepositoryInterface,
        alertRepository: AlertRepositoryInterface
    ) {
        self.weatherRepository = weatherRepository
        self.predictionRepository = predictionRepository
        self.alertRepository = alertRepository
    }

    /// Registers background tasks with the system.
    func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.weatherRefreshIdentifier,
            using: nil
        ) { [weak self] task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            Task { @MainActor in
                self?.handleWeatherRefresh(task: refreshTask)
            }
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.alertCheckIdentifier,
            using: nil
        ) { [weak self] task in
            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            Task { @MainActor in
                self?.handleAlertCheck(task: processingTask)
            }
        }

        Logger.info("Background tasks registered")
    }

    // MARK: - Scheduling

    /// Schedules the next weather refresh background task.
    func scheduleWeatherRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.weatherRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.info("Weather refresh scheduled")
        } catch {
            Logger.error("Failed to schedule weather refresh", error: error)
        }
    }

    /// Schedules the next alert check background task.
    func scheduleAlertCheck() {
        let request = BGProcessingTaskRequest(identifier: Self.alertCheckIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        request.requiresNetworkConnectivity = true

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.info("Alert check scheduled")
        } catch {
            Logger.error("Failed to schedule alert check", error: error)
        }
    }

    // MARK: - Task Handlers

    private func handleWeatherRefresh(task: BGAppRefreshTask) {
        Logger.info("Background weather refresh started")
        scheduleWeatherRefresh()

        let refreshWork = Task {
            do {
                guard let weatherRepo = weatherRepository else {
                    task.setTaskCompleted(success: false)
                    return
                }

                let location = Location.defaultLocation()
                let weather = try await weatherRepo.fetchCurrentWeather(for: location)

                if let predictionRepo = predictionRepository,
                   let alertRepo = alertRepository {
                    let prediction = try await predictionRepo.predictCrisis(for: weather)
                    let threshold = alertRepo.getAlertThreshold()

                    if prediction.riskScore >= threshold {
                        let alert = Alert(
                            id: UUID().uuidString,
                            locationID: location.id,
                            locationName: location.name,
                            riskScore: prediction.riskScore,
                            riskLevel: prediction.riskLevel,
                            title: "\(prediction.riskLevel.displayName) Risk: \(location.name)",
                            message: "Risk score: \(prediction.riskScore)/100. \(prediction.riskLevel.description)",
                            timestamp: Date(),
                            isRead: false,
                            isAcknowledged: false
                        )

                        try await alertRepo.createAlert(alert)
                        NotificationManager.shared.scheduleAlertNotification(alert)
                    }
                }

                task.setTaskCompleted(success: true)
                Logger.info("Background weather refresh completed")
            } catch {
                Logger.error("Background weather refresh failed", error: error)
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            refreshWork.cancel()
        }
    }

    private func handleAlertCheck(task: BGProcessingTask) {
        Logger.info("Background alert check started")
        scheduleAlertCheck()

        let checkWork = Task {
            do {
                guard let weatherRepo = weatherRepository,
                      let predictionRepo = predictionRepository,
                      let alertRepo = alertRepository else {
                    task.setTaskCompleted(success: false)
                    return
                }

                let locations = try await (weatherRepo as? WeatherRepository)?.locationRepository.fetchLocations() ?? []

                for location in locations {
                    let weather = try await weatherRepo.fetchCurrentWeather(for: location)
                    let prediction = try await predictionRepo.predictCrisis(for: weather)
                    let threshold = alertRepo.getAlertThreshold()

                    if prediction.riskScore >= threshold {
                        let alert = Alert(
                            id: UUID().uuidString,
                            locationID: location.id,
                            locationName: location.name,
                            riskScore: prediction.riskScore,
                            riskLevel: prediction.riskLevel,
                            title: "\(prediction.riskLevel.displayName) Risk: \(location.name)",
                            message: "Risk score: \(prediction.riskScore)/100.",
                            timestamp: Date(),
                            isRead: false,
                            isAcknowledged: false
                        )
                        try await alertRepo.createAlert(alert)
                        NotificationManager.shared.scheduleAlertNotification(alert)
                    }
                }

                task.setTaskCompleted(success: true)
                Logger.info("Background alert check completed")
            } catch {
                Logger.error("Background alert check failed", error: error)
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            checkWork.cancel()
        }
    }
}

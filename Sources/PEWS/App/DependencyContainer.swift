// DependencyContainer.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI

/// Central dependency container managing all service and repository instances.
/// Follows the Composition Root pattern for dependency injection.
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Infrastructure

    private lazy var networkClient: NetworkClient = {
        NetworkClient()
    }()

    private lazy var cacheManager: CacheManager = {
        CacheManager()
    }()

    private lazy var coreDataManager: CoreDataManager = {
        CoreDataManager()
    }()

    private lazy var userDefaultsManager: UserDefaultsManager = {
        UserDefaultsManager()
    }()

    // MARK: - Data Sources

    private lazy var weatherAPIService: WeatherAPIService = {
        WeatherAPIService(networkClient: networkClient)
    }()

    // MARK: - Repositories

    private lazy var weatherRepository: WeatherRepository = {
        WeatherRepository(
            remoteDataSource: weatherAPIService,
            cacheManager: cacheManager
        )
    }()

    private lazy var locationRepository: LocationRepository = {
        LocationRepository(coreDataManager: coreDataManager)
    }()

    private lazy var alertRepository: AlertRepository = {
        AlertRepository(
            coreDataManager: coreDataManager,
            userDefaultsManager: userDefaultsManager
        )
    }()

    private lazy var predictionRepository: PredictionRepository = {
        PredictionRepository(
            predictionEngine: predictionEngine,
            weatherRepository: weatherRepository
        )
    }()

    // MARK: - ML

    private lazy var predictionEngine: PredictionEngine = {
        PredictionEngine()
    }()

    // MARK: - Use Cases

    private func makeFetchCurrentWeatherUseCase() -> FetchCurrentWeatherUseCase {
        FetchCurrentWeatherUseCase(repository: weatherRepository)
    }

    private func makeFetchForecastUseCase() -> FetchForecastUseCase {
        FetchForecastUseCase(repository: weatherRepository)
    }

    private func makePredictCrisisUseCase() -> PredictCrisisUseCase {
        PredictCrisisUseCase(repository: predictionRepository)
    }

    private func makeCalculateRiskScoreUseCase() -> CalculateRiskScoreUseCase {
        CalculateRiskScoreUseCase()
    }

    private func makeFetchAlertsUseCase() -> FetchAlertsUseCase {
        FetchAlertsUseCase(repository: alertRepository)
    }

    private func makeCreateAlertUseCase() -> CreateAlertUseCase {
        CreateAlertUseCase(repository: alertRepository)
    }

    private func makeUpdateAlertThresholdUseCase() -> UpdateAlertThresholdUseCase {
        UpdateAlertThresholdUseCase(repository: alertRepository)
    }

    private func makeFetchLocationsUseCase() -> FetchLocationsUseCase {
        FetchLocationsUseCase(repository: locationRepository)
    }

    private func makeAddLocationUseCase() -> AddLocationUseCase {
        AddLocationUseCase(repository: locationRepository)
    }

    private func makeRemoveLocationUseCase() -> RemoveLocationUseCase {
        RemoveLocationUseCase(repository: locationRepository)
    }

    private func makeGenerateReportUseCase() -> GenerateReportUseCase {
        GenerateReportUseCase(
            weatherRepository: weatherRepository,
            predictionRepository: predictionRepository
        )
    }

    // MARK: - ViewModel Factories

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchWeatherUseCase: makeFetchCurrentWeatherUseCase(),
            fetchForecastUseCase: makeFetchForecastUseCase(),
            predictCrisisUseCase: makePredictCrisisUseCase(),
            calculateRiskScoreUseCase: makeCalculateRiskScoreUseCase(),
            fetchLocationsUseCase: makeFetchLocationsUseCase()
        )
    }

    func makeAlertsViewModel() -> AlertsViewModel {
        AlertsViewModel(
            fetchAlertsUseCase: makeFetchAlertsUseCase(),
            createAlertUseCase: makeCreateAlertUseCase(),
            updateThresholdUseCase: makeUpdateAlertThresholdUseCase()
        )
    }

    func makeHistoryViewModel(location: Location = .defaultLocation()) -> HistoryViewModel {
        HistoryViewModel(
            weatherRepository: weatherRepository,
            generateReportUseCase: makeGenerateReportUseCase(),
            location: location
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            userDefaults: userDefaultsManager,
            cacheManager: cacheManager
        )
    }

    // MARK: - Initialization

    func initialize() async {
        Logger.info("Initializing DependencyContainer")
        coreDataManager.setup()
    }
}

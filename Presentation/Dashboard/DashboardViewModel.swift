// DashboardViewModel.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import SwiftUI

/// ViewModel managing the Dashboard screen state and data.
/// Coordinates weather fetching, forecast loading, and risk prediction.
@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var currentWeather: WeatherData?
    @Published private(set) var forecast: [Forecast] = []
    @Published private(set) var prediction: Prediction?
    @Published private(set) var riskLevel: RiskLevel = .unknown
    @Published private(set) var riskScore: Int = 0
    @Published var selectedLocation: Location = Location.defaultLocation()
    @Published private(set) var locations: [Location] = []
    @Published private(set) var lastUpdated: Date?

    // MARK: - Dependencies

    private let fetchWeatherUseCase: FetchCurrentWeatherUseCase
    private let fetchForecastUseCase: FetchForecastUseCase
    private let predictCrisisUseCase: PredictCrisisUseCase
    private let calculateRiskScoreUseCase: CalculateRiskScoreUseCase
    private let fetchLocationsUseCase: FetchLocationsUseCase

    // MARK: - Initialization

    init(
        fetchWeatherUseCase: FetchCurrentWeatherUseCase,
        fetchForecastUseCase: FetchForecastUseCase,
        predictCrisisUseCase: PredictCrisisUseCase,
        calculateRiskScoreUseCase: CalculateRiskScoreUseCase,
        fetchLocationsUseCase: FetchLocationsUseCase
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.fetchForecastUseCase = fetchForecastUseCase
        self.predictCrisisUseCase = predictCrisisUseCase
        self.calculateRiskScoreUseCase = calculateRiskScoreUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }

    // MARK: - Public Methods

    /// Loads all dashboard data (weather, forecast, prediction) in parallel.
    func loadData() async {
        state = .loading

        do {
            // Load locations
            locations = try await fetchLocationsUseCase.execute()
            if locations.isEmpty {
                locations = [Location.defaultLocation()]
            }

            // Parallel fetch weather and forecast
            async let weatherTask = fetchWeatherUseCase.execute(location: selectedLocation)
            async let forecastTask = fetchForecastUseCase.execute(location: selectedLocation)

            let (weather, forecastData) = try await (weatherTask, forecastTask)

            currentWeather = weather
            forecast = forecastData

            // Calculate risk score
            riskScore = calculateRiskScoreUseCase.execute(weatherData: weather)
            riskLevel = RiskLevel.fromScore(riskScore)

            // Generate prediction
            prediction = try await predictCrisisUseCase.execute(weatherData: weather)

            lastUpdated = Date()
            state = .loaded

            Logger.ui("Dashboard loaded: \(weather.location.name), risk=\(riskScore)")
        } catch {
            Logger.error("Dashboard load failed", error: error)
            state = .error(error.localizedDescription)
        }
    }

    /// Refreshes dashboard data (triggered by pull-to-refresh).
    func refresh() async {
        await loadData()
    }

    /// Selects a new location and reloads data.
    func selectLocation(_ location: Location) async {
        selectedLocation = location
        await loadData()
    }

    /// Returns the error message if in error state.
    var errorMessage: String? {
        if case .error(let message) = state {
            return message
        }
        return nil
    }

    /// Returns the formatted last updated time.
    var lastUpdatedString: String {
        guard let lastUpdated = lastUpdated else { return "Never" }
        return "Updated \(lastUpdated.relativeDescription)"
    }
}

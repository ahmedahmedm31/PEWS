// DashboardViewModelTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

@MainActor
final class DashboardViewModelTests: XCTestCase {

    private var sut: DashboardViewModel!
    private var mockWeatherRepo: MockWeatherRepository!
    private var mockPredictionRepo: MockPredictionRepository!
    private var mockAlertRepo: MockAlertRepository!
    private var mockLocationRepo: MockLocationRepository!

    override func setUp() {
        super.setUp()
        mockWeatherRepo = MockWeatherRepository()
        mockPredictionRepo = MockPredictionRepository()
        mockAlertRepo = MockAlertRepository()
        mockLocationRepo = MockLocationRepository()

        sut = DashboardViewModel(
            fetchWeatherUseCase: FetchCurrentWeatherUseCase(repository: mockWeatherRepo),
            fetchForecastUseCase: FetchForecastUseCase(repository: mockWeatherRepo),
            predictCrisisUseCase: PredictCrisisUseCase(repository: mockPredictionRepo),
            calculateRiskScoreUseCase: CalculateRiskScoreUseCase(),
            fetchLocationsUseCase: FetchLocationsUseCase(repository: mockLocationRepo)
        )
    }

    override func tearDown() {
        sut = nil
        mockWeatherRepo = nil
        mockPredictionRepo = nil
        mockAlertRepo = nil
        mockLocationRepo = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertNil(sut.currentWeather)
        XCTAssertNil(sut.prediction)
    }

    // MARK: - Load Data Success

    func testLoadDataSuccess() async {
        let mockWeather = WeatherData.mock()
        let mockPrediction = Prediction.mock()
        let mockLocation = Location.mock()

        mockWeatherRepo.stubbedWeatherData = mockWeather
        mockPredictionRepo.stubbedPrediction = mockPrediction
        mockLocationRepo.stubbedLocations = [mockLocation]
        mockWeatherRepo.stubbedForecasts = [Forecast.mock()]

        await sut.loadData()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertNotNil(sut.currentWeather)
        XCTAssertNotNil(sut.prediction)
        XCTAssertEqual(mockWeatherRepo.fetchCurrentWeatherCallCount, 1)
    }

    // MARK: - Load Data Error

    func testLoadDataNetworkError() async {
        mockWeatherRepo.stubbedError = WeatherError.networkUnavailable
        mockLocationRepo.stubbedLocations = [Location.mock()]

        await sut.loadData()

        XCTAssertTrue(sut.state.isError)
    }

    // MARK: - Refresh

    func testRefreshReloadsData() async {
        mockWeatherRepo.stubbedWeatherData = WeatherData.mock()
        mockPredictionRepo.stubbedPrediction = Prediction.mock()
        mockLocationRepo.stubbedLocations = [Location.mock()]
        mockWeatherRepo.stubbedForecasts = [Forecast.mock()]

        await sut.refresh()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(mockWeatherRepo.fetchCurrentWeatherCallCount, 1)
    }
}

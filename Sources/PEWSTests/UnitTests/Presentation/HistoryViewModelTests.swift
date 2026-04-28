// HistoryViewModelTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

@MainActor
final class HistoryViewModelTests: XCTestCase {

    private var sut: HistoryViewModel!
    private var mockWeatherRepo: MockWeatherRepository!
    private var mockPredictionRepo: MockPredictionRepository!

    override func setUp() {
        super.setUp()
        mockWeatherRepo = MockWeatherRepository()
        mockPredictionRepo = MockPredictionRepository()

        sut = HistoryViewModel(
            weatherRepository: mockWeatherRepo,
            generateReportUseCase: GenerateReportUseCase(
                weatherRepository: mockWeatherRepo,
                predictionRepository: mockPredictionRepo
            ),
            location: Location.mock()
        )
    }

    override func tearDown() {
        sut = nil
        mockWeatherRepo = nil
        mockPredictionRepo = nil
        super.tearDown()
    }

    // MARK: - Load Data Tests

    func testLoadDataSuccess() async {
        mockWeatherRepo.stubbedHistoricalData = [
            WeatherData.mock(),
            WeatherData.mock()
        ]

        await sut.loadData()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.historicalData.count, 2)
    }

    func testLoadDataEmpty() async {
        mockWeatherRepo.stubbedHistoricalData = []

        await sut.loadData()

        XCTAssertEqual(sut.state, .empty)
    }

    func testLoadDataError() async {
        mockWeatherRepo.stubbedError = WeatherError.networkUnavailable

        await sut.loadData()

        XCTAssertTrue(sut.state.isError)
    }

    // MARK: - Statistics Tests

    func testStatisticsWithData() async {
        mockWeatherRepo.stubbedHistoricalData = [
            WeatherData(
                id: "1", location: Location.mock(),
                temperature: 10, feelsLike: 10, tempMin: 8, tempMax: 12,
                humidity: 50, pressure: 1010, windSpeed: 5, windDirection: 180,
                windGust: nil, cloudCoverage: 30, visibility: 10000,
                precipitation: 0, uvIndex: 3, condition: .clear, iconCode: "01d",
                sunrise: Date(), sunset: Date(), timestamp: Date(), timezone: 0
            ),
            WeatherData(
                id: "2", location: Location.mock(),
                temperature: 20, feelsLike: 20, tempMin: 18, tempMax: 22,
                humidity: 70, pressure: 1015, windSpeed: 10, windDirection: 270,
                windGust: nil, cloudCoverage: 50, visibility: 8000,
                precipitation: 2, uvIndex: 5, condition: .partlyCloudy, iconCode: "02d",
                sunrise: Date(), sunset: Date(), timestamp: Date(), timezone: 0
            )
        ]

        await sut.loadData()

        let stats = sut.statistics
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.avgTemperature, 15.0, accuracy: 0.1)
        XCTAssertEqual(stats?.maxTemperature, 20.0, accuracy: 0.1)
        XCTAssertEqual(stats?.minTemperature, 10.0, accuracy: 0.1)
        XCTAssertEqual(stats?.recordCount, 2)
    }

    func testStatisticsWithNoData() {
        XCTAssertNil(sut.statistics)
    }

    // MARK: - Chart Type Tests

    func testChartTypeSelection() async {
        mockWeatherRepo.stubbedHistoricalData = [WeatherData.mock()]
        await sut.loadData()

        sut.selectedChartType = .temperature
        XCTAssertFalse(sut.currentDataPoints.isEmpty)

        sut.selectedChartType = .humidity
        XCTAssertFalse(sut.currentDataPoints.isEmpty)

        sut.selectedChartType = .pressure
        XCTAssertFalse(sut.currentDataPoints.isEmpty)

        sut.selectedChartType = .wind
        XCTAssertFalse(sut.currentDataPoints.isEmpty)
    }
}

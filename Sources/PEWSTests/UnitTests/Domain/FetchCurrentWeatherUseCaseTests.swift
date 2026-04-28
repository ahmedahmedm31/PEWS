// FetchCurrentWeatherUseCaseTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class FetchCurrentWeatherUseCaseTests: XCTestCase {

    private var sut: FetchCurrentWeatherUseCase!
    private var mockRepository: MockWeatherRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockWeatherRepository()
        sut = FetchCurrentWeatherUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testExecuteReturnsWeatherData() async throws {
        let expectedWeather = WeatherData.mock()
        mockRepository.stubbedWeatherData = expectedWeather

        let result = try await sut.execute(location: Location.mock())

        XCTAssertEqual(result.temperature, expectedWeather.temperature)
        XCTAssertEqual(result.humidity, expectedWeather.humidity)
        XCTAssertEqual(mockRepository.fetchCurrentWeatherCallCount, 1)
    }

    // MARK: - Error Tests

    func testExecuteThrowsOnRepositoryError() async {
        mockRepository.stubbedError = WeatherError.networkUnavailable

        do {
            _ = try await sut.execute(location: Location.mock())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is WeatherError)
        }
    }

    // MARK: - Repository Interaction

    func testExecuteCallsRepositoryOnce() async throws {
        mockRepository.stubbedWeatherData = WeatherData.mock()

        _ = try await sut.execute(location: Location.mock())

        XCTAssertEqual(mockRepository.fetchCurrentWeatherCallCount, 1)
    }
}

// LocationUseCaseTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class LocationUseCaseTests: XCTestCase {

    private var mockRepo: MockLocationRepository!

    override func setUp() {
        super.setUp()
        mockRepo = MockLocationRepository()
    }

    override func tearDown() {
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Add Location Tests

    func testAddLocationSuccess() async throws {
        let sut = AddLocationUseCase(repository: mockRepo)
        let location = Location.mock()

        try await sut.execute(location: location)

        XCTAssertEqual(mockRepo.addLocationCallCount, 1)
        XCTAssertEqual(mockRepo.stubbedLocations.count, 1)
    }

    func testAddLocationMaxReached() async {
        let sut = AddLocationUseCase(repository: mockRepo)

        // Fill up to max
        for i in 0..<5 {
            mockRepo.stubbedLocations.append(
                Location(id: "loc_\(i)", name: "City \(i)", latitude: Double(i),
                         longitude: Double(i), country: "US", state: nil, isDefault: false)
            )
        }

        let newLocation = Location.mock()

        do {
            try await sut.execute(location: newLocation)
            XCTFail("Should throw maxLocationsReached error")
        } catch {
            XCTAssertTrue(error is WeatherError)
        }
    }

    // MARK: - Remove Location Tests

    func testRemoveLocationSuccess() async throws {
        let sut = RemoveLocationUseCase(repository: mockRepo)
        let location = Location.mock()
        mockRepo.stubbedLocations = [location]

        try await sut.execute(id: location.id)

        XCTAssertEqual(mockRepo.removeLocationCallCount, 1)
    }

    // MARK: - Fetch Locations Tests

    func testFetchLocationsSuccess() async throws {
        let sut = FetchLocationsUseCase(repository: mockRepo)
        mockRepo.stubbedLocations = [Location.mock()]

        let locations = try await sut.execute()

        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(mockRepo.fetchLocationsCallCount, 1)
    }

    func testFetchLocationsEmpty() async throws {
        let sut = FetchLocationsUseCase(repository: mockRepo)
        mockRepo.stubbedLocations = []

        let locations = try await sut.execute()

        XCTAssertTrue(locations.isEmpty)
    }
}

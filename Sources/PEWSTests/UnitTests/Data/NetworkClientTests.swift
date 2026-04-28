// NetworkClientTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class NetworkClientTests: XCTestCase {

    // MARK: - Endpoint Tests

    func testCurrentWeatherEndpoint() {
        let request = WeatherRequestDTO(latitude: 51.5, longitude: -0.12)
        let endpoint = Endpoint.currentWeather(request)

        guard let url = endpoint.url else {
            XCTFail("URL should not be nil")
            return
        }

        let urlString = url.absoluteString
        XCTAssertTrue(urlString.contains("weather"), "Should contain 'weather' path")
        XCTAssertTrue(urlString.contains("lat="), "Should contain latitude")
        XCTAssertTrue(urlString.contains("lon="), "Should contain longitude")
        XCTAssertTrue(urlString.contains("units=metric"), "Should use metric units")
    }

    func testForecastEndpoint() {
        let request = WeatherRequestDTO(latitude: 40.7, longitude: -74.0)
        let endpoint = Endpoint.forecast(request)

        guard let url = endpoint.url else {
            XCTFail("URL should not be nil")
            return
        }

        let urlString = url.absoluteString
        XCTAssertTrue(urlString.contains("forecast"), "Should contain 'forecast' path")
        XCTAssertTrue(urlString.contains("lat="), "Should contain latitude")
        XCTAssertTrue(urlString.contains("lon="), "Should contain longitude")
    }

    func testGeocodingEndpoint() {
        let request = GeocodingRequestDTO(query: "London", limit: 5)
        let endpoint = Endpoint.geocoding(request)

        guard let url = endpoint.url else {
            XCTFail("URL should not be nil")
            return
        }

        let urlString = url.absoluteString
        XCTAssertTrue(urlString.contains("geo"), "Should contain 'geo' path")
        XCTAssertTrue(urlString.contains("London"), "Should contain query")
        XCTAssertTrue(urlString.contains("limit=5"), "Should contain limit")
    }

    func testEndpointURLRequestNotNil() {
        let request = WeatherRequestDTO(latitude: 51.5, longitude: -0.12)
        let endpoint = Endpoint.currentWeather(request)

        XCTAssertNotNil(endpoint.urlRequest, "URL request should not be nil")
        XCTAssertEqual(endpoint.urlRequest?.httpMethod, "GET")
    }

    // MARK: - API Error Tests

    func testAPIErrorDescriptions() {
        let errors: [APIError] = [
            .invalidURL,
            .noData,
            .decodingFailed,
            .httpError(statusCode: 401),
            .httpError(statusCode: 429),
            .httpError(statusCode: 500),
            .networkError(NSError(domain: "test", code: -1009)),
            .rateLimited
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error should have a description: \(error)")
        }
    }

    func testHTTPError401IsUnauthorized() {
        let error = APIError.httpError(statusCode: 401)
        XCTAssertTrue(error.errorDescription?.lowercased().contains("unauthorized") ?? false
                      || error.errorDescription?.lowercased().contains("api key") ?? false)
    }

    func testHTTPError429IsRateLimited() {
        let error = APIError.httpError(statusCode: 429)
        XCTAssertTrue(error.errorDescription?.lowercased().contains("rate") ?? false)
    }
}

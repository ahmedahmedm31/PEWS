// FormattersTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class FormattersTests: XCTestCase {

    // MARK: - Temperature Formatter

    func testTemperatureFormatterDecimalPlaces() {
        let result = Formatters.temperature.string(from: NSNumber(value: 25.567))
        XCTAssertNotNil(result)
        // Should have at most 1 decimal place
        XCTAssertTrue(result?.contains("25.6") ?? false || result?.contains("25,6") ?? false)
    }

    func testTemperatureFormatterWholeNumber() {
        let result = Formatters.temperature.string(from: NSNumber(value: 25.0))
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("25") ?? false)
    }

    // MARK: - Percentage Formatter

    func testPercentageFormatter() {
        // NumberFormatter with .percent style expects 0.75 for 75%
        let result = Formatters.percentage.string(from: NSNumber(value: 0.755))
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("76") ?? false || result?.contains("75") ?? false)
        XCTAssertTrue(result?.contains("%") ?? false)
    }

    // MARK: - Pressure Formatter

    func testPressureFormatter() {
        let result = Formatters.pressure.string(from: NSNumber(value: 1013.25))
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("1013") ?? false)
        XCTAssertTrue(result?.contains("hPa") ?? false)
    }

    // MARK: - Date Formatters

    func testDisplayDateFormatter() {
        let date = Date()
        let result = Formatters.displayDate.string(from: date)
        XCTAssertFalse(result.isEmpty)
    }

    func testDisplayTimeFormatter() {
        let date = Date()
        let result = Formatters.displayTime.string(from: date)
        XCTAssertFalse(result.isEmpty)
    }

    func testDisplayDateTimeFormatter() {
        let date = Date()
        let result = Formatters.displayDateTime.string(from: date)
        XCTAssertFalse(result.isEmpty)
    }

    func testISO8601Formatter() {
        let date = Date(timeIntervalSince1970: 1000000)
        let result = Formatters.iso8601.string(from: date)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains("T"))
    }

    func testDayOfWeekFormatter() {
        let date = Date()
        let result = Formatters.dayOfWeek.string(from: date)
        XCTAssertFalse(result.isEmpty)
    }

    func testShortDayOfWeekFormatter() {
        let date = Date()
        let result = Formatters.shortDayOfWeek.string(from: date)
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.count <= 3)
    }

    func testHourFormatter() {
        let date = Date()
        let result = Formatters.hourFormatter.string(from: date)
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Risk Score Formatter

    func testRiskScoreFormatter() {
        let result = Formatters.riskScore.string(from: NSNumber(value: 72.8))
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.contains("73") ?? false)
    }
}

// ExtensionsTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class ExtensionsTests: XCTestCase {

    // MARK: - Date Extensions

    func testDateStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay
        let calendar = Calendar.current

        XCTAssertEqual(calendar.component(.hour, from: startOfDay), 0)
        XCTAssertEqual(calendar.component(.minute, from: startOfDay), 0)
        XCTAssertEqual(calendar.component(.second, from: startOfDay), 0)
    }

    func testDateRelativeDescription() {
        let now = Date()
        let description = now.relativeDescription
        XCTAssertFalse(description.isEmpty)
    }

    func testDateShortTimeString() {
        let date = Date()
        let timeString = date.shortTimeString
        XCTAssertFalse(timeString.isEmpty)
    }

    func testDateShortDateString() {
        let date = Date()
        let dateString = date.shortDateString
        XCTAssertFalse(dateString.isEmpty)
    }

    func testDateDayOfWeekAbbreviation() {
        let date = Date()
        let dayString = date.dayOfWeekAbbreviation
        XCTAssertFalse(dayString.isEmpty)
        XCTAssertTrue(dayString.count <= 3)
    }

    func testDateHoursSince() {
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200)
        let hours = now.hoursSince(twoHoursAgo)
        XCTAssertEqual(hours, 2.0, accuracy: 0.01)
    }

    func testDateIsWithinMinutes() {
        let recentDate = Date().addingTimeInterval(-30) // 30 seconds ago
        XCTAssertTrue(recentDate.isWithinMinutes(1))

        let oldDate = Date().addingTimeInterval(-300) // 5 minutes ago
        XCTAssertFalse(oldDate.isWithinMinutes(1))
    }

    func testDateUnixTimestamp() {
        let date = Date(timeIntervalSince1970: 1000000)
        XCTAssertEqual(date.unixTimestamp, 1000000)
    }

    func testDateFromUnixTimestamp() {
        let date = Date.fromUnixTimestamp(1000000)
        XCTAssertEqual(date.timeIntervalSince1970, 1000000, accuracy: 0.001)
    }

    // MARK: - Double Extensions

    func testDoubleCelsiusToFahrenheit() {
        let celsius: Double = 0
        let fahrenheit = celsius.celsiusToFahrenheit
        XCTAssertEqual(fahrenheit, 32, accuracy: 0.1)
    }

    func testDoubleFahrenheitToCelsius() {
        let fahrenheit: Double = 212
        let celsius = fahrenheit.fahrenheitToCelsius
        XCTAssertEqual(celsius, 100, accuracy: 0.1)
    }

    func testDoubleRoundedToPlaces() {
        let value: Double = 3.14159
        XCTAssertEqual(value.rounded(toPlaces: 2), 3.14, accuracy: 0.001)
        XCTAssertEqual(value.rounded(toPlaces: 0), 3.0, accuracy: 0.001)
    }

    // MARK: - RiskLevel Tests

    func testRiskLevelFromScore() {
        XCTAssertEqual(RiskLevel.fromScore(10), .low)
        XCTAssertEqual(RiskLevel.fromScore(25), .low)
        XCTAssertEqual(RiskLevel.fromScore(26), .moderate)
        XCTAssertEqual(RiskLevel.fromScore(50), .moderate)
        XCTAssertEqual(RiskLevel.fromScore(51), .high)
        XCTAssertEqual(RiskLevel.fromScore(75), .high)
        XCTAssertEqual(RiskLevel.fromScore(76), .critical)
        XCTAssertEqual(RiskLevel.fromScore(100), .critical)
    }

    func testRiskLevelDisplayName() {
        XCTAssertEqual(RiskLevel.low.displayName, "Low")
        XCTAssertEqual(RiskLevel.moderate.displayName, "Moderate")
        XCTAssertEqual(RiskLevel.high.displayName, "High")
        XCTAssertEqual(RiskLevel.critical.displayName, "Critical")
    }

    func testRiskLevelComparable() {
        XCTAssertTrue(RiskLevel.low < RiskLevel.moderate)
        XCTAssertTrue(RiskLevel.moderate < RiskLevel.high)
        XCTAssertTrue(RiskLevel.high < RiskLevel.critical)
    }
}

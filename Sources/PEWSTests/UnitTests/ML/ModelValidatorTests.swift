// ModelValidatorTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

final class ModelValidatorTests: XCTestCase {

    private var sut: ModelValidator!

    override func setUp() {
        super.setUp()
        sut = ModelValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Empty State

    func testAccuracyWithNoRecords() async {
        let accuracy = await sut.accuracy
        XCTAssertEqual(accuracy, 0)
    }

    func testPrecisionWithNoRecords() async {
        let precision = await sut.precision
        XCTAssertEqual(precision, 0)
    }

    func testRecallWithNoRecords() async {
        let recall = await sut.recall
        XCTAssertEqual(recall, 0)
    }

    func testF1ScoreWithNoRecords() async {
        let f1 = await sut.f1Score
        XCTAssertEqual(f1, 0)
    }

    // MARK: - Perfect Predictions

    func testPerfectAccuracy() async {
        await sut.record(predicted: 0.8, actual: true)
        await sut.record(predicted: 0.9, actual: true)
        await sut.record(predicted: 0.2, actual: false)
        await sut.record(predicted: 0.1, actual: false)

        let accuracy = await sut.accuracy
        XCTAssertEqual(accuracy, 1.0, accuracy: 0.001)
    }

    func testPerfectPrecision() async {
        await sut.record(predicted: 0.8, actual: true)
        await sut.record(predicted: 0.7, actual: true)

        let precision = await sut.precision
        XCTAssertEqual(precision, 1.0, accuracy: 0.001)
    }

    func testPerfectRecall() async {
        await sut.record(predicted: 0.8, actual: true)
        await sut.record(predicted: 0.6, actual: true)

        let recall = await sut.recall
        XCTAssertEqual(recall, 1.0, accuracy: 0.001)
    }

    // MARK: - Imperfect Predictions

    func testMixedAccuracy() async {
        await sut.record(predicted: 0.8, actual: true)   // TP
        await sut.record(predicted: 0.3, actual: false)   // TN
        await sut.record(predicted: 0.7, actual: false)   // FP
        await sut.record(predicted: 0.2, actual: true)    // FN

        let accuracy = await sut.accuracy
        XCTAssertEqual(accuracy, 0.5, accuracy: 0.001)
    }

    // MARK: - Mean Absolute Error

    func testMeanAbsoluteError() async {
        await sut.record(predicted: 0.8, actual: true)   // Error: 0.2
        await sut.record(predicted: 0.3, actual: false)  // Error: 0.3

        let mae = await sut.meanAbsoluteError
        XCTAssertEqual(mae, 0.25, accuracy: 0.001)
    }

    // MARK: - Metrics Summary

    func testMetricsSummaryContainsAllKeys() async {
        await sut.record(predicted: 0.8, actual: true)

        let summary = await sut.metricsSummary

        XCTAssertNotNil(summary["accuracy"])
        XCTAssertNotNil(summary["precision"])
        XCTAssertNotNil(summary["recall"])
        XCTAssertNotNil(summary["f1Score"])
        XCTAssertNotNil(summary["meanAbsoluteError"])
        XCTAssertNotNil(summary["recordCount"])
    }

    // MARK: - Retraining

    func testNeedsRetrainingWithFewRecords() async {
        for _ in 0..<10 {
            await sut.record(predicted: 0.8, actual: false) // All wrong
        }
        let needs = await sut.needsRetraining
        XCTAssertFalse(needs, "Should not need retraining with < 50 records")
    }

    // MARK: - Clear Records

    func testClearRecords() async {
        await sut.record(predicted: 0.8, actual: true)
        await sut.record(predicted: 0.3, actual: false)

        await sut.clearRecords()

        let accuracy = await sut.accuracy
        XCTAssertEqual(accuracy, 0)
    }
}

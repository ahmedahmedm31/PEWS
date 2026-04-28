// AlertsViewModelTests.swift
// PEWS Tests
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import XCTest
@testable import PEWS

@MainActor
final class AlertsViewModelTests: XCTestCase {

    private var sut: AlertsViewModel!
    private var mockAlertRepo: MockAlertRepository!

    override func setUp() {
        super.setUp()
        mockAlertRepo = MockAlertRepository()

        sut = AlertsViewModel(
            fetchAlertsUseCase: FetchAlertsUseCase(repository: mockAlertRepo),
            createAlertUseCase: CreateAlertUseCase(repository: mockAlertRepo),
            updateThresholdUseCase: UpdateAlertThresholdUseCase(repository: mockAlertRepo)
        )
    }

    override func tearDown() {
        sut = nil
        mockAlertRepo = nil
        super.tearDown()
    }

    // MARK: - Load Tests

    func testLoadAlertsEmpty() async {
        mockAlertRepo.stubbedAlerts = []

        await sut.loadAlerts()

        XCTAssertEqual(sut.state, .empty)
        XCTAssertTrue(sut.alerts.isEmpty)
    }

    func testLoadAlertsWithData() async {
        let unreadAlert = Alert.mock()
        var readAlert = Alert.mock()
        readAlert.isRead = true
        mockAlertRepo.stubbedAlerts = [unreadAlert, readAlert]

        await sut.loadAlerts()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.alerts.count, 2)
        XCTAssertEqual(sut.unreadCount, 1)
    }

    // MARK: - Action Tests

    func testDeleteAlert() async {
        let alert = Alert.mock()
        mockAlertRepo.stubbedAlerts = [alert]

        await sut.delete(alert)

        XCTAssertEqual(mockAlertRepo.deleteAlertCallCount, 1)
    }

    func testDeleteAllAlerts() async {
        mockAlertRepo.stubbedAlerts = [Alert.mock(), Alert.mock()]

        await sut.deleteAll()

        XCTAssertEqual(mockAlertRepo.deleteAllCallCount, 1)
    }

    func testAcknowledgeAlert() async {
        let alert = Alert.mock()
        mockAlertRepo.stubbedAlerts = [alert]

        await sut.acknowledge(alert)

        XCTAssertEqual(mockAlertRepo.acknowledgeCallCount, 1)
    }

    // MARK: - Threshold Tests

    func testUpdateThreshold() {
        sut.alertThreshold = 75
        sut.updateThreshold()

        XCTAssertEqual(mockAlertRepo.stubbedThreshold, 75)
    }

    // MARK: - Filter Tests

    func testFilterUnread() async {
        let unreadAlert = Alert.mock()
        var readAlert = Alert.mock()
        readAlert.isRead = true
        mockAlertRepo.stubbedAlerts = [unreadAlert, readAlert]

        sut.filterOption = .unread
        await sut.applyCurrentFilter()

        XCTAssertEqual(sut.alerts.count, 1)
    }
}

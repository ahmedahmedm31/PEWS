// Logger.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import os.log

/// Centralized logging utility for the PEWS application.
/// Uses Apple's unified logging system (os.log) for production-ready logging.
enum Logger {

    // MARK: - Log Categories

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.pews.app"

    private enum Category: String {
        case general = "General"
        case network = "Network"
        case data = "Data"
        case ml = "ML"
        case ui = "UI"
        case location = "Location"
        case notification = "Notification"
    }

    // MARK: - Private Logger Instances

    private static let generalLogger = os.Logger(subsystem: subsystem, category: Category.general.rawValue)
    private static let networkLogger = os.Logger(subsystem: subsystem, category: Category.network.rawValue)
    private static let dataLogger = os.Logger(subsystem: subsystem, category: Category.data.rawValue)
    private static let mlLogger = os.Logger(subsystem: subsystem, category: Category.ml.rawValue)
    private static let uiLogger = os.Logger(subsystem: subsystem, category: Category.ui.rawValue)
    private static let locationLogger = os.Logger(subsystem: subsystem, category: Category.location.rawValue)
    private static let notificationLogger = os.Logger(subsystem: subsystem, category: Category.notification.rawValue)

    // MARK: - General Logging

    /// Logs an informational message.
    static func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.info("ℹ️ \(message) \(context)")
    }

    /// Logs a debug message (only in DEBUG builds).
    static func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.debug("🔍 \(message) \(context)")
        #endif
    }

    /// Logs a warning message.
    static func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = formatContext(file: file, function: function, line: line)
        generalLogger.warning("⚠️ \(message) \(context)")
    }

    /// Logs an error message.
    static func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = formatContext(file: file, function: function, line: line)
        if let error = error {
            generalLogger.error("❌ \(message): \(error.localizedDescription) \(context)")
        } else {
            generalLogger.error("❌ \(message) \(context)")
        }
    }

    // MARK: - Category-Specific Logging

    /// Logs a network-related message.
    static func network(_ message: String) {
        networkLogger.info("🌐 \(message)")
    }

    /// Logs a data/persistence-related message.
    static func data(_ message: String) {
        dataLogger.info("💾 \(message)")
    }

    /// Logs an ML-related message.
    static func ml(_ message: String) {
        mlLogger.info("🤖 \(message)")
    }

    /// Logs a UI-related message.
    static func ui(_ message: String) {
        uiLogger.info("🖥️ \(message)")
    }

    /// Logs a location-related message.
    static func location(_ message: String) {
        locationLogger.info("📍 \(message)")
    }

    /// Logs a notification-related message.
    static func notification(_ message: String) {
        notificationLogger.info("🔔 \(message)")
    }

    // MARK: - Helpers

    private static func formatContext(file: String, function: String, line: Int) -> String {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        return "[\(fileName):\(line) \(function)]"
    }
}

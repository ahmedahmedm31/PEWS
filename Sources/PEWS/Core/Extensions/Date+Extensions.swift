// Date+Extensions.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

extension Date {

    /// Returns a formatted string for display in the UI.
    /// - Parameter style: The date formatter style to use.
    /// - Returns: A localized date string.
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns a short time string (e.g., "3:45 PM").
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Returns a short date string (e.g., "Feb 16").
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Returns the day of week abbreviation (e.g., "Mon").
    var dayOfWeekAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    /// Returns a relative time description (e.g., "5 minutes ago").
    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Returns the date with time components stripped.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the number of hours between this date and another.
    func hoursSince(_ other: Date) -> Double {
        self.timeIntervalSince(other) / 3600
    }

    /// Checks if the date is within the specified number of minutes from now.
    func isWithinMinutes(_ minutes: Int) -> Bool {
        let interval = Date().timeIntervalSince(self)
        return interval < Double(minutes * 60) && interval >= 0
    }

    /// Returns a Unix timestamp integer.
    var unixTimestamp: Int {
        Int(timeIntervalSince1970)
    }

    /// Creates a Date from a Unix timestamp.
    static func fromUnixTimestamp(_ timestamp: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

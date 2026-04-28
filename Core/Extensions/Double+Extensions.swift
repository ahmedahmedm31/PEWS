// Double+Extensions.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

extension Double {

    /// Rounds to specified decimal places.
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Converts Celsius to Fahrenheit.
    var celsiusToFahrenheit: Double {
        (self * 9.0 / 5.0) + 32.0
    }

    /// Converts Fahrenheit to Celsius.
    var fahrenheitToCelsius: Double {
        (self - 32.0) * 5.0 / 9.0
    }

    /// Converts meters per second to kilometers per hour.
    var msToKmh: Double {
        self * 3.6
    }

    /// Converts meters per second to miles per hour.
    var msToMph: Double {
        self * 2.237
    }

    /// Returns a formatted temperature string with degree symbol.
    func temperatureString(unit: TemperatureUnit = .celsius) -> String {
        let value: Double
        let symbol: String
        switch unit {
        case .celsius:
            value = self
            symbol = "°C"
        case .fahrenheit:
            value = self.celsiusToFahrenheit
            symbol = "°F"
        }
        return String(format: "%.0f%@", value, symbol)
    }

    /// Returns a formatted percentage string.
    var percentageString: String {
        String(format: "%.0f%%", self)
    }

    /// Returns a formatted wind speed string.
    func windSpeedString(unit: SpeedUnit = .metersPerSecond) -> String {
        switch unit {
        case .metersPerSecond:
            return String(format: "%.1f m/s", self)
        case .kilometersPerHour:
            return String(format: "%.1f km/h", self.msToKmh)
        case .milesPerHour:
            return String(format: "%.1f mph", self.msToMph)
        case .knots:
            return String(format: "%.1f kn", self * 1.944)
        }
    }

    /// Clamps the value to a specified range.
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

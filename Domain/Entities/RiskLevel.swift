// RiskLevel.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Represents the crisis risk level based on the risk score (0-100).
/// Domain entities should not import SwiftUI; color mapping lives in the
/// presentation layer via `Color.forRiskLevel(_:)`.
enum RiskLevel: String, Codable, CaseIterable, Comparable, Sendable {
    case low
    case moderate
    case high
    case critical
    case unknown

    // MARK: - Factory

    /// Derives a `RiskLevel` from a numeric risk score (0-100).
    static func fromScore(_ score: Int) -> RiskLevel {
        switch score {
        case 0...25:   return .low
        case 26...50:  return .moderate
        case 51...75:  return .high
        case 76...100: return .critical
        default:       return .unknown
        }
    }

    // MARK: - Display Properties

    var displayName: String {
        switch self {
        case .low:      return "Low"
        case .moderate:  return "Moderate"
        case .high:     return "High"
        case .critical: return "Critical"
        case .unknown:  return "Unknown"
        }
    }

    var iconName: String {
        switch self {
        case .low:      return "checkmark.shield.fill"
        case .moderate:  return "exclamationmark.triangle.fill"
        case .high:     return "exclamationmark.octagon.fill"
        case .critical: return "xmark.octagon.fill"
        case .unknown:  return "questionmark.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .low:
            return "Normal conditions. No significant weather threats detected."
        case .moderate:
            return "Elevated conditions. Monitor weather closely."
        case .high:
            return "Dangerous conditions. Take precautionary measures."
        case .critical:
            return "Extreme conditions. Immediate action required."
        case .unknown:
            return "Unable to determine risk level."
        }
    }

    var scoreRange: ClosedRange<Int> {
        switch self {
        case .low:      return 0...25
        case .moderate:  return 26...50
        case .high:     return 51...75
        case .critical: return 76...100
        case .unknown:  return 0...0
        }
    }

    // MARK: - Comparable

    private var sortOrder: Int {
        switch self {
        case .unknown:  return 0
        case .low:      return 1
        case .moderate:  return 2
        case .high:     return 3
        case .critical: return 4
        }
    }

    static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

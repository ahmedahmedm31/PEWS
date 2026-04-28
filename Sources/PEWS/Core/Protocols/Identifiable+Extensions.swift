// Identifiable+Extensions.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol for entities that can provide mock data for previews and testing.
protocol Mockable {
    /// Returns a mock instance for previews and testing.
    static func mock() -> Self
}

/// Protocol for entities that can be validated.
protocol Validatable {
    /// Validates the entity and returns whether it is valid.
    var isValid: Bool { get }
}

/// Protocol for entities that track creation and modification dates.
protocol Timestamped {
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

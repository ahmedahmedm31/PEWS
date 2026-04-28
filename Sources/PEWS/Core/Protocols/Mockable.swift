// Mockable.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol for entities that can provide mock data for previews and testing.
protocol Mockable {
    static func mock() -> Self
}

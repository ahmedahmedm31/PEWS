// ViewState.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Represents the state of a view's data loading lifecycle.
enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)

    var isLoading: Bool {
        self == .loading
    }

    var isLoaded: Bool {
        self == .loaded
    }

    var isError: Bool {
        if case .error = self { return true }
        return false
    }
}

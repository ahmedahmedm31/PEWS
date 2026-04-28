// UseCase.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Base protocol for all use cases in the domain layer.
/// Each use case encapsulates a single piece of business logic.
protocol UseCase {
    /// The input type required by the use case.
    associatedtype Input
    /// The output type produced by the use case.
    associatedtype Output

    /// Executes the use case with the given input.
    /// - Parameter input: The input parameters for the use case.
    /// - Returns: The result of the use case execution.
    func execute(input: Input) async throws -> Output
}

/// A use case that requires no input parameters.
protocol NoInputUseCase {
    /// The output type produced by the use case.
    associatedtype Output

    /// Executes the use case.
    /// - Returns: The result of the use case execution.
    func execute() async throws -> Output
}

/// Represents the possible states of a view.
enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    case empty

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.loaded, .loaded),
             (.empty, .empty):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

// Debouncer.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// A utility that delays execution of a block until a specified time interval has passed
/// since the last invocation. Useful for search fields and frequent user input.
@MainActor
final class Debouncer {
    private let delay: TimeInterval
    private var task: Task<Void, Never>?

    /// Creates a new debouncer with the specified delay.
    /// - Parameter delay: The time interval to wait before executing the action.
    init(delay: TimeInterval = 0.5) {
        self.delay = delay
    }

    /// Debounces the given action. Previous pending actions are cancelled.
    /// - Parameter action: The async action to execute after the delay.
    func debounce(action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task { [delay] in
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await action()
            } catch {
                // Task was cancelled, which is expected behavior
            }
        }
    }

    /// Cancels any pending debounced action.
    func cancel() {
        task?.cancel()
        task = nil
    }
}

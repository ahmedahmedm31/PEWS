// NetworkClient.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Protocol for the network client to enable testing with mocks.
protocol NetworkClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func requestData(_ endpoint: Endpoint) async throws -> Data
}

/// HTTP network client using URLSession with async/await.
/// Handles request execution, response validation, decoding, and retry logic.
final class NetworkClient: NetworkClientProtocol {

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private let maxRetries: Int

    // MARK: - Initialization

    init(
        session: URLSession = .shared,
        maxRetries: Int = AppConfig.API.maxRetryAttempts
    ) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .secondsSince1970
        self.maxRetries = maxRetries
    }

    // MARK: - Public Methods

    /// Performs a network request and decodes the response.
    /// - Parameter endpoint: The API endpoint to request.
    /// - Returns: The decoded response object.
    /// - Throws: `APIError` if the request fails.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await requestData(endpoint)

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch let decodingError {
            Logger.error("Decoding failed", error: decodingError)
            throw APIError.decodingFailed(decodingError.localizedDescription)
        }
    }

    /// Performs a network request and returns raw data.
    /// - Parameter endpoint: The API endpoint to request.
    /// - Returns: The raw response data.
    /// - Throws: `APIError` if the request fails.
    func requestData(_ endpoint: Endpoint) async throws -> Data {
        guard let urlRequest = endpoint.urlRequest else {
            throw APIError.invalidURL
        }

        Logger.network("Request: \(urlRequest.httpMethod ?? "GET") \(urlRequest.url?.absoluteString ?? "unknown")")

        var lastError: APIError = .networkFailure("Unknown error")

        for attempt in 0..<maxRetries {
            do {
                let (data, response) = try await session.data(for: urlRequest)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse(statusCode: 0)
                }

                Logger.network("Response: \(httpResponse.statusCode) (\(data.count) bytes)")

                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    throw APIError.unauthorized
                case 404:
                    throw APIError.notFound
                case 429:
                    throw APIError.rateLimited
                case 500...599:
                    lastError = .serverError(statusCode: httpResponse.statusCode)
                    if attempt < maxRetries - 1 {
                        let delay = AppConfig.API.retryDelay * pow(2, Double(attempt))
                        Logger.network("Retrying in \(delay)s (attempt \(attempt + 1)/\(maxRetries))")
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw lastError
                default:
                    throw APIError.invalidResponse(statusCode: httpResponse.statusCode)
                }
            } catch let error as APIError {
                throw error
            } catch let error as URLError {
                lastError = mapURLError(error)
                if shouldRetry(error: error) && attempt < maxRetries - 1 {
                    let delay = AppConfig.API.retryDelay * pow(2, Double(attempt))
                    Logger.network("Retrying after URLError in \(delay)s (attempt \(attempt + 1)/\(maxRetries))")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                throw lastError
            } catch {
                throw APIError.networkFailure(error.localizedDescription)
            }
        }

        throw lastError
    }

    // MARK: - Private Helpers

    private func mapURLError(_ error: URLError) -> APIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .networkFailure(error.localizedDescription)
        }
    }

    private func shouldRetry(error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .networkConnectionLost:
            return true
        default:
            return false
        }
    }
}

// Endpoints.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation

/// Defines all API endpoints used by the application.
enum Endpoint {
    // OpenWeatherMap
    case currentWeather(WeatherRequestDTO)
    case forecast(WeatherRequestDTO)
    case historicalWeather(HistoricalWeatherRequestDTO)
    case geocoding(GeocodingRequestDTO)
    case reverseGeocoding(latitude: Double, longitude: Double)

    // Visual Crossing (Fallback)
    case visualCrossingCurrent(latitude: Double, longitude: Double)
    case visualCrossingHistory(latitude: Double, longitude: Double, date: String)

    /// The base URL for the endpoint.
    var baseURL: String {
        switch self {
        case .currentWeather, .forecast, .historicalWeather, .geocoding, .reverseGeocoding:
            return AppConfig.API.openWeatherMapBaseURL
        case .visualCrossingCurrent, .visualCrossingHistory:
            return AppConfig.API.visualCrossingBaseURL
        }
    }

    /// The path component of the endpoint.
    var path: String {
        switch self {
        case .currentWeather:
            return "/data/2.5/weather"
        case .forecast:
            return "/data/2.5/forecast"
        case .historicalWeather:
            return "/data/3.0/onecall/timemachine"
        case .geocoding:
            return "/geo/1.0/direct"
        case .reverseGeocoding:
            return "/geo/1.0/reverse"
        case .visualCrossingCurrent(let lat, let lon):
            return "/timeline/\(lat),\(lon)/today"
        case .visualCrossingHistory(let lat, let lon, let date):
            return "/timeline/\(lat),\(lon)/\(date)"
        }
    }

    /// The HTTP method for the endpoint.
    var method: HTTPMethod {
        .get
    }

    /// The query parameters for the endpoint.
    var queryParameters: [String: String] {
        switch self {
        case .currentWeather(let request):
            return request.queryParameters
        case .forecast(let request):
            return request.queryParameters
        case .historicalWeather(let request):
            return request.queryParameters
        case .geocoding(let request):
            return request.queryParameters
        case .reverseGeocoding(let latitude, let longitude):
            return [
                "lat": String(format: "%.4f", latitude),
                "lon": String(format: "%.4f", longitude),
                "limit": "1",
                "appid": APIKeys.openWeatherMapKey
            ]
        case .visualCrossingCurrent, .visualCrossingHistory:
            return [
                "unitGroup": "metric",
                "key": APIKeys.visualCrossingKey,
                "contentType": "json"
            ]
        }
    }

    /// Constructs the full URL with query parameters.
    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryParameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        return components?.url
    }

    /// Constructs a URLRequest for this endpoint.
    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = AppConfig.API.requestTimeoutInterval
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

/// HTTP methods supported by the API.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

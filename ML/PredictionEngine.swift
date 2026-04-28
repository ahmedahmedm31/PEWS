// PredictionEngine.swift
// PEWS - Predictive Early Warning System
//
// Created by Ahmed Magaji Ahmed
// Copyright © 2026. All rights reserved.

import Foundation
import CoreML

/// Result of a crisis prediction from the ML model.
struct PredictionResult: Sendable {
    let crisisProbability: Double
    let confidence: Double
    let processingTime: TimeInterval
}

/// Protocol for the prediction engine to enable testing with mocks.
protocol PredictionEngineProtocol: Sendable {
    func predict(features: WeatherFeatures) async throws -> PredictionResult
    var isModelLoaded: Bool { get }
}

/// Core ML-based prediction engine for weather crisis prediction.
/// Uses a trained model to analyze weather features and predict crisis probability.
/// Falls back to a rule-based algorithm when the ML model is unavailable.
final class PredictionEngine: PredictionEngineProtocol, @unchecked Sendable {

    // MARK: - Properties

    private var model: MLModel?
    private let queue = DispatchQueue(label: "com.pews.prediction", qos: .userInitiated)
    private static let outputFeatureName = "crisisProbability"

    var isModelLoaded: Bool {
        model != nil
    }

    // MARK: - Initialization

    init() {
        loadModel()
    }

    // MARK: - Model Loading

    private func loadModel() {
        guard let modelURL = Bundle.main.url(
            forResource: AppConfig.ML.modelName,
            withExtension: "mlmodelc"
        ) else {
            Logger.warning("CoreML model not found in bundle, using rule-based fallback")
            return
        }

        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndGPU
            model = try MLModel(contentsOf: modelURL, configuration: config)
            Logger.ml("CoreML model loaded successfully")
        } catch {
            Logger.error("Failed to load CoreML model", error: error)
        }
    }

    // MARK: - Prediction

    func predict(features: WeatherFeatures) async throws -> PredictionResult {
        let startTime = Date()

        if let model {
            return try await predictWithModel(model, features: features, startTime: startTime)
        } else {
            return predictWithRules(features: features, startTime: startTime)
        }
    }

    // MARK: - CoreML Prediction

    private func predictWithModel(
        _ model: MLModel,
        features: WeatherFeatures,
        startTime: Date
    ) async throws -> PredictionResult {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self else {
                    continuation.resume(throwing: WeatherError.predictionFailed("Engine deallocated"))
                    return
                }
                do {
                    let input = try self.createMLInput(from: features)
                    let prediction = try model.prediction(from: input)

                    guard let probabilityOutput = prediction.featureValue(
                        for: Self.outputFeatureName
                    )?.doubleValue else {
                        throw WeatherError.predictionFailed("Invalid model output")
                    }

                    let confidence = self.calculateConfidence(
                        probability: probabilityOutput,
                        features: features
                    )

                    let result = PredictionResult(
                        crisisProbability: min(max(probabilityOutput, 0), 1),
                        confidence: confidence,
                        processingTime: Date().timeIntervalSince(startTime)
                    )
                    continuation.resume(returning: result)
                } catch {
                    Logger.error("ML prediction failed, falling back to rules", error: error)
                    let fallback = self.predictWithRules(features: features, startTime: startTime)
                    continuation.resume(returning: fallback)
                }
            }
        }
    }

    private func createMLInput(from features: WeatherFeatures) throws -> MLFeatureProvider {
        let featureDict: [String: MLFeatureValue] = [
            "temperature": MLFeatureValue(double: features.temperature),
            "humidity": MLFeatureValue(double: features.humidity),
            "pressure": MLFeatureValue(double: features.pressure),
            "windSpeed": MLFeatureValue(double: features.windSpeed),
            "windDirection": MLFeatureValue(double: features.windDirection),
            "cloudCoverage": MLFeatureValue(double: features.cloudCoverage),
            "visibility": MLFeatureValue(double: features.visibility),
            "precipitation": MLFeatureValue(double: features.precipitation),
            "tempChange": MLFeatureValue(double: features.tempChange),
            "pressureChange": MLFeatureValue(double: features.pressureChange),
            "humidityChange": MLFeatureValue(double: features.humidityChange),
            "windSpeedChange": MLFeatureValue(double: features.windSpeedChange),
            "dewPoint": MLFeatureValue(double: features.dewPoint),
            "heatIndex": MLFeatureValue(double: features.heatIndex),
            "windChill": MLFeatureValue(double: features.windChill)
        ]
        return try MLDictionaryFeatureProvider(dictionary: featureDict)
    }

    // MARK: - Rule-Based Fallback

    private func predictWithRules(features: WeatherFeatures, startTime: Date) -> PredictionResult {
        var riskFactors: [Double] = []

        riskFactors.append(calculateTemperatureRisk(features.temperature) * 0.20)
        riskFactors.append(calculateWindRisk(features.windSpeed) * 0.20)
        riskFactors.append(calculatePrecipitationRisk(features.precipitation) * 0.15)
        riskFactors.append(calculatePressureRisk(features.pressure) * 0.15)
        riskFactors.append(calculateVisibilityRisk(features.visibility) * 0.10)
        riskFactors.append(calculateHumidityRisk(features.humidity) * 0.10)
        riskFactors.append(calculateChangeRisk(features) * 0.10)

        let totalProbability = min(riskFactors.reduce(0, +), 1.0)

        return PredictionResult(
            crisisProbability: totalProbability,
            confidence: 0.65,
            processingTime: Date().timeIntervalSince(startTime)
        )
    }

    // MARK: - Risk Calculation Helpers

    private func calculateTemperatureRisk(_ temp: Double) -> Double {
        switch temp {
        case ...(-20): return 1.0
        case -20...(-10): return 0.7
        case -10...0: return 0.3
        case 0...35: return 0.0
        case 35...40: return 0.5
        case 40...45: return 0.8
        default: return 1.0
        }
    }

    private func calculateWindRisk(_ speed: Double) -> Double {
        switch speed {
        case 0...10: return 0.0
        case 10...15: return 0.2
        case 15...20: return 0.4
        case 20...25: return 0.6
        case 25...30: return 0.8
        default: return 1.0
        }
    }

    private func calculatePrecipitationRisk(_ amount: Double) -> Double {
        switch amount {
        case 0...2: return 0.0
        case 2...5: return 0.2
        case 5...10: return 0.4
        case 10...20: return 0.7
        case 20...30: return 0.9
        default: return 1.0
        }
    }

    private func calculatePressureRisk(_ pressure: Double) -> Double {
        switch pressure {
        case ...960: return 1.0
        case 960...970: return 0.8
        case 970...980: return 0.6
        case 980...990: return 0.3
        case 990...1000: return 0.1
        default: return 0.0
        }
    }

    private func calculateVisibilityRisk(_ visibility: Double) -> Double {
        switch visibility {
        case 0...200: return 1.0
        case 200...500: return 0.8
        case 500...1000: return 0.6
        case 1000...3000: return 0.3
        case 3000...5000: return 0.1
        default: return 0.0
        }
    }

    private func calculateHumidityRisk(_ humidity: Double) -> Double {
        switch humidity {
        case 0...30: return 0.1
        case 30...60: return 0.0
        case 60...80: return 0.1
        case 80...90: return 0.3
        case 90...95: return 0.5
        default: return 0.7
        }
    }

    private func calculateChangeRisk(_ features: WeatherFeatures) -> Double {
        var risk: Double = 0
        if features.pressureChange < -5 { risk += 0.5 }
        if abs(features.tempChange) > 10 { risk += 0.3 }
        if features.windSpeedChange > 10 { risk += 0.4 }
        return min(risk, 1.0)
    }

    // MARK: - Confidence Calculation

    private func calculateConfidence(probability: Double, features: WeatherFeatures) -> Double {
        var confidence: Double = 0.85

        if features.temperature > 45 || features.temperature < -30 {
            confidence -= 0.1
        }
        if features.windSpeed > 40 {
            confidence -= 0.05
        }

        let extremeFactors = [
            features.temperature > 35 || features.temperature < -10,
            features.windSpeed > 20,
            features.precipitation > 10,
            features.pressure < 980,
            features.visibility < 1000
        ].filter { $0 }.count

        if extremeFactors >= 3 {
            confidence += 0.05
        }

        return min(max(confidence, 0.5), 0.99)
    }
}

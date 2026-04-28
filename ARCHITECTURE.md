# PEWS Architecture Documentation

## Overview

The Predictive Early Warning System (PEWS) is built using **Clean Architecture** combined with the **MVVM** (Model-View-ViewModel) pattern. This architecture ensures strict separation of concerns, enabling independent testing of each layer, straightforward dependency injection, and the ability to swap implementations without affecting other layers.

The application is organized into four primary layers, each with clearly defined responsibilities and dependencies that flow inward from the presentation layer to the domain layer. The domain layer sits at the center and has no dependencies on any other layer, making it the most stable and reusable part of the codebase.

---

## Layer Architecture

### Presentation Layer

The presentation layer is responsible for all user interface concerns. It consists of SwiftUI views and their corresponding ViewModels. Each screen in the application follows a consistent pattern where the View observes its ViewModel through the `@StateObject` or `@ObservedObject` property wrappers, and the ViewModel exposes state through `@Published` properties.

ViewModels communicate exclusively with the domain layer through use cases and repository interfaces. They never access data sources directly. This ensures that the presentation layer remains agnostic to the specifics of data retrieval and storage.

The `ViewState` enum provides a unified approach to managing loading states across all screens. Every ViewModel publishes a `ViewState` property that drives the view's display logic, ensuring consistent loading, error, and empty state handling throughout the application.

### Domain Layer

The domain layer contains the core business logic and entity definitions. It is the innermost layer and has zero dependencies on external frameworks or other application layers. All repository access is defined through Swift protocols (interfaces), which are implemented in the data layer.

Use cases encapsulate individual business operations. Each use case has a single responsibility and accepts its dependencies through constructor injection. This pattern makes use cases trivially testable by substituting mock implementations of the repository interfaces.

Domain entities represent the core data structures of the application. They are plain Swift structs with value semantics, making them thread-safe and easy to reason about. The `WeatherData`, `Forecast`, `Location`, `Alert`, and `Prediction` entities form the foundation of the application's data model.

### Data Layer

The data layer manages all data access concerns, including remote API communication, local persistence, and caching. It implements the repository interfaces defined in the domain layer, providing concrete data access logic while keeping the domain layer decoupled from implementation details.

The networking stack is built on `URLSession` with full `async/await` support. The `NetworkClient` provides a generic request method with automatic retry logic, error mapping, and response validation. The `WeatherAPIService` builds on this foundation to provide type-safe API methods for all OpenWeatherMap endpoints.

Data Transfer Objects (DTOs) serve as the bridge between external API responses and internal domain entities. The mapper classes (`WeatherMapper`, `ForecastMapper`, `LocationMapper`) handle the transformation between these representations, ensuring that changes to the API response format do not propagate into the domain layer.

The caching system operates at two levels. An in-memory `NSCache` provides fast access to recently fetched data, while a disk-based cache ensures data survives app restarts. The `CacheManager` supports configurable TTL (time-to-live) values, and the repositories check the cache before making network requests.

### ML Layer

The ML layer encapsulates all machine learning functionality. The `PredictionEngine` serves as the primary interface, accepting normalized weather features and returning crisis probability predictions. It attempts to use a CoreML model when available and falls back to a rule-based algorithm when the model is not present.

The `FeatureExtractor` transforms raw weather data into a normalized 15-feature vector suitable for ML model input. It handles min-max normalization, derived feature computation (dew point, heat index, wind chill), and rate-of-change calculations when historical data is available.

The `ModelTrainer` supports on-device model updates using CoreML's updatable model API. It collects prediction-outcome pairs and periodically retrains the model to improve accuracy for the user's specific location and conditions.

The `ModelValidator` tracks prediction accuracy over time by recording predicted probabilities against actual outcomes. It computes standard classification metrics (accuracy, precision, recall, F1 score) and signals when the model's performance drops below the configured threshold.

---

## Data Flow

A typical data flow through the application follows this path:

1. The **View** triggers an action (e.g., pull-to-refresh) that calls a method on the **ViewModel**.
2. The **ViewModel** updates its `ViewState` to `.loading` and invokes the appropriate **Use Case**.
3. The **Use Case** calls the **Repository Interface** method defined in the domain layer.
4. The **Repository Implementation** in the data layer checks the **Cache** first. On a cache miss, it calls the **API Service**.
5. The **API Service** uses the **NetworkClient** to make the HTTP request and decode the **DTO** response.
6. The **Mapper** transforms the DTO into a **Domain Entity**.
7. The **Repository** caches the result and returns the entity to the use case.
8. The **Use Case** may apply additional business logic (e.g., risk calculation) before returning.
9. The **ViewModel** updates its `@Published` properties and sets `ViewState` to `.loaded`.
10. **SwiftUI** automatically re-renders the view based on the updated state.

---

## Dependency Injection

The `DependencyContainer` class serves as the application's composition root. It creates and wires together all dependencies at app launch, providing factory methods for ViewModels that inject the correct use cases and repositories.

This approach avoids the use of service locator patterns or global singletons (with the exception of the `NotificationManager` and `BackgroundTaskManager`, which require singleton behavior due to system framework constraints). All other dependencies are explicitly injected through initializers, making the dependency graph transparent and testable.

---

## Error Handling Strategy

Errors are categorized into three types throughout the application. **API errors** (`APIError`) represent network and HTTP-level failures. **Domain errors** (`WeatherError`) represent business-level failures such as invalid coordinates or maximum locations reached. **System errors** are caught and wrapped in domain errors before being surfaced to the presentation layer.

Every ViewModel catches errors from use cases and maps them to user-friendly messages through the `ViewState.error(String)` case. The `ErrorView` component provides a consistent retry mechanism across all screens.

---

## Background Processing

The application uses `BGTaskScheduler` to register two background tasks. The weather refresh task runs approximately every 15 minutes to fetch updated weather data for monitored locations. The alert check task runs every 30 minutes to evaluate risk scores and trigger notifications when thresholds are exceeded.

Both tasks are designed to be resilient to cancellation. They register expiration handlers that cancel in-flight network requests, and they always schedule the next execution before beginning work to ensure continuity.

---

## Testing Strategy

The testing approach follows the architecture's layer boundaries. Each layer has its own test suite with mock implementations of its dependencies. The mock objects track call counts and support stubbed responses, enabling precise verification of interaction patterns.

Domain layer tests verify business logic in isolation by injecting mock repositories. Presentation layer tests verify ViewModel state transitions by injecting mock use cases and repositories. Data layer tests verify DTO mapping correctness and endpoint URL construction. ML layer tests verify feature normalization, prediction bounds, and validation metric calculations.

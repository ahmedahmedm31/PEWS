# Changelog

All notable changes to the PEWS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-16

### Added

#### Phase 0 - Project Setup
- Clean Architecture + MVVM folder structure
- Base protocols: Repository, UseCase, Mockable
- Core utilities: Logger, Constants, Formatters, Debouncer
- Extensions: Date, Color, View, Double
- Theme system with colors, typography, spacing, corner radius
- Shared UI components: LoadingView, ErrorView, EmptyStateView, RefreshableScrollView
- Button styles, card modifiers, animation styles
- SwiftLint configuration
- Git ignore rules
- App configuration and API key management

#### Phase 1 - Core Data Layer
- WeatherRequestDTO, HistoricalWeatherRequestDTO, GeocodingRequestDTO
- CurrentWeatherResponseDTO, ForecastResponseDTO, GeocodingResponseDTO
- NetworkClient with async/await, retry logic, and error handling
- WeatherAPIService with all endpoint implementations
- Endpoints builder for OpenWeatherMap API
- APIError with comprehensive error types
- CoreDataManager for persistent storage
- UserDefaultsManager for user preferences
- CacheManager with TTL-based memory and disk caching
- WeatherMapper, ForecastMapper, LocationMapper
- WeatherRepository, LocationRepository, AlertRepository, PredictionRepository

#### Phase 2 - Domain Layer
- Domain entities: WeatherData, Forecast, Location, Alert, Prediction, RiskLevel
- Repository interfaces (protocols) for all data access
- FetchCurrentWeatherUseCase, FetchForecastUseCase
- PredictCrisisUseCase, CalculateRiskScoreUseCase
- CreateAlertUseCase, FetchAlertsUseCase, UpdateAlertThresholdUseCase
- AddLocationUseCase, RemoveLocationUseCase, FetchLocationsUseCase
- GenerateReportUseCase with CSV export

#### Phase 3 - Basic UI
- DashboardView with risk gauge, weather card, quick stats
- DashboardViewModel with full state management
- RiskGaugeView with animated arc and color coding
- WeatherCardView with condition icon and details
- QuickStatsView with key metrics grid
- ForecastRowView for hourly/daily forecast items
- TrendChartView using Swift Charts
- ViewState enum for loading lifecycle
- MainTabView with 4 tabs

#### Phase 4 - ML Prediction
- PredictionEngine with CoreML integration and rule-based fallback
- FeatureExtractor with 15-feature normalization
- Derived feature calculations: dew point, heat index, wind chill
- Rate-of-change feature extraction from historical data
- ModelTrainer for on-device model updates
- ModelValidator with accuracy, precision, recall, F1 score tracking

#### Phase 5 - Charts & History
- HistoryView with date range selection and chart display
- HistoryViewModel with data loading and statistics
- DateRangePickerView with preset and custom date ranges
- CSVExportView with preview and share functionality
- StatisticsGrid with summary metrics
- Chart type selector (temperature, humidity, pressure, wind)

#### Phase 6 - Alerts System
- AlertsView with filtering, swipe actions, and management
- AlertsViewModel with load, filter, acknowledge, delete operations
- ThresholdEditorView with slider and risk level preview
- NotificationManager with categories and foreground handling
- BackgroundTaskManager with weather refresh and alert check
- Alert row component with risk level indicator

#### Phase 7 - Settings & Polish
- SettingsView with units, notifications, alerts, appearance, data sections
- SettingsViewModel with preference persistence
- OnboardingView with 5-page guided introduction
- LocationSearchView with debounced search
- AboutView with app info and feature list
- Temperature and speed unit conversion support

#### Phase 8 & 9 - Testing & Documentation
- Mock implementations: MockWeatherAPIService, MockWeatherRepository, MockPredictionEngine, MockPredictionRepository, MockAlertRepository, MockLocationRepository
- Test data factories for all domain entities
- Unit tests: CalculateRiskScoreUseCaseTests, FetchCurrentWeatherUseCaseTests, LocationUseCaseTests
- Unit tests: FeatureExtractorTests, PredictionEngineTests, ModelValidatorTests
- Unit tests: WeatherMapperTests, NetworkClientTests, CacheManagerTests
- Unit tests: DashboardViewModelTests, AlertsViewModelTests, HistoryViewModelTests
- Unit tests: ExtensionsTests, FormattersTests
- Comprehensive README with architecture diagrams
- CHANGELOG with full version history

---

## Development Phases Completed

| Phase | Name | Status |
|-------|------|--------|
| 0 | Project Setup | Complete |
| 1 | Core Data Layer | Complete |
| 2 | Domain Layer | Complete |
| 3 | Basic UI | Complete |
| 4 | ML Prediction | Complete |
| 5 | Charts & History | Complete |
| 6 | Alerts System | Complete |
| 7 | Settings & Polish | Complete |
| 8 | Testing & QA | Complete |
| 9 | Documentation | Complete |

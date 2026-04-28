# PEWS - Predictive Early Warning System

<p align="center">
  <strong>An iOS weather crisis prediction app powered by Machine Learning</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-green" alt="SwiftUI">
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-purple" alt="Architecture">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey" alt="License">
</p>

---

## Overview

PEWS (Predictive Early Warning System) is a comprehensive iOS application that monitors weather conditions and uses machine learning to predict potential weather crises. The app provides real-time risk assessments, customizable alerts, historical trend analysis, and CSV data export capabilities.

### Key Features

| Feature | Description |
|---------|-------------|
| **Real-Time Dashboard** | Live weather data with risk gauge, quick stats, and forecast |
| **ML Crisis Prediction** | CoreML-powered prediction engine with rule-based fallback |
| **Smart Alerts** | Customizable threshold notifications with background fetch |
| **Historical Analysis** | Interactive charts with date range picker and statistics |
| **CSV Export** | Export weather history data for external analysis |
| **Multi-Location** | Monitor up to 5 locations simultaneously |
| **Onboarding** | Guided first-launch experience |
| **Accessibility** | Full VoiceOver support and Dynamic Type |

---

## Architecture

PEWS follows **Clean Architecture** combined with **MVVM** (Model-View-ViewModel) pattern, ensuring separation of concerns, testability, and maintainability.

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │  Views   │──│ViewModels│──│Components │  │
│  └──────────┘  └──────────┘  └───────────┘  │
├─────────────────────────────────────────────┤
│                Domain Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ Entities │  │Use Cases │  │Interfaces │  │
│  └──────────┘  └──────────┘  └───────────┘  │
├─────────────────────────────────────────────┤
│                 Data Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │   DTOs   │  │ Mappers  │  │Repositories│  │
│  │  Remote  │  │  Local   │  │  Services │  │
│  └──────────┘  └──────────┘  └───────────┘  │
├─────────────────────────────────────────────┤
│                  ML Layer                    │
│  ┌──────────────┐  ┌─────────────────────┐  │
│  │PredictionEng.│  │FeatureExtractor     │  │
│  │ModelTrainer  │  │ModelValidator       │  │
│  └──────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Layer Responsibilities

- **Presentation**: SwiftUI views, ViewModels with `@Published` state, shared UI components
- **Domain**: Business entities, use cases, repository interfaces (protocols)
- **Data**: DTOs, API services, network client, local storage, mappers, repository implementations
- **ML**: CoreML prediction engine, feature extraction, model training and validation

---

## Project Structure

```
PEWS/
├── App/
│   ├── PEWSApp.swift                    # App entry point
│   ├── AppDelegate.swift                # App lifecycle
│   ├── DependencyContainer.swift        # DI container
│   └── Configuration/
│       ├── AppConfig.swift              # App configuration
│       └── APIKeys.swift                # API key management
├── Core/
│   ├── Extensions/                      # Date, Color, View, Double extensions
│   ├── Protocols/                       # Repository, UseCase, Mockable protocols
│   └── Utilities/                       # Logger, Constants, Formatters, etc.
├── Data/
│   ├── DTOs/
│   │   ├── Request/                     # API request DTOs
│   │   ├── Response/                    # API response DTOs
│   │   └── Mappers/                     # DTO-to-Entity mappers
│   ├── DataSources/
│   │   ├── Remote/                      # NetworkClient, API services
│   │   └── Local/                       # CoreData, UserDefaults, Cache
│   └── Repositories/                    # Repository implementations
├── Domain/
│   ├── Entities/                        # WeatherData, Forecast, Alert, etc.
│   ├── Interfaces/                      # Repository protocols
│   └── UseCases/                        # Business logic use cases
├── ML/
│   ├── PredictionEngine.swift           # CoreML integration
│   ├── FeatureExtractor.swift           # Feature normalization
│   ├── ModelTrainer.swift               # On-device model updates
│   └── ModelValidator.swift             # Prediction accuracy tracking
├── Presentation/
│   ├── MainTabView.swift                # Root tab navigation
│   ├── Dashboard/                       # Dashboard screen
│   ├── History/                         # History & charts screen
│   ├── Alerts/                          # Alerts management screen
│   ├── Settings/                        # Settings screen
│   ├── Location/                        # Location search
│   ├── Onboarding/                      # First-launch onboarding
│   └── Shared/                          # Shared components & styles
├── Tests/
│   ├── Mocks/                           # Mock implementations
│   └── UnitTests/                       # Unit test suites
├── .swiftlint.yml                       # SwiftLint configuration
├── .gitignore                           # Git ignore rules
├── CHANGELOG.md                         # Version history
└── README.md                            # This file
```

---

## Technology Stack

| Category | Technology |
|----------|-----------|
| **Language** | Swift 5.9 |
| **UI Framework** | SwiftUI 4.0 |
| **Architecture** | Clean Architecture + MVVM |
| **ML Framework** | CoreML |
| **Networking** | URLSession (async/await) |
| **Local Storage** | CoreData + UserDefaults |
| **Caching** | NSCache + Disk Cache |
| **Charts** | Swift Charts (iOS 16+) |
| **Notifications** | UserNotifications |
| **Background Tasks** | BGTaskScheduler |
| **Minimum iOS** | iOS 16.0 |

---

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ deployment target
- OpenWeatherMap API key

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/PEWS.git
   cd PEWS
   ```

2. **Configure API Keys**
   ```bash
   cp App/Configuration/APIKeys.example.swift App/Configuration/APIKeys.swift
   ```
   Edit `APIKeys.swift` and add your OpenWeatherMap API key.

3. **Open in Xcode**
   ```bash
   open PEWS.xcodeproj
   ```

4. **Build and Run**
   Select your target device/simulator and press `Cmd + R`.

### API Key

Sign up at [OpenWeatherMap](https://openweathermap.org/api) to get a free API key. The app uses:
- Current Weather API
- 5-Day Forecast API
- Geocoding API

---

## ML Model

### Prediction Engine

The app uses a dual-approach prediction system:

1. **CoreML Model** (Primary): A trained classification model that analyzes 15 weather features to predict crisis probability. When the `.mlmodelc` file is present in the bundle, predictions use GPU-accelerated inference.

2. **Rule-Based Algorithm** (Fallback): A weighted multi-factor algorithm that calculates risk based on temperature, wind, precipitation, pressure, visibility, humidity, and rate-of-change metrics.

### Feature Vector (15 features)

| Feature | Range | Description |
|---------|-------|-------------|
| temperature | -40 to 50°C | Current temperature |
| humidity | 0-100% | Relative humidity |
| pressure | 950-1050 hPa | Atmospheric pressure |
| windSpeed | 0-50 m/s | Wind speed |
| windDirection | 0-360° | Wind direction |
| cloudCoverage | 0-100% | Cloud cover percentage |
| visibility | 0-20000m | Visibility distance |
| precipitation | 0-50mm | Precipitation amount |
| tempChange | Rate/hr | Temperature rate of change |
| pressureChange | Rate/hr | Pressure rate of change |
| humidityChange | Rate/hr | Humidity rate of change |
| windSpeedChange | Rate/hr | Wind speed rate of change |
| dewPoint | Computed | Dew point (Magnus formula) |
| heatIndex | Computed | Apparent temperature (hot) |
| windChill | Computed | Apparent temperature (cold) |

### Risk Levels

| Level | Score Range | Color | Description |
|-------|------------|-------|-------------|
| Low | 0-25 | Green | Normal conditions |
| Moderate | 26-50 | Orange | Elevated risk, monitor |
| High | 51-75 | Red | Significant risk, prepare |
| Critical | 76-100 | Dark Red | Severe risk, take action |

---

## Testing

### Test Coverage

| Layer | Test Files | Focus Areas |
|-------|-----------|-------------|
| Core | ExtensionsTests, FormattersTests | Date/Double extensions, formatting |
| Data | WeatherMapperTests, NetworkClientTests, CacheManagerTests | DTO mapping, endpoints, caching |
| Domain | CalculateRiskScoreUseCaseTests, FetchCurrentWeatherUseCaseTests, LocationUseCaseTests | Business logic, use cases |
| ML | FeatureExtractorTests, PredictionEngineTests, ModelValidatorTests | Normalization, prediction, metrics |
| Presentation | DashboardViewModelTests, AlertsViewModelTests, HistoryViewModelTests | ViewModel state management |

### Running Tests

```bash
# Run all tests
Cmd + U (in Xcode)

# Run specific test suite
swift test --filter FeatureExtractorTests
```

---

## Git Conventions

### Branch Naming
```
feature/PEWS-{number}-{description}
bugfix/PEWS-{number}-{description}
hotfix/PEWS-{number}-{description}
```

### Commit Messages
```
feat: Add risk gauge component
fix: Correct temperature conversion
test: Add FeatureExtractor unit tests
docs: Update README with ML section
refactor: Extract prediction logic to use case
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**Ahmed Magaji Ahmed**

Built with SwiftUI, CoreML, and Clean Architecture principles.

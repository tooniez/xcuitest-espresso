# Test Strategy

## Goals

- Prove end-to-end UI automation on **native** Android and iOS stacks
- Follow the **testing pyramid**: many fast unit tests, fewer integration tests, minimal UI smoke tests
- Keep CI deterministic (no live network in default UI/CI paths)
- Share fixture data via `test-data/` for data-driven scenarios

## Testing pyramid

```text
        UI (Espresso / XCUITest)     ~10%  — critical journeys, mocked boundaries
    Integration (device / URL stub)  ~20%  — HTTP + parsing with fixtures
Unit (JVM / XCTest host)             ~70%  — pure parsing and formatting
```

| Layer | Android | iOS | Run locally |
|-------|---------|-----|-------------|
| **Unit** | `app/src/test` — JUnit | `DemoAppTests` — XCTest | `./scripts/run-android-unit.sh` / `./scripts/run-ios-unit.sh` |
| **Integration** | `app/src/androidTest/.../integration` — MockWebServer | `DemoAppTests` — URLProtocol stub | `./scripts/run-android.sh` (with emulator) |
| **UI** | `app/src/androidTest/.../ui` — Espresso | `DemoAppUITests` — XCUITest | `./scripts/run-android.sh` / `./scripts/run-ios.sh` |

Shared fixture: [`test-data/open-meteo-forecast-response.json`](../test-data/open-meteo-forecast-response.json) (wired into Android `test` / `androidTest` resource sets and the iOS unit-test bundle).

## What each layer covers

### Unit

- `WeatherClient.parseForecastResponse` / JSON → `"San Francisco: 63°F"`
- `formatTemperature` (whole vs fractional)
- Error paths for malformed JSON

No emulator, simulator UI, or network.

### Integration

- Android: `WeatherClientIntegrationTest` — MockWebServer returns the shared fixture
- Android: `WeatherClientLiveIntegrationTest` — real Open-Meteo (`@Ignore`; run manually for [Charles Proxy](charles-proxy.md))
- iOS: `WeatherClientIntegrationTests` — `MockURLProtocol` + injectable `urlSession`

### UI

- Home screen copy mirrors product demo strings (parity with `test-data/products.json`)
- **Get Weather** uses test doubles (no live API in CI):
  - Android: `WeatherClient.mockSummary` in instrumentation process
  - iOS: launch argument `-MockWeather <summary>`

| Platform | Home UI test | Weather UI test |
|----------|--------------|-----------------|
| Android | `ui.MainActivityEspressoTest` | `ui.MainActivityWeatherEspressoTest` |
| iOS | `testHomeScreenShowsWelcomeAndProductDetails` | `testGetWeatherShowsMockedSanFranciscoTemperature` |

## Network / Charles demo (manual)

For live HTTPS inspection, run the ignored Android live integration test or launch the app manually and tap **Get Weather**. See [charles-proxy.md](charles-proxy.md).

Metadata fixture: [`test-data/weather.json`](../test-data/weather.json).

## Conventions

- **Stable selectors**: Android `@+id/...`; iOS `accessibilityIdentifier` and visible text
- **No sleeps**: Espresso idling resources; XCUITest `waitForExistence`
- **Scripts as entry points**: `run-*-unit.sh` for pyramid base; `run-android.sh` / `run-ios.sh` for instrumented/UI suites

## CI

| Workflow | Command | Notes |
|----------|---------|-------|
| `android-unit-tests.yml` | `run-android-unit.sh` | Ubuntu, no emulator |
| `android-ui-tests.yml` | `run-android.sh` | Emulator + Espresso |
| `ios-ui-tests.yml` | `run-ios.sh` | macOS simulator + XCUITest |

Add `run-ios-unit.sh` to CI when a macOS unit-test job is needed alongside UI tests.

## Extending coverage

1. Add business logic with unit tests first (`src/test`, `DemoAppTests`).
2. Add boundary tests with mocks (`integration/` package, URLProtocol).
3. Add one UI smoke test per user journey (`ui/` package, `DemoAppUITests`).
4. Load JSON from `test-data/` rather than duplicating literals.
5. Publish reports per [reporting.md](reporting.md).

# Test Strategy

## Goals

- Prove end-to-end UI automation on **native** Android and iOS stacks
- Keep tests fast, deterministic, and runnable locally and in CI
- Share fixture data via `test-data/` for future data-driven scenarios

## Test layers

| Layer | Android | iOS |
|-------|---------|-----|
| UI / instrumentation | Espresso in `app/src/androidTest` | XCUITest in `DemoAppUITests` |
| Network / API (demo) | Get Weather → Open-Meteo HTTPS | Get Weather → Open-Meteo HTTPS |
| Unit (optional) | JUnit in `app/src/test` | XCTest unit target (not scaffolded by default) |

Current scaffold ships smoke tests per platform: home screen copy mirrors `test-data/products.json`, and a weather test triggers a live call documented in `test-data/weather.json`.

## Network / API demo

The **Get Weather** button fetches current temperature from [Open-Meteo](https://open-meteo.com/) (no API key). UI tests on both platforms tap the button and assert a `San Francisco: …°F` label.

Use [charles-proxy.md](charles-proxy.md) to capture HTTPS traffic while running the app or tests locally. Weather tests require network access and may be flaky in offline CI — run them locally when demoing Charles.

| Platform | Test |
|----------|------|
| Android | `MainActivityWeatherEspressoTest.getWeather_showsSanFranciscoTemperatureInFahrenheit` |
| iOS | `DemoAppUITests.testGetWeatherShowsSanFranciscoTemperatureInFahrenheit` |

Android uses `CountingIdlingResource` so Espresso waits for the network call without fixed sleeps.

## Conventions

- **Stable selectors**: Android uses `@+id/...` view IDs; iOS uses visible text and `accessibilityIdentifier` where needed.
- **No sleeps**: Espresso and XCUITest sync with the UI; use `waitForExistence` on iOS when launching cold.
- **Scripts as entry points**: `./scripts/run-android.sh` and `./scripts/run-ios.sh` are the canonical local and CI commands.

## CI

Workflows in `github/workflows/` trigger on `main` pushes and PRs:

- `android-ui-tests.yml` — Ubuntu + JDK 17 + `run-android.sh`
- `ios-ui-tests.yml` — macOS + `run-ios.sh`

CI jobs should scaffold before test if generated native trees are not committed, or checkout a branch that already includes them.

## Extending coverage

1. Add flows (login, cart, settings) in the app UI.
2. Mirror scenarios in both Espresso and XCUITest for parity.
3. Load JSON from `test-data/` in app debug builds or test fixtures as needed.
4. Publish reports per [reporting.md](reporting.md).

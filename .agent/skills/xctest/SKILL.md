---
name: xctest
description: Writes and extends XCUITest UI tests for the iOS app in this repo. Use when adding iOS UI tests, fixing flaky XCUITest, wiring SwiftUI accessibilityIdentifier, handling async/network UI, or when the user mentions XCTest, XCUITest, DemoAppUITests, or XCUIApplication.
---

# XCUITest (Mobile UI Automation Demo)

## Project map

| Item | Path |
|------|------|
| App | `ios/DemoApp/` |
| UI tests | `ios/DemoAppUITests/DemoAppUITests.swift` |
| XcodeGen spec | `ios/project.yml` |
| Run tests | `./scripts/run-ios.sh` |
| Fixtures | `test-data/` (`products.json`, `weather.json`) |

Do **not** run builds or tests yourself — ask the user to run `./scripts/run-ios.sh` after changes.

For Android parity, use the [espresso](../espresso/SKILL.md) skill.

## Conventions

1. **Selectors** — Prefer `accessibilityIdentifier` on SwiftUI views over visible label text (especially buttons and dynamic labels).
2. **No sleeps** — Use `waitForExistence(timeout:)` after launch or network-backed UI updates.
3. **Setup** — `continueAfterFailure = false` in `setUpWithError()`.
4. **Main actor** — Mark UI test methods `@MainActor` when using `XCUIApplication`.
5. **Project changes** — Edit `ios/project.yml`, then regenerate with XcodeGen — do not hand-edit `DemoApp.xcodeproj`.

## Accessibility identifiers (home + weather)

| Element | Identifier |
|---------|------------|
| Welcome | `welcome_title` |
| Product name | `product_name` |
| Price | `product_price` |
| Get Weather button | `get_weather_button` |
| Status line | `weather_status` |
| Result | `weather_result` |

Add identifiers in SwiftUI:

```swift
Button("Get Weather") { ... }
    .accessibilityIdentifier("get_weather_button")
```

## Adding a test

```
Task progress:
- [ ] Add accessibilityIdentifier in ios/DemoApp/ if missing
- [ ] Add test method in DemoAppUITests.swift
- [ ] Mirror scenario in Espresso (see espresso skill) for shared flows
- [ ] Update test-data/ if assertions use shared JSON
- [ ] Ask user to run ./scripts/run-ios.sh
```

### Static screen (smoke)

```swift
@MainActor
func testHomeScreenShowsWelcomeAndProductDetails() throws {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(app.staticTexts["welcome_title"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["product_name"].exists)
    XCTAssertTrue(app.staticTexts["product_price"].exists)
}
```

Visible text queries are OK for fixed copy (`"Welcome to Mobile UI Demo"`) but identifiers are preferred for maintenance.

### Async / network (weather pattern)

Open-Meteo HTTPS call — needs network; may fail offline in CI. Note in PRs when adding similar tests.

```swift
@MainActor
func testGetWeatherShowsSanFranciscoTemperatureInFahrenheit() throws {
    let app = XCUIApplication()
    app.launch()

    app.buttons["get_weather_button"].tap()

    let weatherResult = app.staticTexts["weather_result"]
    XCTAssertTrue(weatherResult.waitForExistence(timeout: 15))

    let summary = weatherResult.label
    XCTAssertTrue(summary.contains("San Francisco"))
    XCTAssertNotNil(summary.range(of: #"\d+(\.\d+)?°F"#, options: .regularExpression))
}
```

Query types: `staticTexts`, `buttons`, `textFields`, `otherElements` — pick what SwiftUI exposes for the control.

## Naming

- **Class:** `DemoAppUITests` (single class is fine)
- **Methods:** `testFeatureExpectedOutcome` (camelCase, `test` prefix)

## Simulator config

Optional `.env` overrides: `IOS_SIMULATOR_NAME`, `IOS_SIMULATOR_OS`.

## Anti-patterns

- `sleep` / arbitrary delays instead of `waitForExistence`
- Fragile selectors tied to localization or changing copy
- Hand-editing `ios/DemoApp.xcodeproj`
- Network UI tests in CI without documenting connectivity requirement

## Further reading

- [reference.md](reference.md) — queries, troubleshooting
- [docs/test-strategy.md](../../docs/test-strategy.md)
- [docs/ios-setup.md](../../docs/ios-setup.md)
- [docs/troubleshooting.md](../../docs/troubleshooting.md)

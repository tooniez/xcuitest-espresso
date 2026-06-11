# XCUITest Reference

## Common queries

```swift
let app = XCUIApplication()
app.launch()

// By accessibility identifier (preferred)
app.buttons["get_weather_button"].tap()
app.staticTexts["welcome_title"]

// By visible label (static copy only)
app.staticTexts["Welcome to Mobile UI Demo"]

// Wait after launch or network
element.waitForExistence(timeout: 5)

// Read dynamic label
let label = app.staticTexts["weather_result"].label

// Regex assertion
XCTAssertNotNil(label.range(of: #"\d+(\.\d+)?°F"#, options: .regularExpression))
```

## SwiftUI accessibility

```swift
Text("Example Product")
    .accessibilityIdentifier("product_name")

Button("Get Weather") { ... }
    .accessibilityIdentifier("get_weather_button")

if let weatherResult {
    Text(weatherResult)
        .accessibilityIdentifier("weather_result")
}
```

## test-data

`test-data/products.json` — home screen asserts `name` and `$9.99` price. Load from test bundle for data-driven cases; document the fixture path in the test.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Element not found | Add `accessibilityIdentifier`; increase `waitForExistence` timeout |
| Flaky after tap | Longer timeout on result element; verify network for API flows |
| Fails in CI only | Weather tests need internet; iOS CI runs on macOS |
| Target missing | Regenerate with `xcodegen` from `ios/project.yml` |

## CI

`github/workflows/ios-ui-tests.yml` → `./scripts/run-ios.sh`

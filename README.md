# Mobile UI Automation Demo

A demonstration project showcasing UI test automation for Android and iOS platforms.

## Structure

### Repository

| Path | Purpose |
|------|---------|
| `android/` | Gradle app module — Kotlin UI + Espresso tests (generated) |
| `ios/` | SwiftUI app + XCUITest target (generated via XcodeGen) |
| `test-data/` | Shared JSON fixtures |
| `reports/` | Local test output (`reports/android`, `reports/ios/*.xcresult`) |
| `docs/` | Setup, strategy, and troubleshooting guides |
| `scripts/` | Scaffold and test runner scripts |
| `github/workflows/` | CI workflows (reuse the same `run-*.sh` scripts) |

Run `./scripts/scaffold-all.sh` first if `android/` or `ios/` are missing.

### Android (`android/`)

Standard single-module Gradle layout. **UI tests live in the `androidTest` source set** (instrumented Espresso tests run on a device/emulator).

```
android/
├── app/
│   ├── src/
│   │   ├── main/                          # App under test
│   │   │   ├── java/.../MainActivity.kt
│   │   │   ├── res/layout/activity_main.xml
│   │   │   └── AndroidManifest.xml
│   │   └── androidTest/                   # ← Espresso UI tests
│   │       └── java/.../MainActivityEspressoTest.kt
│   └── build.gradle.kts                   # Espresso + AndroidX Test deps
├── gradlew
├── settings.gradle.kts
└── build.gradle.kts
```

| Item | Location |
|------|----------|
| Sample UI test | `android/app/src/androidTest/java/com/example/mobileuiautomationdemo/MainActivityEspressoTest.kt` |
| Framework | Espresso 3.7 + AndroidX Test (JUnit4, `ActivityScenarioRule`) |
| Run command | `./scripts/run-android.sh` → `./gradlew connectedDebugAndroidTest` |
| Reports | HTML under `android/app/build/reports/androidTests/` (see [Reporting](docs/reporting.md)) |

### iOS (`ios/`)

XcodeGen project with separate app and UI-test targets. **UI tests live in the `DemoAppUITests` target** (XCUITest runs on the iOS Simulator).

```
ios/
├── DemoApp/                    # App under test (SwiftUI)
│   ├── DemoAppApp.swift
│   └── ContentView.swift
├── DemoAppUITests/             # ← XCUITest suite
│   └── DemoAppUITests.swift
├── project.yml                 # XcodeGen spec (source of truth for targets)
└── DemoApp.xcodeproj/          # Generated — do not hand-edit; regenerate with xcodegen
```

| Item | Location |
|------|----------|
| Sample UI test | `ios/DemoAppUITests/DemoAppUITests.swift` |
| Framework | XCUITest (`XCUIApplication`, `XCTestCase`) |
| Run command | `./scripts/run-ios.sh` → `xcodebuild test` on simulator |
| Reports | `reports/ios/DemoApp.xcresult` (Xcode result bundle) |

Both platforms assert the same demo home screen copy (`Welcome to Mobile UI Demo`, product name, price) and include a **Get Weather** flow that calls Open-Meteo over HTTPS (see [Charles Proxy demo](docs/charles-proxy.md)).

## Network / API demo (Charles Proxy)

Tap **Get Weather** in either app (or run the weather UI tests) to issue a real HTTPS GET to `api.open-meteo.com`. Use [Charles Proxy](docs/charles-proxy.md) on macOS to inspect the request URL, query parameters, JSON response, and timing.

| Platform | Weather UI test |
|----------|-----------------|
| Android | `MainActivityWeatherEspressoTest.kt` |
| iOS | `testGetWeatherShowsSanFranciscoTemperatureInFahrenheit` |

Fixture: [`test-data/weather.json`](test-data/weather.json).

Add new tests alongside the existing files in each platform’s test directory above.

## Quick start

Scaffold both native projects, then run tests:

```bash
cp .env.example .env   # optional — edit simulator/package overrides
chmod +x scripts/*.sh scripts/lib/common.sh
./scripts/scaffold-all.sh
./scripts/run-all.sh       # Android + iOS (or run platforms individually)
./scripts/run-android.sh   # needs emulator/device
./scripts/run-ios.sh       # needs macOS + Xcode
```

Configuration lives in `.env` (see `.env.example`). Scripts fall back to sensible defaults when a variable is unset; iOS auto-detects a simulator when `IOS_SIMULATOR_NAME` / `IOS_SIMULATOR_OS` are empty.

### Android emulator (before tests)

Android UI tests need a **booted** emulator or a USB device. Start an AVD from the terminal, wait until `adb` sees it, then run the test scripts.

**List available AVDs:**

```bash
emulator -list-avds
```

If `emulator` is not on `PATH`, use the SDK path (macOS default):

```bash
$HOME/Library/Android/sdk/emulator/emulator -list-avds
```

**Start an emulator in the background** (replace `<avd-name>` with one from the list above, e.g. `Pixel_10_Pro`):

```bash
emulator -avd <avd-name> &
```

Or with the full SDK path:

```bash
$HOME/Library/Android/sdk/emulator/emulator -avd <avd-name> &
```

**Wait until the device is ready:**

```bash
adb wait-for-device
adb shell getprop sys.boot_completed   # repeat until output is 1
adb devices                            # should show a line ending in "device"
```

**Run tests:**

```bash
./scripts/run-all.sh
# or Android only:
./scripts/run-android.sh
```

**GUI alternative:** Android Studio → **Device Manager** → start (▶) your virtual device, then confirm with `adb devices`.

If no emulator is connected, `run-all.sh` skips Android with a warning and continues with iOS on macOS. Use `./scripts/run-all.sh --ios-only` to skip Android explicitly.

See [docs/getting-started.md](docs/getting-started.md) for prerequisites. See [docs/troubleshooting.md](docs/troubleshooting.md) for errors and fixes from initial setup.

## Scripts

| Script | Purpose |
|--------|---------|
| `scaffold-all.sh` | Generate Android + iOS native projects |
| `scaffold-android.sh` | Gradle app module + Espresso test |
| `scaffold-ios.sh` | SwiftUI app + XCUITest + Xcode project |
| `run-all.sh` | Run Android then iOS; skips unavailable platforms (use `--ios-only` / `--android-only`) |
| `run-android.sh` | `connectedDebugAndroidTest` |
| `run-ios.sh` | `xcodebuild test` on simulator |

Pass `--force` to scaffold scripts to overwrite generated files.

## Documentation

- [Getting started](docs/getting-started.md)
- [Android setup](docs/android-setup.md)
- [iOS setup](docs/ios-setup.md)
- [Troubleshooting & learnings](docs/troubleshooting.md)
- [Test strategy](docs/test-strategy.md)
- [Charles Proxy demo](docs/charles-proxy.md) — includes `adb` / `xcodebuild` debug commands
- [Architecture](docs/architecture.md)
- [Reporting](docs/reporting.md)

# Mobile UI Automation Demo

A demonstration project showcasing mobile test automation for Android and iOS using the **testing pyramid** (unit → integration → UI).

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

Gradle layout with three test layers:

```
android/app/src/
├── main/                    # App under test
├── test/                    # Unit (JVM) — WeatherClient parsing/formatting
└── androidTest/
    ├── integration/         # MockWebServer + WeatherClient HTTP
    └── ui/                  # Espresso smoke tests
```

| Layer | Location | Run |
|-------|----------|-----|
| Unit | `app/src/test/.../WeatherClientTest.kt` | `./scripts/run-android-unit.sh` |
| Integration | `app/src/androidTest/.../integration/` | `./scripts/run-android.sh` (emulator) |
| UI | `app/src/androidTest/.../ui/` | `./scripts/run-android.sh` (emulator) |

Fixtures load from shared [`test-data/`](test-data/) via Gradle `sourceSets` resources.

### iOS (`ios/`)

XcodeGen project with unit and UI test targets:

```
ios/
├── DemoApp/                 # App under test (SwiftUI)
├── DemoAppTests/            # Unit + integration (XCTest host)
├── DemoAppUITests/          # UI smoke tests (XCUITest)
├── project.yml
└── DemoApp.xcodeproj/       # Regenerate with xcodegen after project.yml edits
```

| Layer | Location | Run |
|-------|----------|-----|
| Unit / integration | `ios/DemoAppTests/` | `./scripts/run-ios-unit.sh` |
| UI | `ios/DemoAppUITests/` | `./scripts/run-ios.sh` |

Both platforms assert the same home screen copy and a **Get Weather** flow. UI tests use mocks (no live API in CI). Live HTTPS is for manual [Charles Proxy](docs/charles-proxy.md) demos — see [Test strategy](docs/test-strategy.md).

## Network / API demo (Charles Proxy)

Tap **Get Weather** in either app to issue a real HTTPS GET to `api.open-meteo.com`. Use [Charles Proxy](docs/charles-proxy.md) on macOS to inspect traffic. Automated UI tests use mocks; run `WeatherClientLiveIntegrationTest` manually on Android for live API checks.

| Fixture | Purpose |
|---------|---------|
| [`test-data/open-meteo-forecast-response.json`](test-data/open-meteo-forecast-response.json) | Unit/integration parsing |
| [`test-data/weather.json`](test-data/weather.json) | API metadata for Charles docs |

See [Test strategy](docs/test-strategy.md) for pyramid conventions and CI layout.

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
| `run-android-unit.sh` | JVM unit tests (`testDebugUnitTest`) |
| `run-ios-unit.sh` | `DemoAppTests` on simulator |
| `run-android.sh` | `connectedDebugAndroidTest` (integration + UI) |
| `run-ios.sh` | `xcodebuild test` on simulator (UI) |

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

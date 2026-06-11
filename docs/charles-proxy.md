# Charles Proxy demo — weather API traffic

Use this guide to capture and inspect the **Get Weather** HTTPS call from the demo apps. Both platforms call Open-Meteo when you tap **Get Weather** or run the weather UI tests.

## What you should see in Charles

When the request succeeds, Charles shows something like:

```http
GET /v1/forecast?latitude=37.7749&longitude=-122.4194&current=temperature_2m&temperature_unit=fahrenheit HTTP/1.1
Host: api.open-meteo.com
```

The JSON response includes `current.temperature_2m`. The app displays:

`San Francisco: 62.4°F`

Fixture coordinates live in [`test-data/weather.json`](../test-data/weather.json).

## Prerequisites

- [Charles Proxy](https://www.charlesproxy.com/) installed on macOS
- Network access from simulator/emulator
- For **HTTPS body inspection**: Charles root certificate installed and trusted on the target platform

Charles default proxy port: **8888**.

---

## 1. Configure Charles (all platforms)

1. Start Charles.
2. **Proxy → SSL Proxying Settings…**
3. Enable **SSL Proxying**.
4. Add location: Host `api.open-meteo.com`, Port `443`.
5. Leave **Proxy → macOS Proxy** **off** when demoing Android only (macOS proxy can interfere with emulator routing). Enable it for **iOS Simulator** demos.

---

## 2. Android Emulator (full setup)

The Android emulator runs in a virtual network. Your Mac (where Charles listens) is reachable at **`10.0.2.2`** — not `localhost` and not your Mac’s Wi‑Fi IP.

```text
Emulator app  →  10.0.2.2:8888  →  Charles on Mac  →  api.open-meteo.com
```

Debug builds of this app trust **user-installed CA certificates** (see `android/app/src/debug/res/xml/network_security_config.xml`) so Charles HTTPS interception works after you install its cert on the emulator.

### Step 1 — Start an emulator

List AVDs:

```bash
emulator -list-avds
```

Start one in the background (use your AVD name, e.g. `Pixel_9_Pro`):

```bash
emulator -avd Pixel_9_Pro &
```

If `emulator` is not on `PATH`:

```bash
$HOME/Library/Android/sdk/emulator/emulator -avd Pixel_9_Pro &
```

Wait until the device is ready:

```bash
adb wait-for-device
adb shell getprop sys.boot_completed   # repeat until output is 1
adb devices                            # should show a line ending in "device"
```

See also [README — Android emulator](../README.md#android-emulator-before-tests).

### Step 2 — Route emulator traffic through Charles

Pick **one** method.

**Option A — Start emulator with proxy (recommended)**

Restart the AVD with an HTTP proxy pointing at the Mac host:

```bash
emulator -avd Pixel_9_Pro -http-proxy 10.0.2.2:8888 &
```

**Option B — Android Studio extended controls**

1. Android Studio → **Device Manager** → start the emulator.
2. **⋮** (Extended controls) → **Settings** → **Proxy**.
3. Host: `10.0.2.2`, Port: `8888`.
4. Apply and cold-boot the emulator if traffic still bypasses Charles.

**Option C — `adb` global HTTP proxy**

With the emulator running:

```bash
adb shell settings put global http_proxy 10.0.2.2:8888
```

To clear later:

```bash
adb shell settings put global http_proxy :0
```

### Step 3 — Install Charles root certificate on the emulator

1. In Charles: **Help → SSL Proxying → Save Charles Root Certificate…**
   Save as `charles.pem` (or `.crt`) on your Mac.
2. Push the cert to the emulator:

```bash
adb push charles.pem /sdcard/Download/charles.pem
```

3. On the emulator:
   - **Settings → Security & privacy → Encryption & credentials**
   - **Install a certificate → CA certificate**
   - Open **charles.pem** from Downloads and confirm the install warning.

On older Android images the path may be **Settings → Security → Install from storage**.

### Step 4 — Verify Charles sees traffic

1. Confirm Charles is running and SSL Proxying includes `api.open-meteo.com:443`.
2. Install and open the demo app on the emulator (or run tests — they install the debug APK automatically).
3. Tap **Get Weather**.
4. In Charles **Sequence**, look for `api.open-meteo.com` with a decrypted **JSON** body.

If you only see `CONNECT` lines or SSL errors, re-check Step 2 (proxy) and Step 3 (cert). Reinstall the app after changing the cert if needed:

```bash
cd android && ./gradlew installDebug
```

### Step 5 — Run the demo via UI tests

With the emulator booted and proxy/cert configured:

```bash
./scripts/run-android.sh
```

The Espresso test `getWeather_showsSanFranciscoTemperatureInFahrenheit` taps **Get Weather** and triggers the same HTTPS call you can inspect in Charles.

### Android emulator checklist

| Step | Done when |
|------|-----------|
| Emulator booted | `adb devices` shows `device` |
| Proxy set | Charles shows *any* traffic from the emulator (e.g. connectivity checks) |
| Charles cert installed | Settings shows Charles Proxy CA under user credentials |
| SSL Proxying enabled | Host `api.open-meteo.com`, port `443` |
| Debug app installed | **Get Weather** shows temperature, not “Could not load weather” |

---

## 3. iOS Simulator

Charles often captures iOS Simulator traffic when **Proxy → macOS Proxy** is enabled.

If HTTPS bodies are empty or encrypted:

1. **Help → SSL Proxying → Install Charles Root Certificate** on the Mac.
2. Open **Keychain Access** → trust the Charles certificate for SSL.
3. In Simulator: **Settings → General → About → Certificate Trust Settings** → enable full trust for Charles (if a device profile was installed).

### Run the demo

```bash
./scripts/run-ios.sh
```

Or launch the app manually, tap **Get Weather**, and watch Charles.

For automated live traffic, remove `@Ignore` from `WeatherClientLiveIntegrationTest` and run it on a device/emulator, or tap **Get Weather** manually in the app. UI tests use mocks and do not call Open-Meteo.

---

## 4. Inspect traffic in Charles

1. Trigger **Get Weather** (manual tap or UI test).
2. In the **Sequence** list, find `api.open-meteo.com`.
3. Select the request:
   - **Overview** — full URL and query parameters
   - **JSON** — response body with `current.temperature_2m`
   - **Timing** — latency breakdown
   - **SSL** — certificate details (when SSL proxying works)

## 5. Teaching moments (optional)

- **Breakpoints** — pause and edit a request before it reaches Open-Meteo.
- **Map Local** — return a fixed JSON file to demo error handling without changing app code.
- **Repeat test run** — show the same URL/params on every test execution.

---

## 6. Debug commands (Charles + tests)

Handy commands while pairing Charles with manual taps or UI tests. Package/bundle id for this repo: **`com.example.mobileuiautomationdemo`**.

### Android — `adb` / Gradle

**Device & proxy**

```bash
# List connected emulators/devices
adb devices -l

# Confirm global HTTP proxy (expect 10.0.2.2:8888 when using Charles)
adb shell settings get global http_proxy

# Set / clear proxy without restarting the AVD
adb shell settings put global http_proxy 10.0.2.2:8888
adb shell settings put global http_proxy :0

# Quick check that the emulator can reach the Mac host
adb shell ping -c 1 10.0.2.2
```

**App lifecycle (trigger Get Weather manually while watching Charles)**

```bash
# Install debug APK only (no tests)
cd android && ./gradlew installDebug

# Launch main screen
adb shell am start -n com.example.mobileuiautomationdemo/.MainActivity

# Force-stop before a clean retry
adb shell am force-stop com.example.mobileuiautomationdemo
```

**Run tests**

```bash
# Full Espresso suite (both home + weather tests)
./scripts/run-android.sh

# Equivalent Gradle invocation
cd android && ./gradlew connectedDebugAndroidTest

# Weather test only — good for a focused Charles demo
cd android && ./gradlew connectedDebugAndroidTest \
  -Pandroid.testInstrumentationRunnerArguments.class=com.example.mobileuiautomationdemo.integration.WeatherClientLiveIntegrationTest

# Same single test via adb (app must already be installed)
adb shell am instrument -w -r \
  -e class com.example.mobileuiautomationdemo.integration.WeatherClientLiveIntegrationTest \
  com.example.mobileuiautomationdemo.test/androidx.test.runner.AndroidJUnitRunner
```

**Logs (SSL / network failures while Charles is enabled)**

```bash
adb logcat -c
adb logcat *:E | grep -iE 'SSL|Certificate|Weather|mobileuiautomationdemo'
```

**Charles on the Mac**

```bash
# Confirm Charles is listening on the default port
lsof -i :8888
```

### iOS — `simctl` / `xcodebuild`

**Simulator**

```bash
# List booted and available simulators
xcrun simctl list devices available

# Boot a specific device (use name or UDID from the list)
xcrun simctl boot "iPhone 16"

# Wait until boot finished
xcrun simctl bootstatus booted

# Launch / terminate the demo app (tap Get Weather in the Simulator UI)
xcrun simctl launch booted com.example.mobileuiautomationdemo
xcrun simctl terminate booted com.example.mobileuiautomationdemo
```

**Run tests**

```bash
# Full XCUITest suite
./scripts/run-ios.sh

# Weather test only — triggers one Open-Meteo call for Charles
xcodebuild test \
  -project ios/DemoApp.xcodeproj \
  -scheme DemoApp \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
  -only-testing:DemoAppTests/WeatherClientIntegrationTests/testFetchCurrentTemperatureFahrenheitUsesStubbedHTTPResponse \
  -resultBundlePath reports/ios/DemoApp.xcresult \
  CODE_SIGNING_ALLOWED=NO
```

Replace `name` / `OS` with values from `xcrun simctl list devices available`, or use `.env` (`IOS_SIMULATOR_NAME`, `IOS_SIMULATOR_OS`) with `run-ios.sh`.

**Inspect failures**

```bash
# Open the result bundle in Xcode (after run-ios.sh)
open reports/ios/DemoApp.xcresult

# Stream simulator logs while tapping Get Weather
xcrun simctl spawn booted log stream --level debug \
  --predicate 'process == "DemoApp"'
```

**Charles on the Mac (iOS Simulator)**

Enable **Proxy → macOS Proxy** in Charles so Simulator traffic routes through it. Verify with `lsof -i :8888` as above.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| No requests in Charles (Android) | Proxy must be `10.0.2.2:8888`, not `127.0.0.1`; restart emulator with `-http-proxy` or set `adb shell settings put global http_proxy 10.0.2.2:8888` |
| No requests in Charles (iOS) | Enable **Proxy → macOS Proxy** in Charles |
| CONNECT tunnels only, no JSON body | Enable SSL Proxying for `api.open-meteo.com:443`; install/trust Charles cert on emulator/simulator |
| Android SSL / certificate errors | Install Charles CA on emulator; use a **debug** build (release builds do not trust user CAs in this project) |
| App shows "Could not load weather" | Test without Charles first; then verify proxy + cert; check emulator has internet |
| UI test fails on CI | Weather tests need internet; run locally for Charles demos |

## Related docs

- [Android setup](android-setup.md) — SDK, Gradle, Espresso
- [Test strategy](test-strategy.md) — network/API demo layer
- [Getting started](getting-started.md) — prerequisites
- [Troubleshooting](troubleshooting.md) — platform test issues

# Troubleshooting & Learnings

Errors encountered while scaffolding, building, and running UI tests in this repo — with root causes and fixes applied.

Use this as a runbook when local runs or CI fail in similar ways.

---

## Android

### Espresso fails on Android 16 with `InputManager.getInstance`

**Symptom**

```
java.lang.RuntimeException: java.lang.NoSuchMethodException:
  android.hardware.input.InputManager.getInstance []
  at androidx.test.espresso.base.InputManagerEventInjectionStrategy.initialize(...)
```

**Cause**

Espresso **3.6.1** and older AndroidX Test libraries use reflection to call the hidden `InputManager.getInstance()` API. That method is not available on **Android 16 (API 36)** emulators/devices.

**Fix**

Upgrade instrumentation dependencies in `android/app/build.gradle.kts`:

```kotlin
androidTestImplementation("androidx.test:core:1.7.0")
androidTestImplementation("androidx.test.ext:junit:1.3.0")
androidTestImplementation("androidx.test:runner:1.7.0")
androidTestImplementation("androidx.test:rules:1.7.0")
androidTestImplementation("androidx.test.espresso:espresso-core:3.7.0")
```

Espresso **3.7.0+** uses `getSystemService` instead of reflective `InputManager.getInstance` ([AndroidX Test release notes](https://developer.android.com/jetpack/androidx/releases/test)).

**Verify**

```bash
adb devices   # emulator or device listed as "device"
./scripts/run-android.sh
```

---

### Emulator fails to start — insufficient disk space

**Symptom**

```
FATAL | Your device does not have enough disk space to run avd: `Pixel_9_Pro`.
```

**Cause**

AVD system images and runtime snapshots need several GB free on the system volume.

**Fix**

1. Free disk space (empty Trash, remove old AVDs, clear Gradle caches if needed).
2. Confirm: `df -h /` shows adequate free space.
3. Start emulator manually, then run tests:

```bash
$HOME/Library/Android/sdk/emulator/emulator -avd Pixel_9_Pro &
# wait until: adb devices shows "device"
./scripts/run-android.sh
```

**Learning**

`connectedAndroidTest` requires a **booted** device. A wait loop that times out with an empty `adb devices` list usually means the emulator never started — not that Gradle or Espresso is broken.

---

### `SDK location not found`

**Symptom**

Gradle error referencing missing Android SDK path.

**Fix**

Create `android/local.properties` (gitignored):

```properties
sdk.dir=/Users/YOU/Library/Android/sdk
```

Or set `ANDROID_HOME` and open the project in Android Studio once to generate the file.

---

### `gradlew` not found

**Symptom**

`./scripts/run-android.sh` exits because `android/gradlew` is missing.

**Fix**

```bash
cd android && gradle wrapper --gradle-version 8.7
```

Scaffold also attempts this when Gradle is installed on the machine.

---

### Kotlin sources under wrong package folder after scaffold

**Symptom**

Build cannot find `MainActivity` or package path looks like `com\/example\/...` on disk.

**Cause**

Early scaffold script used `${PACKAGE//./\/}` in bash, which produced a **literal backslash** directory name instead of nested folders.

**Fix**

Scaffold now uses:

```bash
PACKAGE_PATH="$(echo "${PACKAGE}" | tr '.' '/')"
```

Re-scaffold with `--force` or move files into `com/example/mobileuiautomationdemo/`.

---

## iOS

### `DemoApp.xcodeproj` missing

**Symptom**

`run-ios.sh` fails: project not found.

**Cause**

iOS sources are generated from `project.yml`, but the `.xcodeproj` is created by **XcodeGen**, not by the scaffold script alone.

**Fix**

```bash
brew install xcodegen
cd ios && xcodegen generate
```

`run-ios.sh` will auto-run XcodeGen if the project is missing and the tool is on `PATH`.

---

### XcodeGen install / generate errors

**Symptom**

- `xcodegen not found` during scaffold
- Rare temp-dir collision: `The file "XcodeGen" couldn't be saved... File exists`

**Fix**

1. Install: `brew install xcodegen`
2. On collision, remove stale output and retry:

```bash
cd ios && rm -rf DemoApp.xcodeproj && xcodegen generate
```

---

### Simulator not found (`xcodebuild` destination error)

**Symptom**

```
Unable to find a destination matching the provided destination specifier
```

**Cause**

Default simulator names/OS versions differ per machine (e.g. **iPhone 17e** on iOS **26.5** vs iPhone 16 on iOS 18).

**Fix**

List available simulators:

```bash
xcrun simctl list devices available
```

Override for `run-ios.sh`:

Set simulator in `.env` (quote names with spaces):

```bash
IOS_SIMULATOR_NAME="iPhone 17e"
IOS_SIMULATOR_OS=26.5
./scripts/run-ios.sh
```

If env vars are unset, `run-ios.sh` auto-picks the first available iPhone simulator.

---

## Shared / repo hygiene

### Build artifacts committed or cluttering `git status`

**Fix**

Root `.gitignore` excludes:

- Android: `.gradle/`, `build/`, `local.properties`, APK outputs
- iOS: `build/`, `DerivedData/`, `xcuserdata`, dSYM/IPA
- Local: `reports/`

Generated `ios/DemoApp.xcodeproj` remains tracked so the app opens without XcodeGen on every clone (optional policy — regenerate from `project.yml` in CI if preferred).

---

## Quick reference — verified working stack

| Check | Android | iOS |
|-------|---------|-----|
| App builds | `./gradlew assembleDebug` | `xcodebuild build -scheme DemoApp …` |
| UI tests | `./scripts/run-android.sh` | `./scripts/run-ios.sh` |
| Test count | 2 Espresso tests (home + weather) | 2 XCUITests (home + weather) |
| Charles + debug cmds | [charles-proxy.md](charles-proxy.md#6-debug-commands-charles--tests) | [charles-proxy.md](charles-proxy.md#6-debug-commands-charles--tests) |
| Blockers resolved | Espresso 3.7.0 on API 36; disk space for AVD | XcodeGen; simulator auto-detect |

---

## Related docs

- [Android setup](android-setup.md)
- [iOS setup](ios-setup.md)
- [Getting started](getting-started.md)
- [Reporting](reporting.md) — where HTML / `.xcresult` reports land after a successful run

# Architecture

## Overview

```
┌─────────────────────────────────────────────────────────┐
│                    scripts/ (orchestration)              │
│  scaffold-*.sh  →  generate native projects              │
│  run-*.sh       →  execute platform UI test suites       │
└──────────────────────────┬──────────────────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         ▼                                   ▼
┌─────────────────┐                 ┌─────────────────┐
│ android/        │                 │ ios/            │
│ Kotlin app      │                 │ SwiftUI app     │
│ Espresso tests  │                 │ XCUITest target │
│ Gradle + AGP    │                 │ XcodeGen + Xcode│
└────────┬────────┘                 └────────┬────────┘
         │                                   │
         └─────────────────┬─────────────────┘
                           ▼
                  ┌─────────────────┐
                  │ test-data/      │
                  │ JSON fixtures   │
                  └─────────────────┘
```

## Native apps

Both platforms render a minimal home screen with product copy intended for UI assertions. The scaffold scripts encode this layout so Android and iOS stay in sync without a shared UI framework.

## Scaffolding

| Script | Output |
|--------|--------|
| `scaffold-android.sh` | Gradle project, `MainActivity`, Espresso test, wrapper config |
| `scaffold-ios.sh` | SwiftUI sources, `project.yml`, XCUITest target; runs XcodeGen |
| `scaffold-all.sh` | Both of the above |

Templates live inside the shell scripts (heredocs) so the repo stays self-contained without external cookiecutter templates.

## Test execution

- **Android**: `./gradlew connectedDebugAndroidTest` via `run-android.sh`
- **iOS**: `xcodebuild test` on a simulator via `run-ios.sh`; results land in `reports/ios/*.xcresult`

## CI integration

GitHub Actions reuse the same shell entry points, keeping local and pipeline behavior aligned. Android runs on Linux agents with an emulator step (add when hardening CI); iOS requires `macos-latest`.

## Related docs

- [Getting started](getting-started.md)
- [Android setup](android-setup.md)
- [iOS setup](ios-setup.md)
- [Troubleshooting & learnings](troubleshooting.md)

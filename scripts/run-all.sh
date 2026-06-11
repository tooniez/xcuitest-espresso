#!/usr/bin/env bash
# Run Android and iOS UI test suites.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

RUN_ANDROID=1
RUN_IOS=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Run UI tests on one or both platforms. By default, skips platforms that are
not ready (no Android device, or iOS unavailable on this machine) with a warning.

Options:
  --android-only   Run Android tests only (fail if no device/emulator)
  --ios-only       Run iOS tests only
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --android-only)
      RUN_IOS=0
      shift
      ;;
    --ios-only)
      RUN_ANDROID=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1 (try --help)"
      ;;
  esac
done

failures=0
ran=0

run_android() {
  if [[ "${RUN_ANDROID}" -ne 1 ]]; then
    return 0
  fi

  if ! android_device_available; then
    if [[ "${RUN_IOS}" -eq 0 ]]; then
      ensure_android_device
    fi
    warn "Skipping Android: no emulator or device connected."
    warn "Start one in Android Studio → Device Manager, or run: ./scripts/run-all.sh --ios-only"
    return 0
  fi

  ran=1
  if ! "${SCRIPT_DIR}/run-android.sh"; then
    failures=$((failures + 1))
  fi
}

run_ios() {
  if [[ "${RUN_IOS}" -ne 1 ]]; then
    return 0
  fi

  if ! ios_tests_available; then
    if [[ "${RUN_ANDROID}" -eq 0 ]]; then
      die "iOS tests require macOS with Xcode and a scaffolded ios/ project. Run ./scripts/scaffold-ios.sh first."
    fi
    warn "Skipping iOS: requires macOS, Xcode, and ios/ project."
    return 0
  fi

  ran=1
  if ! "${SCRIPT_DIR}/run-ios.sh"; then
    failures=$((failures + 1))
  fi
}

run_android
run_ios

if [[ "${ran}" -eq 0 ]]; then
  die "No test suites ran. Connect an Android device/emulator and/or run on macOS with Xcode, or use --android-only / --ios-only."
fi

if [[ "${failures}" -gt 0 ]]; then
  die "${failures} platform test suite(s) failed."
fi

log "All platform UI tests complete."

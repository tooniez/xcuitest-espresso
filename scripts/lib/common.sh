#!/usr/bin/env bash
# Shared helpers and config for mobile-ui-automation-demo scripts.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANDROID_DIR="${ROOT_DIR}/android"
IOS_DIR="${ROOT_DIR}/ios"
REPORTS_DIR="${ROOT_DIR}/reports"

load_env() {
  local env_file="${ROOT_DIR}/.env"
  [[ -f "${env_file}" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  source "${env_file}"
  set +a
}

apply_defaults() {
  IOS_SCHEME="${IOS_SCHEME:-DemoApp}"
  IOS_SIMULATOR_UDID="${IOS_SIMULATOR_UDID:-}"
  IOS_SIMULATOR_NAME="${IOS_SIMULATOR_NAME:-}"
  IOS_SIMULATOR_OS="${IOS_SIMULATOR_OS:-}"
  ANDROID_PACKAGE="${ANDROID_PACKAGE:-com.example.mobileuiautomationdemo}"
  ANDROID_GRADLE_TASK="${ANDROID_GRADLE_TASK:-connectedDebugAndroidTest}"
  ANDROID_UNIT_GRADLE_TASK="${ANDROID_UNIT_GRADLE_TASK:-testDebugUnitTest}"
  GRADLE_VERSION="${GRADLE_VERSION:-8.7}"
}

load_env
apply_defaults

log() {
  printf '[demo] %s\n' "$*"
}

warn() {
  printf '[demo] WARN: %s\n' "$*" >&2
}

die() {
  printf '[demo] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  local hint="${2:-Install $cmd and retry.}"
  command -v "$cmd" >/dev/null 2>&1 || die "$cmd is required. $hint"
}

ensure_executable() {
  chmod +x "$1"
}

ensure_dir() {
  mkdir -p "$@"
}

path_exists() {
  [[ -e "$1" ]]
}

confirm_or_force() {
  local marker="$1"
  local force="${2:-0}"

  if path_exists "$marker" && [[ "$force" != "1" ]]; then
    die "Already scaffolded ($marker exists). Re-run with --force to regenerate."
  fi
}

require_ios_project_spec() {
  [[ -f "${IOS_DIR}/project.yml" ]] \
    || die "ios/project.yml not found. Add the XcodeGen spec and source trees under ios/ manually, then re-run scaffold."
}

require_android_project() {
  [[ -f "${ANDROID_DIR}/settings.gradle.kts" && -f "${ANDROID_DIR}/app/build.gradle.kts" ]] \
    || die "Android project files missing. Add android/ manually (Gradle files, app module, sources), then re-run scaffold."
}

scaffold_ios_project() {
  local force="${1:-0}"
  local marker="${IOS_DIR}/DemoApp.xcodeproj"

  confirm_or_force "$marker" "$force"
  require_ios_project_spec
  require_cmd xcodegen "Install with: brew install xcodegen"

  log "Generating DemoApp.xcodeproj from ios/project.yml (XcodeGen)"
  (cd "${IOS_DIR}" && xcodegen generate)
}

scaffold_android_wrapper() {
  local force="${1:-0}"
  local marker="${ANDROID_DIR}/gradlew"

  confirm_or_force "$marker" "$force"
  require_android_project

  if command -v gradle >/dev/null 2>&1; then
    log "Generating Gradle wrapper (Gradle ${GRADLE_VERSION})"
    (cd "${ANDROID_DIR}" && gradle wrapper --gradle-version "${GRADLE_VERSION}")
    return 0
  fi

  if [[ -x "${ANDROID_DIR}/gradlew" ]]; then
    log "Gradle CLI not found; using existing gradlew"
    return 0
  fi

  die "Gradle is not installed and gradlew is missing. Install Gradle or open android/ in Android Studio to create the wrapper."
}

resolve_ios_simulator() {
  if [[ -n "${IOS_SIMULATOR_UDID:-}" ]]; then
    return 0
  fi

  if [[ -n "${IOS_SIMULATOR_NAME}" && -n "${IOS_SIMULATOR_OS}" ]]; then
    return 0
  fi

  require_cmd xcrun "Install Xcode from the Mac App Store."
  local picked
  picked="$(
    xcrun simctl list devices available -j \
      | python3 -c "
import json, sys
data = json.load(sys.stdin)
runtimes = [
    r for r in data.get('devices', {})
    if 'iOS' in r and 'watchOS' not in r and 'tvOS' not in r and 'visionOS' not in r
]
for runtime in sorted(runtimes, reverse=True):
    os_ver = runtime.split('iOS-')[-1].replace('-', '.')
    for device in data['devices'][runtime]:
        name = device.get('name', '')
        if device.get('isAvailable') and name.startswith('iPhone'):
            print(name)
            print(os_ver)
            raise SystemExit
raise SystemExit('No available iPhone simulator found')
"
  )" || die "No available iPhone simulator. Set IOS_SIMULATOR_NAME and IOS_SIMULATOR_OS in .env (quote names with spaces)."

  IOS_SIMULATOR_NAME="$(sed -n '1p' <<<"${picked}")"
  IOS_SIMULATOR_OS="$(sed -n '2p' <<<"${picked}")"
  [[ -n "${IOS_SIMULATOR_NAME}" && -n "${IOS_SIMULATOR_OS}" ]] \
    || die "Failed to parse simulator from simctl output."
}

ios_destination() {
  if [[ -n "${IOS_SIMULATOR_UDID:-}" ]]; then
    printf 'platform=iOS Simulator,id=%s' "${IOS_SIMULATOR_UDID}"
    return
  fi
  printf 'platform=iOS Simulator,name=%s,OS=%s' "${IOS_SIMULATOR_NAME}" "${IOS_SIMULATOR_OS}"
}

android_device_available() {
  command -v adb >/dev/null 2>&1 \
    || return 1
  adb devices 2>/dev/null | awk 'NR>1 && $2=="device" { found=1 } END { exit !found }'
}

ensure_android_device() {
  require_cmd adb "Install Android SDK platform-tools and ensure adb is on PATH."
  android_device_available \
    || die "No Android emulator or device connected. Start an emulator (Android Studio → Device Manager) or plug in a device, then run adb devices to confirm."
}

ios_tests_available() {
  [[ "$(uname -s)" == "Darwin" ]] || return 1
  command -v xcodebuild >/dev/null 2>&1 || return 1
  [[ -d "${IOS_DIR}/DemoApp.xcodeproj" || -f "${IOS_DIR}/project.yml" ]]
}

ensure_ios_project() {
  [[ -d "${IOS_DIR}/DemoApp.xcodeproj" ]] && return 0
  scaffold_ios_project 0
}

ensure_android_gradlew() {
  [[ -x "${ANDROID_DIR}/gradlew" ]] && return 0
  scaffold_android_wrapper 0
}

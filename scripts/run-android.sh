#!/usr/bin/env bash
# Run Android Espresso UI tests.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

[[ -f "${ANDROID_DIR}/app/build.gradle.kts" ]] \
  || die "Android app module missing. Run ./scripts/scaffold-android.sh first."

ensure_android_gradlew
ensure_android_device
ensure_dir "${REPORTS_DIR}/android"

log "Running Android UI tests (${ANDROID_GRADLE_TASK})..."
(
  cd "${ANDROID_DIR}"
  ./gradlew "${ANDROID_GRADLE_TASK}" --stacktrace
)

log "Android tests complete. Reports: ${REPORTS_DIR}/android"

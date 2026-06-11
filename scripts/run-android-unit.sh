#!/usr/bin/env bash
# Run Android JVM unit tests (testing pyramid base layer).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

[[ -f "${ANDROID_DIR}/app/build.gradle.kts" ]] \
  || die "Android app module missing. Run ./scripts/scaffold-android.sh first."

ensure_android_gradlew

log "Running Android unit tests (${ANDROID_UNIT_GRADLE_TASK})..."
(
  cd "${ANDROID_DIR}"
  ./gradlew "${ANDROID_UNIT_GRADLE_TASK}" --stacktrace
)

log "Android unit tests complete."

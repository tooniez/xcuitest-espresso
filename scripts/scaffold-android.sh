#!/usr/bin/env bash
# Generate the Gradle wrapper for the committed Android project under android/.
# Gradle files, Kotlin sources, and Espresso tests are maintained manually.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

log "Scaffolding Android project under ${ANDROID_DIR}"
scaffold_android_wrapper "$FORCE"

log "Android scaffold complete."
log "Next: ./scripts/run-android.sh (requires emulator or device for connectedAndroidTest)"

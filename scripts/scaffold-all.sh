#!/usr/bin/env bash
# Generate CLI-derived artifacts for both platforms (Gradle wrapper + Xcode project).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/scaffold-android.sh" "$@"
"${SCRIPT_DIR}/scaffold-ios.sh" "$@"

log "All platforms scaffolded."

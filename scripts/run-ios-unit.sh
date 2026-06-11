#!/usr/bin/env bash
# Run iOS unit tests (DemoAppTests target).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_cmd xcodebuild "Install Xcode to run iOS unit tests."
ensure_ios_project
resolve_ios_simulator

DESTINATION="$(ios_destination)"

log "Running iOS unit tests (${DESTINATION})..."
xcodebuild test \
  -project "${IOS_DIR}/DemoApp.xcodeproj" \
  -scheme "${IOS_SCHEME}" \
  -destination "${DESTINATION}" \
  -only-testing:DemoAppTests \
  CODE_SIGNING_ALLOWED=NO

log "iOS unit tests complete."

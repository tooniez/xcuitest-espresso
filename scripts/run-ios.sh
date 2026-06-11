#!/usr/bin/env bash
# Run iOS XCUITest suite on a simulator via xcodebuild.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

require_cmd xcodebuild "Install Xcode from the Mac App Store."
ensure_ios_project
resolve_ios_simulator

DESTINATION="$(ios_destination)"
RESULT_BUNDLE="${REPORTS_DIR}/ios/DemoApp.xcresult"

ensure_dir "${REPORTS_DIR}/ios"
rm -rf "${RESULT_BUNDLE}"

if [[ -n "${IOS_SIMULATOR_UDID:-}" ]]; then
  log "Running iOS UI tests on simulator ${IOS_SIMULATOR_UDID}..."
else
  log "Running iOS UI tests on ${IOS_SIMULATOR_NAME} (iOS ${IOS_SIMULATOR_OS})..."
fi
xcodebuild test \
  -project "${IOS_DIR}/DemoApp.xcodeproj" \
  -scheme "${IOS_SCHEME}" \
  -destination "${DESTINATION}" \
  -resultBundlePath "${RESULT_BUNDLE}" \
  CODE_SIGNING_ALLOWED=NO

log "iOS tests complete. Result bundle: ${RESULT_BUNDLE}"

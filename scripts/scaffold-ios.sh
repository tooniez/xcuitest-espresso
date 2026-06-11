#!/usr/bin/env bash
# Generate DemoApp.xcodeproj from the committed XcodeGen spec (ios/project.yml).
# Swift sources and project.yml are maintained manually under ios/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

log "Scaffolding iOS project under ${IOS_DIR}"
scaffold_ios_project "$FORCE"

log "iOS scaffold complete."
log "Next: ./scripts/run-ios.sh (requires Xcode + iOS Simulator)"

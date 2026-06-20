#!/bin/zsh
set -e
set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$IOS_DIR/.." && pwd)"

FLUTTER_DIR="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

if [ ! -x "$FLUTTER_BIN" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

cd "$PROJECT_ROOT"

# Xcode Cloud can occasionally reach GitHub while failing to reach the
# default Flutter artifact bucket on storage.googleapis.com. Keep the default
# first, then retry with the official Flutter China mirror. The mirror can be
# overridden from CI with FLUTTER_STORAGE_BASE_URL if needed.
run_flutter_bootstrap() {
  local storage_base_url="${1:-}"

  rm -rf "$FLUTTER_DIR/bin/cache/dart-sdk" "$FLUTTER_DIR/bin/cache/downloads"

  if [ -n "$storage_base_url" ]; then
    export FLUTTER_STORAGE_BASE_URL="$storage_base_url"
    echo "Using Flutter storage mirror: $FLUTTER_STORAGE_BASE_URL"
  else
    unset FLUTTER_STORAGE_BASE_URL
    echo "Using default Flutter storage"
  fi

  flutter --version || return 1
  flutter config --no-analytics || return 1
  flutter precache --ios || return 1
  flutter pub get || return 1
}

if [ -n "${FLUTTER_STORAGE_BASE_URL:-}" ]; then
  run_flutter_bootstrap "$FLUTTER_STORAGE_BASE_URL"
else
  run_flutter_bootstrap "" || run_flutter_bootstrap "https://storage.flutter-io.cn"
fi

BUILD_NUMBER="${CI_BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
API_BASE_URL="${API_BASE_URL:-https://revision-api.yoahn.me}"
DART_DEFINE_API_BASE_URL="$(printf "API_BASE_URL=%s" "$API_BASE_URL" | base64 | tr -d '\n')"

cat <<EOF >> "$IOS_DIR/Flutter/Generated.xcconfig"

// Xcode Cloud overrides
FLUTTER_BUILD_NUMBER=$BUILD_NUMBER
DART_DEFINES=$DART_DEFINE_API_BASE_URL
EOF

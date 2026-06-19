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

flutter --version
flutter config --no-analytics
flutter precache --ios
flutter pub get

BUILD_NUMBER="${CI_BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
API_BASE_URL="${API_BASE_URL:-https://revision-api.yoahn.me}"
DART_DEFINE_API_BASE_URL="$(printf "API_BASE_URL=%s" "$API_BASE_URL" | base64 | tr -d '\n')"

cat <<EOF >> "$IOS_DIR/Flutter/Generated.xcconfig"

// Xcode Cloud overrides
FLUTTER_BUILD_NUMBER=$BUILD_NUMBER
DART_DEFINES=$DART_DEFINE_API_BASE_URL
EOF

# Marionette dev testing

This folder contains the dev-only entry point used to drive Revision Project
with Marionette on macOS and iOS simulators.

Nothing here is used by the normal production entry point. `lib/main.dart`
remains the shipped app entry.

## One-time setup

The project includes these dev dependencies:

```yaml
dev_dependencies:
  marionette_flutter: ^0.5.0
  marionette_mcp: ^0.5.0
```

Install packages after pulling the project:

```bash
flutter pub get
```

## Launch on macOS

```bash
flutter run -t dev/marionette_main.dart -d macos --debug
```

Copy the printed VM Service URI, for example:

```text
ws://127.0.0.1:59511/xxxx=/ws
```

Then connect Marionette to that URI.

## Launch on iOS simulator

Boot a simulator:

```bash
open -a Simulator
xcrun simctl list devices booted
```

Launch with the simulator id:

```bash
flutter run -t dev/marionette_main.dart -d <ios-simulator-id> --debug
```

Then connect Marionette to the printed VM Service URI.

## API target

The entry point uses the same `API_BASE_URL` dart define as the normal app.

Production API is the default from `AppConfig`. To test a local API:

```bash
flutter run \
  -t dev/marionette_main.dart \
  -d macos \
  --debug \
  --dart-define=API_BASE_URL=http://localhost:3000
```

Use the same flag for iOS.

## Logs

`dev/marionette_main.dart` injects a Dio interceptor so Marionette logs show
HTTP requests, responses and errors.

The logger intentionally does not print request headers or request bodies. This
keeps bearer tokens, credentials and PDF payloads out of logs while still making
API failures visible.

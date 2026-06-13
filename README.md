# Revision App

Application Flutter mobile et desktop du MVP Revision.

## Stack

- Flutter
- Clean architecture par feature
- Firebase Auth + Storage
- API NestJS Revision via HTTP
- GenUI avec fallback natif

## Local

```bash
flutter pub get
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:3000
```

L'API doit etre joignable via `API_BASE_URL`.

## Firebase

Le fichier `lib/firebase_options.dart` contient des valeurs locales factices pour
permettre le boot de l'app. Pour utiliser Google/Apple Sign-In et Firebase
Storage, passer les vraies valeurs du projet Firebase :

```bash
flutter run -d macos \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=...
```

Pour Android et Web, les app ids peuvent etre surcharges avec :

- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_WEB_APP_ID`

## Verification

```bash
flutter test
dart analyze lib test
flutter build macos --debug
```

## Backend attendu

Le backend est dans le repo separe :

```text
yoahnl/revision_project_api
```

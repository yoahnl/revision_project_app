# Revision App

Application Flutter mobile et desktop du MVP Revision.

## Stack

- Flutter
- Clean architecture par feature
- Firebase Auth
- API NestJS Revision via HTTP
- GenUI avec fallback natif

## Local

```bash
flutter pub get
flutter run -d macos
```

Par defaut, l'app utilise l'API deployee :

```text
https://revision-api.yoahn.me
```

Pour tester une API locale, surcharge `API_BASE_URL` :

```bash
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:3000
```

## Firebase

Le fichier `lib/firebase_options.dart` pointe par defaut vers le projet Firebase
`revision-app-1b799`. Les `--dart-define` restent disponibles pour surcharger la
configuration en staging/production :

```bash
flutter run -d macos \
  --dart-define=API_BASE_URL=https://revision-api.yoahn.me \
  --dart-define=FIREBASE_PROJECT_ID=revision-app-1b799
```

Apps Firebase creees :

- Apple iOS/macOS : `1:44948206826:ios:6c0b647ddb89ea8f8a9393`
- Android : `1:44948206826:android:095dd55272d132f48a9393`
- Web : `1:44948206826:web:879d53d4020758da8a9393`

Les PDF ne passent pas par Firebase Storage. L'app les envoie a l'API NestJS,
qui les stocke sur le volume persistant Dokploy configure cote backend.

Defines disponibles par plateforme :

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_MEASUREMENT_ID`

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

# Riverpod + GoRouter Grimaldi Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the Revision Flutter app with the Grimaldi architecture by centralizing routing, dependency injection, app bootstrap, light/dark theming, persisted theme preferences, and UI state management around Riverpod and go_router.

**Architecture:** Keep the current clean-architecture feature folders, but introduce a Grimaldi-style application shell: `app/router`, `app/di`, `app/bootstrap`, `presentation/theme`, and `presentation/widgets`. The first milestone migrates dependency wiring and theming, including a persisted `ThemeMode` with dark mode, without rewriting every screen; the second milestone moves page UI state from local `StatefulWidget`/`FutureBuilder` patterns into Riverpod notifiers.

**Tech Stack:** Flutter, go_router, flutter_riverpod, riverpod_annotation, riverpod_generator, build_runner, shared_preferences, Dio, Firebase Auth, Firebase Core, Firebase Storage, GenUI. Optional phase-two immutable UI states use `freezed` and `freezed_annotation`.

---

## Current Constraints And Defaults

- Active front repo: `/Users/karim/Project/app-révision/revision_app`.
- Do not touch backend repo `/Users/karim/Project/app-révision/api`.
- Keep the current `StatefulShellRoute.indexedStack` navigation work; do not revert it.
- Preserve existing public URLs: `/subjects`, `/subjects/:subjectId`, `/today`, `/activities?subjectId=...`, `/profile`, `/sign-in`, `/onboarding`.
- Keep Material 3 and the native Flutter `NavigationBar`/`NavigationRail`.
- Dark mode is part of this architecture pass, not a later visual polish task.
- Default theme mode must be `ThemeMode.system`.
- User theme preference must be persisted locally and survive app restart.
- The user must be able to choose `Systeme`, `Clair`, or `Sombre` from the profile screen.
- Do not modify or delete unrelated local commits or `devtools_options.yaml`.

## Target File Structure

- Create `lib/app/app_root.dart`: Riverpod-powered root widget, equivalent to Grimaldi `AppRoot`.
- Create `lib/app/bootstrap/app_widget.dart`: global UI-event wrapper, initially minimal.
- Create `lib/app/di/providers.dart`: barrel export for app providers.
- Create `lib/app/di/infrastructure_providers.dart`: Dio, upload/read adapters, app config.
- Create `lib/app/di/revision_providers.dart`: repositories, APIs, controllers.
- Create `lib/app/di/storage_providers.dart`: local key-value storage provider for app preferences.
- Create `lib/app/router/app_router.dart`: `appRouterProvider` returning `GoRouter`.
- Create `lib/app/router/app_routes.dart`: route constants and helpers.
- Move or replace `lib/core/routing/app_router.dart` and `lib/core/routing/route_paths.dart`.
- Create `lib/core/storage/kv_storage_port.dart` and `shared_preferences_kv_storage_adapter.dart`.
- Create `lib/presentation/theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart`, `app_theme.dart`, `theme_controller.dart`.
- Create `lib/presentation/widgets/theme_mode_selector.dart` for the profile page.
- Keep `lib/features/*/{domain,application,data,presentation}` for now; migrate UI state to notifiers later.

---

## Task 1: Add Grimaldi-Style Light/Dark Theme Tokens

**Files:**
- Create: `lib/presentation/theme/app_colors.dart`
- Create: `lib/presentation/theme/app_spacing.dart`
- Create: `lib/presentation/theme/app_radius.dart`
- Create: `lib/presentation/theme/app_theme.dart`
- Modify: `lib/app/revision_app.dart` or replacement root in Task 3
- Keep temporarily: `lib/core/theme/app_theme.dart` as a compatibility export until imports are migrated

- [ ] **Step 1: Write failing theme tests**

Create `test/presentation/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_radius.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/theme/app_theme.dart';

void main() {
  test('light and dark themes expose Revision design tokens', () {
    final lightTheme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;

    expect(lightTheme.useMaterial3, isTrue);
    expect(lightTheme.colorScheme.primary, AppColors.primary);
    expect(lightTheme.scaffoldBackgroundColor, AppColors.background);
    expect(darkTheme.useMaterial3, isTrue);
    expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
    expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
    expect(AppSpacing.pageHorizontal, 16);
    expect(AppRadius.radiusL, BorderRadius.circular(12));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/presentation/theme/app_theme_test.dart
```

Expected: FAIL because `revision_app/presentation/theme/...` does not exist.

- [ ] **Step 3: Implement theme tokens**

Create `lib/presentation/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF7FAF8);
  static const backgroundDark = Color(0xFF0F1715);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF182421);
  static const surfaceSubtle = Color(0xFFEAF4F0);
  static const surfaceSubtleDark = Color(0xFF22332F);
  static const primary = Color(0xFF246B5F);
  static const primaryDark = Color(0xFF8ED8CB);
  static const primaryLight = Color(0xFF6DAA9E);
  static const text = Color(0xFF17211F);
  static const textDark = Color(0xFFEAF4F0);
  static const textSecondary = Color(0xFF5E6B67);
  static const textSecondaryDark = Color(0xFFB4C3BE);
  static const border = Color(0xFFD7E1DD);
  static const borderDark = Color(0xFF304742);
  static const success = Color(0xFF0F9F6E);
  static const warning = Color(0xFFB7791F);
  static const danger = Color(0xFFC2413A);
}
```

Create `lib/presentation/theme/app_spacing.dart`:

```dart
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pageHorizontal = 16;
  static const double pageVertical = 24;
  static const double cardPadding = 16;
  static const double buttonPaddingH = 24;
  static const double buttonPaddingV = 14;
}
```

Create `lib/presentation/theme/app_radius.dart`:

```dart
import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double s = 4;
  static const double m = 8;
  static const double l = 12;
  static const double xl = 16;
  static const double pill = 999;

  static BorderRadius get radiusS => BorderRadius.circular(s);
  static BorderRadius get radiusM => BorderRadius.circular(m);
  static BorderRadius get radiusL => BorderRadius.circular(l);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);
}
```

Create `lib/presentation/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      outline: AppColors.border,
      error: AppColors.danger,
      tertiary: AppColors.success,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.text,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textDark,
      outline: AppColors.borderDark,
      error: AppColors.danger,
      tertiary: AppColors.success,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.textDark,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusL,
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
      ),
    ),
  );
}
```

Modify `lib/core/theme/app_theme.dart` to keep compatibility:

```dart
export '../../presentation/theme/app_theme.dart';
```

- [ ] **Step 4: Run theme test**

Run:

```bash
flutter test test/presentation/theme/app_theme_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/theme lib/core/theme/app_theme.dart test/presentation/theme/app_theme_test.dart
git commit -m "style: add Grimaldi-style light and dark theme tokens"
```

---

## Task 1B: Add Persisted Theme Mode And Profile Selector

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/storage/kv_storage_port.dart`
- Create: `lib/core/storage/shared_preferences_kv_storage_adapter.dart`
- Create: `lib/app/di/storage_providers.dart`
- Modify: `lib/app/di/providers.dart`
- Create: `lib/presentation/theme/theme_controller.dart`
- Create generated: `lib/presentation/theme/theme_controller.g.dart`
- Create: `lib/presentation/widgets/theme_mode_selector.dart`
- Modify: `lib/features/profile/presentation/profile_page.dart`

- [ ] **Step 1: Add theme persistence dependencies**

Modify `pubspec.yaml`:

```yaml
dependencies:
  shared_preferences: ^2.5.3
  riverpod_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^2.10.4
  riverpod_generator: ^4.0.0+1
```

Run:

```bash
flutter pub get
```

Expected: dependencies resolve.

- [ ] **Step 2: Write failing theme controller tests**

Create `test/presentation/theme/theme_controller_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/presentation/theme/theme_controller.dart';

class FakeKvStorage implements KvStoragePort {
  final Map<String, String> values = {};

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  test('theme controller defaults to system mode', () async {
    final storage = FakeKvStorage();
    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final mode = await container.read(themeProvider.future);

    expect(mode, ThemeMode.system);
  });

  test('theme controller persists selected dark mode', () async {
    final storage = FakeKvStorage();
    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    await container.read(themeProvider.future);
    await container.read(themeProvider.notifier).select(ThemeMode.dark);

    expect(await container.read(themeProvider.future), ThemeMode.dark);
    expect(storage.values['revision.theme_mode'], 'dark');
  });
}
```

- [ ] **Step 3: Add local storage port and adapter**

Create `lib/core/storage/kv_storage_port.dart`:

```dart
abstract interface class KvStoragePort {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);
}
```

Create `lib/core/storage/shared_preferences_kv_storage_adapter.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

import 'kv_storage_port.dart';

class SharedPreferencesKvStorageAdapter implements KvStoragePort {
  SharedPreferencesKvStorageAdapter(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }
}
```

Create `lib/app/di/storage_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/storage/kv_storage_port.dart';
import '../../core/storage/shared_preferences_kv_storage_adapter.dart';

final kvStorageProvider = Provider<KvStoragePort>((ref) {
  return SharedPreferencesKvStorageAdapter(SharedPreferencesAsync());
});
```

Modify `lib/app/di/providers.dart`:

```dart
export 'infrastructure_providers.dart';
export 'revision_providers.dart';
export 'storage_providers.dart';
```

- [ ] **Step 4: Implement ThemeController**

Create `lib/presentation/theme/theme_controller.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di/providers.dart';

part 'theme_controller.g.dart';

final themeProvider = themeControllerProvider;
const themeModeStorageKey = 'revision.theme_mode';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  Future<ThemeMode> build() async {
    final storage = ref.read(kvStorageProvider);
    final storedMode = await storage.readString(themeModeStorageKey);
    return decodeThemeMode(storedMode);
  }

  Future<void> select(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref
        .read(kvStorageProvider)
        .writeString(themeModeStorageKey, encodeThemeMode(mode));
  }
}

ThemeMode decodeThemeMode(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

String encodeThemeMode(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
```

- [ ] **Step 5: Generate provider code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/presentation/theme/theme_controller.g.dart` is created.

- [ ] **Step 6: Run theme controller tests**

Run:

```bash
flutter test test/presentation/theme/theme_controller_test.dart
```

Expected: PASS.

- [ ] **Step 7: Add a reusable theme selector widget**

Create `lib/presentation/widgets/theme_mode_selector.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_controller.dart';

class ThemeModeSelector extends ConsumerWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return themeMode.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (mode) => SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('Systeme')),
          ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
        ],
        selected: {mode},
        onSelectionChanged: (selection) {
          ref.read(themeProvider.notifier).select(selection.single);
        },
      ),
    );
  }
}
```

- [ ] **Step 8: Add selector to profile**

Modify `lib/features/profile/presentation/profile_page.dart` to display `ThemeModeSelector` in the profile settings area, below account identity/sign-out controls.

Acceptance for this screen:
- the label or surrounding section should be `Theme`;
- the selector exposes `Systeme`, `Clair`, and `Sombre`;
- selecting `Sombre` updates `themeProvider` and persists `revision.theme_mode=dark`;
- no auth behavior changes.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/storage lib/app/di lib/presentation/theme lib/presentation/widgets lib/features/profile test/presentation/theme
git commit -m "feat: add persisted dark mode preference"
```

---

## Task 2: Introduce Riverpod Dependency Injection

**Files:**
- Create: `lib/app/di/infrastructure_providers.dart`
- Create: `lib/app/di/revision_providers.dart`
- Create: `lib/app/di/providers.dart`
- Keep/export if already created in Task 1B: `lib/app/di/storage_providers.dart`
- Modify later consumers only after tests are green

- [ ] **Step 1: Write failing provider tests**

Create `test/app/di/revision_providers_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/config/app_config.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';

void main() {
  test('infrastructure provider creates Dio with API base URL', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio, isA<Dio>());
    expect(dio.options.baseUrl, AppConfig.apiBaseUrl);
  });

  test('application providers expose runtime controllers', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authControllerProvider), isA<AuthController>());
    expect(container.read(subjectsControllerProvider), isA<SubjectsController>());
    expect(container.read(documentsControllerProvider), isA<DocumentsController>());
    expect(container.read(activityControllerProvider), isA<ActivityController>());
    expect(container.read(todayControllerProvider), isA<TodayController>());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/app/di/revision_providers_test.dart
```

Expected: FAIL because `app/di/providers.dart` does not exist.

- [ ] **Step 3: Implement infrastructure providers**

Create `lib/app/di/infrastructure_providers.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
});
```

- [ ] **Step 4: Implement controller and repository providers**

Create `lib/app/di/revision_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/activities/data/http_activities_api.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/data/http_student_profile_bootstrapper.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/documents/data/documents_api.dart';
import '../../features/documents/data/firebase_document_uploader.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/onboarding/data/http_revision_goals_api.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/data/http_subjects_repository.dart';
import '../../features/today/application/today_controller.dart';
import '../../features/today/data/http_today_repository.dart';
import 'infrastructure_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final repository = ref.read(authRepositoryProvider);
  final controller = AuthController(
    repository,
    profileBootstrapper: HttpStudentProfileBootstrapper(
      apiBaseUrl: ref.read(dioProvider).options.baseUrl,
      getIdToken: repository.requireIdToken,
    ),
  );
  controller.start();
  ref.onDispose(controller.dispose);
  return controller;
});

final subjectsControllerProvider = Provider<SubjectsController>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return SubjectsController(
    HttpSubjectsRepository(dio: dio, getIdToken: auth.requireIdToken),
  );
});

final revisionGoalsControllerProvider =
    Provider<RevisionGoalsController>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return RevisionGoalsController(
    HttpRevisionGoalsApi(dio: dio, getIdToken: auth.requireIdToken),
  );
});

final documentsControllerProvider = Provider<DocumentsController>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return DocumentsController(
    FirebaseDocumentUploader(),
    HttpDocumentsApi(dio: dio, getIdToken: auth.requireIdToken),
  );
});

final activityControllerProvider = Provider<ActivityController>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return ActivityController(
    HttpActivitiesApi(dio: dio, getIdToken: auth.requireIdToken),
  );
});

final todayControllerProvider = Provider<TodayController>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return TodayController(
    HttpTodayRepository(dio: dio, getIdToken: auth.requireIdToken),
  );
});
```

- [ ] **Step 5: Add DI barrel**

Create `lib/app/di/providers.dart`:

```dart
export 'infrastructure_providers.dart';
export 'revision_providers.dart';
export 'storage_providers.dart';
```

- [ ] **Step 6: Run provider tests**

Run:

```bash
flutter test test/app/di/revision_providers_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/app/di test/app/di/revision_providers_test.dart
git commit -m "refactor: add Riverpod dependency providers"
```

---

## Task 3: Move GoRouter Into A Riverpod Provider

**Files:**
- Create: `lib/app/router/app_routes.dart`
- Create: `lib/app/router/app_router.dart`
- Modify: `lib/core/routing/route_paths.dart`
- Modify: `lib/core/routing/app_router.dart`
- Modify imports in pages that use route constants

- [ ] **Step 1: Write failing router provider test**

Create `test/app/router/app_router_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_router.dart';
import 'package:revision_app/app/router/app_routes.dart';

void main() {
  test('appRouterProvider exposes a GoRouter with Revision initial location', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    expect(router, isA<GoRouter>());
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.subjects);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/app/router/app_router_test.dart
```

Expected: FAIL because `app/router/app_router.dart` does not exist.

- [ ] **Step 3: Add app route constants**

Create `lib/app/router/app_routes.dart`:

```dart
class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const subjects = '/subjects';
  static const today = '/today';
  static const activities = '/activities';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  static String subjectDetail(String subjectId) => '/subjects/$subjectId';
  static String activitiesForSubject(String subjectId) =>
      Uri(path: activities, queryParameters: {'subjectId': subjectId}).toString();
}
```

- [ ] **Step 4: Move router factory into provider**

Create `lib/app/router/app_router.dart` by moving the current `createAppRouter` logic from `lib/core/routing/app_router.dart`, changing constructor dependency reads to Riverpod reads:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/di/providers.dart';
import '../../app/presentation/revision_home_shell.dart';
import '../../features/activities/presentation/activities_page.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/subjects/presentation/subject_detail_page.dart';
import '../../features/subjects/presentation/subjects_home_page.dart';
import '../../features/today/presentation/today_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.read(authControllerProvider);
  final subjectsController = ref.read(subjectsControllerProvider);
  final revisionGoalsController = ref.read(revisionGoalsControllerProvider);
  final documentsController = ref.read(documentsControllerProvider);
  final activityController = ref.read(activityControllerProvider);
  final todayController = ref.read(todayControllerProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.subjects,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(path: AppRoutes.root, redirect: (_, _) => AppRoutes.subjects),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) =>
            SignInPage(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingPage(
          subjectsController: subjectsController,
          revisionGoalsController: revisionGoalsController,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RevisionHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) =>
                    SubjectsHomePage(controller: subjectsController),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    builder: (context, state) => SubjectDetailPage(
                      subjectId: state.pathParameters['subjectId'] ?? '',
                      controller: subjectsController,
                      documentsController: documentsController,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) =>
                    TodayPage(controller: todayController),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    ProfilePage(authController: authController),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

@visibleForTesting
String? executeRevisionRedirect(AuthController authController, GoRouterState state) {
  final isSigningIn = state.uri.path == AppRoutes.signIn;

  if (authController.isLoading) {
    return null;
  }

  if (!authController.isSignedIn) {
    return isSigningIn ? null : AppRoutes.signIn;
  }

  if (isSigningIn) {
    return AppRoutes.subjects;
  }

  return null;
}
```

- [ ] **Step 5: Keep old routing files as compatibility exports**

Modify `lib/core/routing/app_router.dart`:

```dart
export '../../app/router/app_router.dart';
```

Modify `lib/core/routing/route_paths.dart`:

```dart
import '../../app/router/app_routes.dart';

const String subjectsRoutePath = AppRoutes.subjects;
const String todayRoutePath = AppRoutes.today;
const String activitiesRoutePath = AppRoutes.activities;
const String profileRoutePath = AppRoutes.profile;
const String onboardingRoutePath = AppRoutes.onboarding;
const String signInRoutePath = AppRoutes.signIn;
const String subjectDetailRoutePattern = '/subjects/:subjectId';

String subjectDetailRoutePath(String subjectId) => AppRoutes.subjectDetail(subjectId);
```

- [ ] **Step 6: Run router test**

Run:

```bash
flutter test test/app/router/app_router_test.dart
```

Expected: PASS.

- [ ] **Step 7: Run existing app tests**

Run:

```bash
flutter test test/app/revision_app_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/app/router lib/core/routing test/app/router test/app/revision_app_test.dart
git commit -m "refactor: provide GoRouter through Riverpod"
```

---

## Task 4: Replace Manual App Wiring With ProviderScope + AppRoot

**Files:**
- Create: `lib/app/app_root.dart`
- Create: `lib/app/bootstrap/app_widget.dart`
- Modify: `lib/app/revision_app.dart`
- Modify: `lib/main.dart`
- Modify: `test/app/revision_app_test.dart`

- [ ] **Step 1: Write failing app root test**

Create `test/app/app_root_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revision_app/app/app_root.dart';

void main() {
  testWidgets('AppRoot builds MaterialApp.router from Riverpod providers', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AppRoot()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.darkTheme, isNotNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
flutter test test/app/app_root_test.dart
```

Expected: FAIL because `AppRoot` does not exist.

- [ ] **Step 3: Add global UI wrapper**

Create `lib/app/bootstrap/app_widget.dart`:

```dart
import 'package:flutter/widgets.dart';

class UiEventsListener extends StatelessWidget {
  const UiEventsListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
```

- [ ] **Step 4: Add AppRoot**

Create `lib/app/app_root.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/app_widget.dart';
import 'router/app_router.dart';
import '../presentation/theme/app_theme.dart';
import '../presentation/theme/theme_controller.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'Revision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          UiEventsListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
```

- [ ] **Step 5: Make RevisionApp a compatibility wrapper**

Modify `lib/app/revision_app.dart` so it only hosts a `ProviderScope` and `AppRoot` for production. Keep the old constructor temporarily only if tests still need direct controller injection; prefer moving tests to provider overrides in Step 6.

Final desired production shape:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_root.dart';

class RevisionApp extends StatelessWidget {
  const RevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: AppRoot());
  }
}
```

- [ ] **Step 6: Update app tests to use ProviderScope overrides**

In `test/app/revision_app_test.dart`, replace constructor injection with Riverpod overrides:

```dart
ProviderScope(
  overrides: [
    authControllerProvider.overrideWithValue(resolvedAuthController),
    subjectsControllerProvider.overrideWithValue(SubjectsController(subjectsRepository)),
    revisionGoalsControllerProvider.overrideWithValue(
      RevisionGoalsController(revisionGoalsRepository),
    ),
    documentsControllerProvider.overrideWithValue(
      DocumentsController(NoopDocumentUploader(), documentsApi),
    ),
    activityControllerProvider.overrideWithValue(ActivityController(activityApi)),
    todayControllerProvider.overrideWithValue(TodayController(todayRepository)),
  ],
  child: const AppRoot(),
)
```

- [ ] **Step 7: Wrap main in RevisionApp**

Keep `lib/main.dart` simple:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/revision_app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RevisionApp());
}
```

- [ ] **Step 8: Run app tests**

Run:

```bash
flutter test test/app/app_root_test.dart test/app/revision_app_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/app test/app
git commit -m "refactor: bootstrap app with Riverpod root"
```

---

## Task 5: Move Page UI State To Riverpod Notifiers

**Files:**
- Add dependency: `riverpod_annotation`
- Add dev dependencies: `riverpod_generator`, `build_runner`, `freezed`, `freezed_annotation`
- Create: `lib/features/subjects/application/subjects_notifier.dart`
- Create: `lib/features/today/application/today_notifier.dart`
- Create: `lib/features/documents/application/subject_documents_notifier.dart`
- Modify pages to become `ConsumerWidget`/`ConsumerStatefulWidget`

- [ ] **Step 1: Update dependencies**

If Task 1B has already added Riverpod codegen dependencies, keep the existing versions. Otherwise, modify `pubspec.yaml`:

```yaml
dependencies:
  riverpod_annotation: ^4.0.0
  freezed_annotation: ^3.1.0

dev_dependencies:
  build_runner: ^2.10.4
  riverpod_generator: ^4.0.0+1
  freezed: ^3.2.3
```

Run:

```bash
flutter pub get
```

Expected: dependencies resolve.

- [ ] **Step 2: Write failing notifier test for today**

Create `test/features/today/today_notifier_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/today/application/today_notifier.dart';

import '../../fakes/in_memory_today_repository.dart';

void main() {
  test('today notifier loads plan through repository provider', () async {
    final repository = InMemoryTodayRepository();
    final container = ProviderContainer(
      overrides: [
        todayRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final plan = await container.read(todayNotifierProvider.future);

    expect(plan.items, isEmpty);
    expect(repository.getTodayPlanCalls, 1);
  });
}
```

- [ ] **Step 3: Implement repository and today notifier providers**

Add to `lib/app/di/revision_providers.dart`:

```dart
final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpTodayRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final todayControllerProvider = Provider<TodayController>((ref) {
  return TodayController(ref.read(todayRepositoryProvider));
});
```

Create `lib/features/today/application/today_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/providers.dart';
import '../domain/today_plan.dart';

part 'today_notifier.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  @override
  Future<TodayPlan> build() {
    return ref.read(todayRepositoryProvider).getTodayPlan();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(todayRepositoryProvider).getTodayPlan(),
    );
  }
}
```

- [ ] **Step 4: Generate Riverpod code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: creates `today_notifier.g.dart` and other generated files only where needed.

- [ ] **Step 5: Run today notifier test**

Run:

```bash
flutter test test/features/today/today_notifier_test.dart
```

Expected: PASS.

- [ ] **Step 6: Migrate TodayPage to ConsumerWidget**

Modify `lib/features/today/presentation/today_page.dart` so it watches `todayNotifierProvider` instead of accepting `TodayController`.

The page should:
- render loading with `LinearProgressIndicator`;
- render error with retry calling `ref.read(todayNotifierProvider.notifier).reload()`;
- render empty with `Aucune revision prioritaire`;
- keep existing “Démarrer” navigation.

- [ ] **Step 7: Repeat the notifier pattern for Subjects and Documents**

Create:
- `lib/features/subjects/application/subjects_notifier.dart`
- `lib/features/documents/application/subject_documents_notifier.dart`

Migrate:
- `SubjectsHomePage` to watch `subjectsNotifierProvider`;
- `SubjectDetailPage` to watch subject detail and documents providers;
- `DocumentImportButton` remains controller-based until upload flow is migrated, then invalidates `subjectDocumentsProvider(subjectId)`.

- [ ] **Step 8: Run tests after each migrated page**

Run after each page migration:

```bash
flutter test test/app/revision_app_test.dart
dart analyze lib test
```

Expected: PASS after each page.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features lib/app/di test/features test/app
git commit -m "refactor: manage page state with Riverpod notifiers"
```

---

## Task 6: Final Cleanup And Compatibility

**Files:**
- Remove unused manual controller constructor parameters after tests are migrated.
- Remove compatibility exports only if no imports remain.
- Keep backend untouched.

- [ ] **Step 1: Find old imports and direct controller injection**

Run:

```bash
rg -n "core/routing|core/theme|RevisionApp\\(|FutureBuilder<|StatefulWidget|final .*Controller" lib test
```

Expected: only intentional `StatefulWidget` cases remain, such as form pages or widgets with local transient input state.

- [ ] **Step 2: Remove obsolete compatibility files only when unused**

If no imports remain:

```bash
git rm lib/core/routing/app_router.dart lib/core/routing/route_paths.dart lib/core/theme/app_theme.dart
```

If imports remain, keep compatibility exports until the next cleanup PR.

- [ ] **Step 3: Run final checks**

Run:

```bash
dart analyze lib test
flutter test
git diff --check
```

Expected:
- analyzer: `No issues found!`
- Flutter tests: all tests passed
- diff check: no output

- [ ] **Step 4: Commit**

```bash
git add lib test pubspec.yaml pubspec.lock
git commit -m "chore: align Flutter architecture with Grimaldi"
```

---

## Acceptance Criteria

- `go_router` remains the only routing library.
- Router configuration is provided through Riverpod via `appRouterProvider`.
- App bootstrap starts through `ProviderScope` and a Grimaldi-style root widget.
- Runtime dependencies are created through providers, not manual constructor wiring in `RevisionApp`.
- Light and dark theme tokens live under `presentation/theme` and replace the one-file `core/theme` setup.
- `MaterialApp.router` receives `theme`, `darkTheme`, and a Riverpod-driven `themeMode`.
- Default theme mode is `ThemeMode.system`.
- Theme preference is persisted locally with `shared_preferences`.
- Profile exposes a theme selector with `Systeme`, `Clair`, and `Sombre`.
- Selecting `Sombre` switches the app to dark mode and survives app restart.
- At least Today, Subjects, and Documents page loading state are represented with Riverpod `AsyncValue`.
- Existing public routes and auth redirects still work.
- Existing app tests pass, including persistent tab behavior.
- Backend repo remains untouched.

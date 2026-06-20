# Create Subject From Picker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users create a real subject directly from the premium subject picker on the home page, then automatically select it.

**Architecture:** Reuse the existing real subjects stack: `SubjectsRepository` -> `SubjectsController` -> `SubjectsNotifier` -> home picker. No backend changes are needed because `POST /subjects` already exists and `HttpSubjectsRepository.createSubject` is already implemented. The UI stays local to `CoursesHomePage` for now because the picker is private there and this is a narrow UX gap, not a new global subject-management flow.

**Tech Stack:** Flutter, Riverpod, GoRouter, existing Revision design system, existing in-memory test repositories.

---

## File Structure

- Modify: `lib/features/subjects/application/subjects_notifier.dart`
  - Add a `createSubject` method that calls the real repository, reloads subjects, and returns the created `Subject`.
- Modify: `lib/features/courses/presentation/courses_home_page.dart`
  - Add a create-subject CTA to the existing subject picker bottom sheet.
  - Add a small premium `_CreateSubjectSheet`.
  - Select the newly created subject through `activeSubjectIdProvider`.
- Modify: `test/app/revision_app_test.dart`
  - Add a widget test proving the picker can create and select a real subject without fake data.
- No backend file changes.
- No generated Riverpod file changes expected, because `SubjectsNotifier` already has a generated provider and method additions do not require regeneration.

---

### Task 1: Add Subject Creation To `SubjectsNotifier`

**Files:**
- Modify: `lib/features/subjects/application/subjects_notifier.dart`
- Test: existing tests indirectly via app/widget test in Task 3

- [ ] **Step 1: Add the method to the notifier**

Add this method inside `SubjectsNotifier`, after `reload()` and before `deleteSubject()`:

```dart
  Future<Subject> createSubject({
    required String name,
    int priority = 3,
  }) async {
    final created = await ref.read(subjectsRepositoryProvider).createSubject(
      name: name,
      priority: priority,
    );
    await reload();
    return created;
  }
```

Rationale:
- `SubjectsController` already validates names, but the UI will also perform local validation for better feedback.
- `priority = 3` is neutral and avoids exposing a priority picker in this small UX fix.
- The method returns the created subject so the UI can select it immediately.

- [ ] **Step 2: Run the targeted analyzer**

Run:

```bash
dart analyze lib/features/subjects/application/subjects_notifier.dart
```

Expected:

```text
No issues found!
```

If the analyzer warns that `Subject` is unknown, verify the file still imports:

```dart
import '../domain/subject.dart';
```

---

### Task 2: Add A Create-Subject Flow To The Premium Picker

**Files:**
- Modify: `lib/features/courses/presentation/courses_home_page.dart`

- [ ] **Step 1: Replace the current `_showSubjectPicker` builder**

Change the bottom sheet builder from an inline `RevisionBottomSheetFrame` to a dedicated widget. The function should become:

```dart
void _showSubjectPicker(
  BuildContext context,
  WidgetRef ref,
  List<Subject> subjects,
  String activeSubjectId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _SubjectPickerSheet(
      parentContext: context,
      subjects: subjects,
      activeSubjectId: activeSubjectId,
    ),
  );
}
```

Notes:
- `parentContext` is kept so the create sheet can be opened after the picker sheet closes.
- The existing `ref` parameter can be removed from `_showSubjectPicker` if the compiler reports it unused, but keep the call site clean:

```dart
onTap: () => _showSubjectPicker(context, ref, subjects, subject.id),
```

or, if removing `ref` from the function signature:

```dart
onTap: () => _showSubjectPicker(context, subjects, subject.id),
```

- [ ] **Step 2: Add `_SubjectPickerSheet`**

Add this widget near `_showSubjectPicker`, before `_showCreateCourseSheet`:

```dart
class _SubjectPickerSheet extends ConsumerWidget {
  const _SubjectPickerSheet({
    required this.parentContext,
    required this.subjects,
    required this.activeSubjectId,
  });

  final BuildContext parentContext;
  final List<Subject> subjects;
  final String activeSubjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RevisionBottomSheetFrame(
      title: 'Choisir une matière',
      subtitle: 'La page reste centrée sur une seule matière active.',
      children: [
        for (final subject in subjects)
          _SubjectChoiceCard(
            subject: subject,
            selected: subject.id == activeSubjectId,
            onTap: () {
              ref.read(activeSubjectIdProvider.notifier).select(subject.id);
              Navigator.of(context).pop();
            },
          ),
        RevisionGradientButton(
          label: 'Créer une matière',
          icon: Icons.add_rounded,
          expanded: true,
          onPressed: () {
            Navigator.of(context).pop();
            Future<void>.microtask(
              () => _showCreateSubjectSheet(parentContext),
            );
          },
        ),
      ],
    );
  }
}
```

Rationale:
- Keeps the current subject picker behavior unchanged.
- Adds a single obvious create action at the bottom.
- Uses existing design system button instead of a raw Material button.

- [ ] **Step 3: Add `_CreateSubjectSheet`**

Add this widget near `_CreateCourseSheet`:

```dart
class _CreateSubjectSheet extends ConsumerStatefulWidget {
  const _CreateSubjectSheet();

  @override
  ConsumerState<_CreateSubjectSheet> createState() => _CreateSubjectSheetState();
}

class _CreateSubjectSheetState extends ConsumerState<_CreateSubjectSheet> {
  final _nameController = TextEditingController();
  String? _localError;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RevisionBottomSheetFrame(
        title: 'Créer une matière',
        subtitle: 'Elle deviendra la matière active de l’accueil.',
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom de la matière'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitting ? null : _submit(),
          ),
          if (_localError != null)
            Text(
              _localError!,
              style: const TextStyle(color: RevisionColors.red),
            ),
          RevisionGradientButton(
            label: _submitting ? 'Création...' : 'Créer la matière',
            icon: Icons.add_rounded,
            expanded: true,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.length < 2) {
      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
      });
      return;
    }

    setState(() {
      _localError = null;
      _submitting = true;
    });

    try {
      final subject = await ref
          .read(subjectsNotifierProvider.notifier)
          .createSubject(name: name);

      ref.read(activeSubjectIdProvider.notifier).select(subject.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Impossible de créer la matière.';
        _submitting = false;
      });
    }
  }
}
```

Important:
- Do not add fake subjects.
- Do not navigate to the legacy subjects page after creation.
- Do not expose priority in this sheet.
- Do not show gamification or mock counters.

- [ ] **Step 4: Add `_showCreateSubjectSheet`**

Add this function near `_showCreateCourseSheet`:

```dart
void _showCreateSubjectSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateSubjectSheet(),
  );
}
```

- [ ] **Step 5: Run formatter**

Run:

```bash
dart format lib/features/courses/presentation/courses_home_page.dart lib/features/subjects/application/subjects_notifier.dart
```

Expected:

```text
Formatted 2 files
```

or:

```text
Formatted 2 files (0 changed)
```

---

### Task 3: Add Widget Coverage For Create Subject From Picker

**Files:**
- Modify: `test/app/revision_app_test.dart`

- [ ] **Step 1: Add the failing test**

Add this test after `home can list real subjects without inventing courses`:

```dart
  testWidgets('home can create and select a subject from the subject picker', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Droits').first);
    await tester.pumpAndSettle();

    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);

    await tester.tap(find.text('Créer une matière'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Nom de la matière'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Histoire');
    await tester.tap(find.text('Créer la matière'));
    await tester.pumpAndSettle();

    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Tes cours de Histoire'), findsOneWidget);
    expect(find.text('Aucun cours réel'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });
```

Expected before implementation:
- The test fails because `Créer une matière` is not present in the subject picker.

- [ ] **Step 2: Run the failing test**

Run:

```bash
flutter test test/app/revision_app_test.dart --plain-name "home can create and select a subject from the subject picker" --reporter compact
```

Expected:

```text
Expected: exactly one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "Créer une matière": []>
```

- [ ] **Step 3: Run the test after implementation**

Run the same command:

```bash
flutter test test/app/revision_app_test.dart --plain-name "home can create and select a subject from the subject picker" --reporter compact
```

Expected:

```text
All tests passed!
```

---

### Task 4: Validate Existing Home And Router Behavior

**Files:**
- No additional code changes expected.

- [ ] **Step 1: Run app-level tests**

Run:

```bash
flutter test test/app/revision_app_test.dart --reporter compact
```

Expected:

```text
All tests passed!
```

- [ ] **Step 2: Run router tests**

Run:

```bash
flutter test test/app/router/app_router_test.dart --reporter compact
```

Expected:

```text
All tests passed!
```

- [ ] **Step 3: Run courses tests**

Run:

```bash
flutter test test/features/courses --reporter compact
```

Expected:

```text
All tests passed!
```

---

### Task 5: Run Static Analysis And Anti-Fixture Checks

**Files:**
- No additional code changes expected.

- [ ] **Step 1: Analyze**

Run:

```bash
dart analyze lib test
```

Expected:

```text
No issues found!
```

- [ ] **Step 2: Anti-fixture grep**

Run:

```bash
rg -n "MvpStudyController\\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours|🔥 12|💎 870" lib/app lib/features/courses lib/features/revision_sessions lib/presentation/pages/revision_sessions lib/presentation/shell test/app test/features/courses test/features/revision_sessions || true
```

Expected:
- No runtime occurrences in `lib/app`, `lib/features/courses`, `lib/features/revision_sessions`, `lib/presentation/pages/revision_sessions`, or `lib/presentation/shell`.
- Test occurrences are allowed only for `findsNothing` anti-fixture assertions.

- [ ] **Step 3: Anti-CourseSource grep**

Run:

```bash
rg -n "CourseSource" lib test || true
```

Expected:

```text
```

No output.

- [ ] **Step 4: Diff whitespace check**

Run:

```bash
git diff --check
```

Expected:

```text
```

No output.

---

## Manual QA Checklist

- [ ] Open home.
- [ ] Tap the subject pill.
- [ ] Verify the picker shows existing subjects and a visible `Créer une matière` CTA.
- [ ] Tap `Créer une matière`.
- [ ] Submit an invalid one-character name.
- [ ] Verify the inline validation message appears.
- [ ] Submit a valid name, for example `Histoire`.
- [ ] Verify the sheet closes.
- [ ] Verify `Histoire` becomes the active subject.
- [ ] Verify home shows `Tes cours de Histoire`.
- [ ] Verify no fake course, score, streak, gem, or mock value appears.

---

## Self-Review

- Spec coverage: the plan adds creation directly from the subject picker, uses the real subject repository, selects the created subject, and keeps the current premium UI direction.
- Placeholder scan: no `TBD`, `TODO`, or vague test steps.
- Type consistency: uses existing `Subject`, `subjectsNotifierProvider`, `activeSubjectIdProvider`, `RevisionBottomSheetFrame`, and `RevisionGradientButton`.
- Scope guard: no backend changes, no route changes, no subject icon/color editor, no gamification, no fake data.


# Repository Guidelines

## 1. Purpose

Revision App is the Flutter client for an adaptive study companion. It must feel like a focused student tool: fast, calm, visual, and coherent across mobile and desktop.

This file applies to the Flutter app in:

```text
/Users/karim/Project/app-révision/revision_app
```

Do not edit the NestJS backend from this repository unless the user explicitly asks for backend work.

Instruction priority:

1. Direct user request.
2. The nearest `AGENTS.md`.
3. Referenced specs, plans, screenshots, or rule files.
4. Local code patterns.
5. General agent behavior.

If rules conflict, choose the stricter safe rule and report the conflict.

## 2. Project Shape

Keep the app split by responsibility:

| Path | Role |
|---|---|
| `lib/app` | App bootstrap, root widget, DI entry points, router assembly. |
| `lib/app/di/providers.dart` | Barrel file only. It exports provider modules. |
| `lib/app/router` | `go_router` route definitions and route-level wiring. |
| `lib/core` | Stable cross-feature helpers, config, routing paths, storage ports. |
| `lib/features/<feature>/domain` | Pure models and contracts. No Flutter UI. |
| `lib/features/<feature>/application` | Controllers, notifiers, use cases, providers. |
| `lib/features/<feature>/data` | HTTP/Firebase/local adapters. |
| `lib/presentation/pages` | Page widgets only. |
| `lib/presentation/widgets` | Reusable UI primitives and shared components. |
| `lib/presentation/theme` | Color, spacing, radius, typography, theme tokens. |
| `test` | Focused widget, application, notifier, and adapter tests. |

Compatibility exports under `lib/features/**/presentation` may remain for stable imports, but new UI belongs under `lib/presentation`.

## 3. Routing

Use `go_router` for navigation.

- Keep public paths stable unless the user explicitly approves a route change.
- `lib/core/routing/route_paths.dart` is the canonical source for route path strings.
- `lib/app/router/app_routes.dart` is the canonical source for route definitions.
- Keep public routes outside the authenticated shell: `/`, `/sign-in`, `/onboarding`.
- Keep tab routes inside the persistent shell: `/subjects`, `/subjects/:subjectId`, `/today`, `/activities`, `/profile`.
- Use `StatefulShellRoute.indexedStack` for tabs. Do not reintroduce a basic `ShellRoute` for the main tabs.
- Re-tapping the active tab should return to that branch initial location.

Pages should receive dependencies through route wiring, controllers, or providers. They should not create routers, clients, Firebase instances, or repositories directly.

## 4. Riverpod and DI

Use Riverpod for app state and dependency wiring.

- `lib/app/di/providers.dart` is a barrel only. Do not define providers in it.
- Cross-cutting infrastructure providers belong in `lib/app/di`.
- Feature-specific providers belong in `lib/features/<feature>/application`.
- New generated providers require running build runner and committing the matching generated files.
- Pages should watch notifiers/providers or receive controllers; avoid direct adapter access from UI.
- Do not duplicate provider definitions across app and feature modules.

Recommended command after provider annotation changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Visual Identity

The app should not look like default Material scaffolding. The visual direction is dark mint glass, soft panels, restrained glow, clear study hierarchy, and reusable components.

Use the shared primitives first:

```text
RevisionBackground
RevisionPage
RevisionPanel
RevisionButton
RevisionIconBadge
RevisionTextField
RevisionMessage
RevisionStatusPill
RevisionProgressBar
RevisionBottomNavigation
RevisionNavigationRail
RevisionChoiceTile
```

Rules:

- Build pages from reusable primitives. If a page needs a recurring visual pattern, add or extend a shared widget under `lib/presentation/widgets`.
- Avoid raw `Scaffold` surfaces that expose default Material visuals. Wrap app screens in `RevisionBackground` when they are outside the shell.
- Avoid `Card`, ad-hoc glass `Container`, local navigation widgets, and local button variants in pages.
- Use `Theme.of(context).textTheme` and semantic theme colors for text.
- Use `AppColors`, `AppSpacing`, and `AppRadius` for visual tokens. Add a semantic token when a new repeated value is needed.
- Do not hardcode color hex values, spacing numbers, or radii in pages.
- Prefer icons inside controls where they clarify the action.
- Keep mobile and desktop layouts coherent. Wide layouts may use `RevisionNavigationRail`; mobile should use `RevisionBottomNavigation`.
- Keep text inside buttons and panels short enough to fit on small devices.

Allowed direct `Colors.*` usage should be limited to low-level theme/primitives or necessary framework values such as transparent scaffold backgrounds.

## 6. Page Organization

All user-facing screens should be under:

```text
lib/presentation/pages/<area>/<page>.dart
```

Feature directories can keep presentation files only as export shims when needed for backward compatibility.

Do not put one-off layout primitives inside a page if another page is likely to need the same pattern. Move it into `lib/presentation/widgets`.

## 7. Testing

Behavior matters more than implementation details, but tests should still protect the app shell and study flows.

Add or update tests when changing:

- routing or redirects;
- tab persistence;
- auth gates;
- page state;
- upload/import behavior;
- generated activities and quiz submit behavior;
- reusable UI components with non-trivial interaction.

Preferred verification from the Flutter app root:

```bash
dart analyze lib test
flutter test
git diff --check
```

If a command cannot run locally, report the reason and the exact command the user should run.

## 8. Git Safety

Do not run Git write operations unless the user explicitly asks.

Forbidden without explicit instruction:

```text
git add, git commit, git commit --amend, git merge, git rebase,
git push, git tag, git stash, git reset, git restore,
git checkout/switch when it changes files or branches,
git branch creation/deletion/rename,
git worktree add/remove.
```

Allowed read-only commands:

```bash
git status --short --untracked-files=all
git diff
git diff --name-only
git log
git show
git branch
```

The worktree can be dirty. Preserve unrelated user changes and do not silently clean generated or local files.

## 9. Working Style

- Keep changes scoped to the request.
- Prefer existing controllers, providers, and repositories over new abstractions.
- Prefer small reusable UI primitives over repeated local styling.
- Keep compatibility exports unless removing them is explicitly requested.
- Do not rename public routes, storage keys, provider names, or domain fields without a clear migration reason.
- Before saying work is complete, run the relevant verification commands and report the result.

## 10. Codex Lot Reports

When a task references `codex_rule.md`, that file is mandatory for the lot report. Apply it as a strict reporting contract for both this Flutter app and the sibling NestJS API when the requested work spans both repositories.

Required report shape:

- Audit the prompt before implementation and explicitly challenge unsafe, contradictory, or repo-inaccurate instructions.
- Audit existing files, contracts, tests, prior reports, risks, and scope boundaries before editing.
- Use sub-agents when available; otherwise run clearly named local passes for Audit / Architecture, Implementation, Tests, Build / Validation, and Critical Review.
- Include the verdict of each sub-agent or named pass in the final report.
- Include the initial and final Git state.
- List every modified, created, or deleted file.
- Include the complete content of every created file.
- For modified files, include the exact changed zones or a diff-style excerpt.
- Include tests created or modified, exact commands run, and exact results.
- Include analysis commands, build commands, exact results, preserved scope limits, remaining risks, next steps, and final self-critique.

For code lots, useful comments are expected where they protect an invariant, explain a lot boundary, or prevent a future false behavior. Comments should clarify why the code exists; they must not decorate obvious statements.

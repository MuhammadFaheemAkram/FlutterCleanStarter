# Contributing to Flutter Clean Starter

Thanks for your interest! This is a **starter template**: people copy it to begin their own apps. Contributions that make it clearer, more correct, easier to copy, or easier to strip down are especially welcome.

## Ground Rules

- Be respectful. See the [Code of Conduct](CODE_OF_CONDUCT.md).
- **Keep the architecture intact:**
  - Respect the layer boundaries: View → Cubit → UseCase → Repository → drift / the API.
  - `domain/` stays pure Dart, Views never import `data/`, and drift files never import `material_ui`.
  - **Screens read drift, never the API.** The API only seeds, refreshes and resets.
  - **The device owns the tasks:** a refresh adds the server's new tasks and never overwrites a stored one (`ON CONFLICT DO NOTHING`); a tombstone keeps a deleted task deleted.
  - **Due dates are days** (`CalendarDate`), instants are UTC, and "now" comes from the injected `Clock`, never `DateTime.now()`.
  - **Writes return a `Result`** and never throw into a Cubit; validation is one set of pure rules (`TaskRules`), used by the form and the use cases.
  - **Navigation happens in Views** (typed routes), never in Cubits.
  - **Platform services stay behind `domain/service` interfaces** (`DynamicColorSource`).
- **Keep the sample removable:** every file of the Tasks sample has `task` in its name, and shared code doesn't depend on it beyond the edits listed in [TEMPLATE_USAGE.md](docs/TEMPLATE_USAGE.md#remove-the-tasks-sample). A change that adds a dependency on the sample must update that list, and the removal check must still pass.
- **Keep the rename working:** a new file that holds the package name, the app ID or the display name must be handled by `tool/rename.dart` (and its tests).
- **UI:** import `package:material_ui/material_ui.dart`, never `package:flutter/material.dart`.
- **Dependencies:** every package should be one a new app is likely to keep. Explain a new one in the README's tech stack.

## Development Setup

- Install [FVM](https://fvm.app), then run `fvm install`. It reads `.fvmrc`, which pins Flutter 3.47.6.
- iOS needs Xcode. Android needs the Android SDK and Java 17+ (Android Studio's bundled JDK works).
- `fvm flutter pub get`, then `fvm flutter run`. The first launch seeds the demo tasks.
- After changing annotated code (freezed, json_serializable, injectable, drift, typed routes), regenerate it:

  ```bash
  fvm dart run build_runner build --delete-conflicting-outputs
  ```

  Generated files are committed, and CI fails if they are stale or missing.
- **Changing the database schema:**
  1. Bump `schemaVersion` in `app_database.dart`.
  2. Run `fvm dart run drift_dev make-migrations`. It exports the new version to `drift_schemas/` and generates the steps and the migration tests.
  3. Write the new step in the migration strategy, and a data test for it.
- **Before a release:** launch a **release** build once. Resource shrinking and tree shaking only happen there (conventions §11.85).

## Coding Conventions

- **Lints:** `fvm flutter analyze` must report **no issues** (`flutter_lints` plus strict casts, inference and raw types).
- **Formatting:** `fvm dart format .`.
- **Pages and Views:** Pages create and provide a Cubit (from DI); Views render state and forward intents.
- **Cubit by default.** A Bloc only when event transformers (debounce, `restartable`) earn their place.
- **One-time effects** (a SnackBar, closing a form) are state with a serial or a status transition, shown by a `BlocListener`.
- **Immutable state:** freezed classes, rendered with an exhaustive `switch`.
- **Accessibility:** every tappable is at least 48 × 48 and labelled, text contrast meets WCAG AA in both themes, color is never the only signal, and above 130 % text (`context.prefersStackedLayout`) side-by-side controls stack. Add new screens and states to the accessibility tour.
- **Comments** explain *decisions*, not obvious code.

## Commits

This project uses **[Conventional Commits](https://www.conventionalcommits.org/)**:

```
<type>(<scope>): <message>
```

Examples: `feat(tasks): filter by due date`, `fix(settings): keep the theme on resume`, `test(tasks): cover a refresh after a reset`, `docs(template): explain flavors`.

## Pull Requests

1. Fork the repository and create a topic branch.
2. Make sure `fvm flutter analyze`, `fvm dart format --output=none --set-exit-if-changed .` and `fvm flutter test` all pass.
3. If the change touches what TEMPLATE_USAGE describes, follow the guide on a copy (remove the sample; rename) and say so in the PR.
4. Update the docs where relevant, and open a PR with the change and its motivation.

## Tests

- **Rules:** pure unit tests with the fixtures in `test/helpers/` (`task()`, `taskDto()`); test each rule at its edge (80 vs 81 characters, due today vs yesterday).
- **Cubits, use cases and repositories:** on a real data stack (`test/helpers/tasks_data_stack.dart`: the real repository, an in-memory database and preferences, the real fake API with no latency, a clock you can move), with `waitFor` for bounded waits; `ScriptedTaskApi` scripts the server's answers.
- **Views:** widget tests with `MockCubit` (`bloc_test`) and `mocktail`; one state per test (conventions §11.73).
- **drift:** an in-memory database; insert broken rows to prove a constraint.
- **App-level flows:** `pumpStarter` (with `beforeLaunch:`, `offline:`, `preferences:`, `wallpaperColor:`), and `tearDown(getIt.reset)`. A plugin touched while the graph is built needs its channel mocked in `configureTestDependencies`.
- **Prove a new test can fail:** break the rule it guards and run it.

See [docs/TESTING.md](docs/TESTING.md).

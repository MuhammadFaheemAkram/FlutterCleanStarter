# Testing

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test
```

**388 tests**, all on the host: no device, no network, no real clock. CI runs the same three commands on every push and pull request, after checking that the committed generated code is current.

The template's own tests show how each layer is tested; an app built from it keeps the pattern and replaces the sample's.

## What is covered

| Area | Tests | What it pins |
|---|---:|---|
| The Tasks screens | 83 | `TasksCubit`, `TaskDetailCubit` and `TaskFormCubit` on the real data stack (the seed's loading and error, refresh messages, toggle, delete and Undo, validation after Save, one save at a time, what counts as a change, not found); each view in every state with a `MockCubit` (swipes, pulls, the discard guard, SnackBars and closing once); the card (overdue, due, done, labels, a screen-reader Delete, the icon at large text) |
| The design system | 54 | Both themes, and list rows keeping their icons level with a wrapped title; `overdue` and `done` at WCAG AA on every surface, in both themes and on seven wallpaper palettes; date labels; the large-text rule; the adaptive confirm dialog and date picker on Android and iOS; `SegmentedChoice` |
| Repositories and use cases | 41 | Seeding exactly once (two calls, offline, damaged data, a lost flag); a refresh that adds, never overwrites, never revives; edits that never touch `createdAt`; delete and an exact Undo; reset (offline and damaged leave everything); settings (defaults, unknown values, only changed keys written); the use cases refusing what the form would |
| The accessibility tour | 35 | Every screen and state, light and dark, text at 200 %; the tab labels at 300 % |
| App-level flows | 32 | On the real DI graph: the first launch, offline then Try again, toggle, swipe and Undo, refresh offline, add, edit, delete, the discard guard, links to missing tasks; Dark on every screen and from the first frame, dynamic color in light and dark, Reset demo data online and offline, About |
| Network and mappers | 26 | The bundled seed decodes and maps; its relative dates; latency in fake time; failures; damaged JSON of six kinds; every mapping rule; a lossless row round trip |
| The database | 24 | Every `CHECK` (blank titles, bad days, local times, an update before its creation compared as times); seed, merge and reset in one transaction each; a damaged row refused, not skipped; delete and restore; the exported schema matching the tables |
| Domain rules and models | 24 | `CalendarDate`; titles and notes at their limits, in grapheme clusters; overdue at its edges; the list's order; `DeviceColors`, `AppInfo` |
| Settings | 20 | The app-wide Cubit (no flash of the default theme, the dynamic seed); Reset demo data; the view (segments, a radio list at large text, the dynamic color switch only with wallpaper colors, the reset asking first) |
| The rename script | 20 | Every file it changes, `MainActivity` moved and the old folders gone, a second run changing nothing, renaming again, a dry run writing nothing, only what differs changing, a clear error outside a project, nine invalid options |
| Navigation | 17 | The shell (read from `AppTab`, so it holds for any tabs), typed locations and encoded ids, the form as a full-screen dialog, links with Close (kept by a screen rebuilt while covered), "Page not found" |
| Common, DI, platform | 12 | `guardWrite`, UUIDs, the composition root resolving (app-wide and the sample's), the dynamic color source on iOS, old Android and a failing plugin |

## How the tests are built

- **The data stack** (`test/helpers/tasks_data_stack.dart`): the real `TaskRepositoryImpl` on an **in-memory drift database** and in-memory preferences, with the **real fake API** (zero latency, reading the bundled seed) behind a `ScriptedTaskApi`, and a clock stopped at Wednesday 28 October 2026, 14:00 UTC (set `stack.now` to move it). Cubit, repository and use case tests run on it instead of mocks.
- **`ScriptedTaskApi`** answers a DTO list or throws an exception, in order, then falls back to the real seed; it counts the calls. **`ScriptedTaskDeletes`** answers a delete without touching the store, to make timing deterministic.
- **Fixtures:** `task()`, `taskDto()`, `demoTaskId` / `demoTaskPath`, `seedDemo`; `demoNow` and `demoToday` in `test_clock.dart`.
- **Views** use `MockCubit` (`bloc_test`) and `mocktail`, one state per test (conventions §11.73); changes over time go through `whenListen`.
- **App-level flows** use `pumpStarter` on the real DI graph (`configureTestDependencies`: an in-memory database and preferences, zero latency, a fixed clock, the dynamic color channel and `PackageInfo` mocked), with `beforeLaunch:`, `offline:`, `preferences:` and `wallpaperColor:`; `tearDown(getIt.reset)`.
- **Real and fake time:** widget tests run in fake time, and drift works on the real event loop. The harness's `settle()` pumps frame by frame, giving the real loop time, until no loading screen is left and no frame is scheduled (a spinner never lets `pumpAndSettle` finish). `settleRealAsync` and `pumpUntilFound` wait for work started by a tap.
- **The accessibility tour** (`test/helpers/accessibility.dart`, used by `accessibility_tour_test.dart` and the sample's `tasks_accessibility_tour_test.dart`) opens each screen in both themes at 200 % text on a tall phone surface, then checks tap targets, labels and contrast. Material's own date picker is checked for labels and contrast only: its day cells are 47.7 px wide.
- **The sample's tests have `task` in their file names**, and shared tests don't name it; removing the sample removes its tests and leaves the rest passing.

## Proving the tests can fail

A test that can't fail proves nothing. In every phase, rules were **broken on purpose** (a mutation: a condition removed, a transaction dropped, a comparison flipped), one at a time, and the whole suite run: each must make some test fail.

| Phase | Mutations | Examples |
|---|---:|---|
| 1: foundation | 3 | the task route before `/tasks/new`; the form not a full-screen dialog; the tab labels scaling |
| 2: data | 22 | the merge as `REPLACE` or `INSERT OR IGNORE`; tombstones ignored; the seed's flag ignored or set before the insert; `createdAt` written; reset deleting before it fetches |
| 3: the list | 18 | no read after the seed; delete not optimistic; Undo left hidden; SnackBars on every rebuild, or in the shell's Scaffold; overdue not marked |
| 4: detail and the form | 18 | errors before Save; the form skipping its own check; no discard guard; a detail showing "not found" for its own delete; the Material picker on iOS |
| 5: settings | 11 | the theme starting from the defaults; dynamic color ignoring its switch, or the dark theme ignoring the wallpaper; reset without asking |
| 6: the key rules, once more | 35 | below |

Phase 6 broke the correctness rules again against the **whole** suite, on the final code: the refresh (as `REPLACE`, as `INSERT OR IGNORE`, ignoring tombstones), tombstones (not written, not removed by Undo or a reset), the seed (its flag ignored or set too early, run twice), times (`createdAt` written, `updatedAt` kept), a reset deleting before it fetches, overdue including today, titles counted in code units, duplicate server ids accepted, settings writing every key, validation skipped by the use case or the form, the post-seed read, optimistic delete and Undo, SnackBars (on every rebuild, in the shell's Scaffold), the discard guard, closing once, the detail's own delete, the theme's first frame, dynamic color (its switch, the dark theme); and the rename script (a dry run writing, the tests' bundle ID kept, empty folders left, only `CFBundleDisplayName` renamed, the tests' imports kept, a package name with capitals accepted).

Misses along the way became tests or fixes: a damaged row silently skipped (`INSERT OR IGNORE`), two Undo tests that passed by luck (and Undo not republishing), an unreachable branch in the form's Close, and no test of dynamic color in dark mode.

## Checking the template itself

Phase 6 checked the two promises of [TEMPLATE_USAGE](TEMPLATE_USAGE.md) on fresh copies of the repository:
- **Removing the sample,** by its steps: no file with `task` in its name is left, the code analyzes with no issues, and the remaining 138 tests pass.
- **Renaming** with `tool/rename.dart` (`my_tasks`, `com.example.mytasks`, "My Tasks"), then its next steps: a second run changes nothing; format, analyze and all 385 tests pass; the Android and iOS debug builds succeed with the new IDs and name.

They found three things fixed in the template: drift's generated code for a database with no tables warns about an unused field (`build.yaml` now ignores it in generated parts); `dart fix --apply` must be limited to `directives_ordering` (its other fixes rewrite test stubs); and the shared tests named the sample (they now read the tabs from `AppTab`).

## Checked on devices

Every phase was checked on an **iPhone 17 Pro simulator** (light, dark, large text) and, for dynamic color and a **release build** (Phase 6: it launches, seeds and draws in the wallpaper's colors), on an **Android 16 emulator** (Pixel 10 Pro). Three problems only a device showed, each now pinned by a test: the Undo SnackBar covering the Add button in the tab shell (Phase 3), a small status icon beside wrapped text at the largest text size (Phase 3), and list rows' icons drifting away from their titles at that size (Phase 6).

## Gotchas worth knowing

From the conventions' traps, the ones this suite runs into:

- **§11.13:** a dismissed `Dismissible` must leave the tree at once; hide the row in the Cubit before the database answers.
- **§11.32, §11.33:** a write can answer before drift's stream reports it; read the store again before deciding.
- **§11.44:** async work before a widget test's first pump waits on fake time forever; run it in `runAsync` (`pumpStarter(beforeLaunch:)`).
- **§11.58:** a plugin channel called while the graph is built hangs app tests; mock it in `configureTestDependencies`.
- **§11.73:** a `MockCubit` pumped again keeps its first state; one state per test.
- **§11.77:** under a full-screen dialog, `find.text` also matches the page beneath; target the dialog's own widgets.
- **§11.86:** `INSERT OR IGNORE` also ignores `CHECK` failures.
- **§11.87:** in a tab shell, SnackBars cover the tab screen's FAB unless the screen has its own `ScaffoldMessenger`.
- **A spinner never lets `pumpAndSettle` finish:** settle frame by frame while a loading screen shows.

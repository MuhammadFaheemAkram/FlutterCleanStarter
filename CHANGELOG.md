# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project follows [Conventional Commits](https://www.conventionalcommits.org/).

## [Unreleased]

_All six build phases are complete. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's next._

### Fixed
- **The Close fallback** asked `Navigator.canPop()`, which answers for the whole stack: a screen opened by a link and rebuilt while another covered it would lose Close, and have no way out after Back. It now asks its own route (`ModalRoute.impliesAppBarDismissal`, as the `AppBar` does). Tested on the helper itself.

## [0.6.0] — 2026-10-28 — Phase 6: Documentation & CI

### Added
- **`tool/rename.dart`:** renames the package (and every import), the Android application ID, namespace and `MainActivity` folder, the iOS bundle IDs, and the display names; reads the current names from the project (a second run changes nothing), with `--dry-run`. Tested on a copy of the real files.
- **Docs:** TEMPLATE_USAGE (clone, rename, remove the sample, add a feature, replace the fake API, what the template leaves out, before you ship), ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS; the Phase 6 summary.
- **Open-source files:** CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, this CHANGELOG, and the GitHub issue and PR templates.
- **The template checked on scratch copies:** the sample removed by following TEMPLATE_USAGE (analyze and tests pass); the project renamed with the script (analyze, tests and both builds pass).
- **A final mutation pass** of the key rules and the rename script, against the whole suite (35, each caught), and a release-build launch on Android.

### Changed
- **Shared code and tests no longer depend on the sample:** the Settings screen takes the sample's section as a parameter; the shell's tests read the tabs from `AppTab`; the sample's test cases moved into files named `task*`; the test clock moved to `test_clock.dart`; `pumpStarter` takes `beforeLaunch:` instead of `withDemo:`.
- **`build.yaml`** also ignores `unused_field` in generated parts (drift's code for a database with no tables yet).

### Fixed
- **At the largest text, list rows' icons drifted to the middle of a wrapped row:** the theme keeps them level with the title.
- **The accessibility tour's "Task" and "Edit task" stops** checked "Task not found" (a link opened cold has no data): they now store the demo first and check what's shown.

## [0.5.0] — 2026-10-28 — Phase 5: Settings

### Added
- The app-wide `SettingsCubit` above the router: System / Light / Dark on every screen at once and from the first frame; dynamic color on Android 12+ (`DynamicColorSource`, `MaterialYouColorSource`), hidden elsewhere.
- Settings: appearance as segments (a radio list at large text), Reset demo data after a confirmation, About (`package_info_plus`); `SegmentedChoice`.
- Contrast checks of the meaning colors on seven wallpaper palettes.

## [0.4.0] — 2026-10-28 — Phase 4: Create / Edit + Detail

### Added
- Task detail: the status, a Done switch, notes, the due date, history; Edit; Delete after an adaptive confirmation; "Task not found".
- One form for Add and Edit (`@factoryParam`): errors after the first Save, the adaptive date picker (Material calendar, iOS wheel), a Done switch, the discard guard, closing once saved.
- `showConfirmDialog`, `DatePickerField`, long day and date-time labels.

### Fixed
- Close in the form read a stale state, so a fast tap after typing skipped "Discard changes?".

## [0.3.0] — 2026-10-28 — Phase 3: The Tasks List

### Added
- `TasksCubit` and the Tasks screen: the seed on first launch (loading, error, Try again), the list in order, toggle, swipe to delete with Undo, pull to refresh, empty.
- `TaskCard` with overdue / due / done (an icon and words), a screen-reader Delete action, and an icon sized to the text.

### Fixed
- The Undo SnackBar covered the Add button (the tab shell's outer Scaffold showed it): the Tasks screen has its own `ScaffoldMessenger`.
- A "No tasks yet" flash after the first seed; Undo waiting for drift before showing the row again.

## [0.2.0] — 2026-10-28 — Phase 2: Core Data Layer

### Added
- `Result` / `AppException` / `guardWrite`, `IdGenerator`, `CalendarDate`, `Task`, `AppSettings`, `TaskRules`, the repository contracts and the use cases.
- The fake API over bundled JSON with relative due dates; drift v1 (`tasks` with `CHECK`s, `deleted_tasks` tombstones), the schema exported; mappers that validate; the repositories; settings loaded before the first frame.

### Fixed
- The refresh used `INSERT OR IGNORE`, which silently skips rows breaking a `CHECK`: it is `ON CONFLICT DO NOTHING`.

## [0.1.0] — 2026-10-28 — Phase 1: Foundation

### Added
- The FVM-pinned project, strict analysis, CI, the MIT license.
- Themes from a seed, `AppColors` (overdue, done) with contrast tests, tokens, state views, the large-text rule.
- Typed routes: a two-tab shell and the task routes; the Close fallback for links; the DI root; the accessibility tour.

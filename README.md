# 🧱 Flutter Clean Starter

[![Flutter CI](https://github.com/MuhammadFaheemAkram/FlutterCleanStarter/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/MuhammadFaheemAkram/FlutterCleanStarter/actions/workflows/flutter-ci.yml)
![Flutter 3.47.6](https://img.shields.io/badge/Flutter-3.47.6-02569B?logo=flutter)
![Dart 3.13](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A **starter template** for Flutter apps. Architecture, DI, persistence, a fake API, navigation, a design system, tests and CI come already wired. One small sample feature, **Tasks**, runs through every layer.

It runs on **Android and iOS**, fully offline: there is **no API key and no server**.

> **Why this repo exists**
>
> Every new app needs the same plumbing before its first feature. This template packages the stack and the lessons of six earlier BitFuse Flutter apps (MovieExplorer to Evently) into something you can:
> 1. **clone** and run straight away (generated code is committed);
> 2. **rename** with one script (package, app ID, bundle ID, display name);
> 3. **strip** of the sample feature by deleting a known list of files;
> 4. **extend** by following the Tasks feature's shape, layer by layer.
>
> It is the Flutter edition of a template that also exists natively for [Android](https://github.com/MuhammadFaheemAkram/AndroidCleanStarter) and [iOS](https://github.com/MuhammadFaheemAkram/SwiftStarterKit). Each phase ships with a beginner-to-intermediate friendly write-up in [`docs/`](docs/), which also shows how the Android and iOS editions approached the same step.

---

## 📋 Project Status

The template is built in **strict, reviewable phases**. Each phase ends with:
- a building app (Android + iOS);
- a clean analyzer and passing tests;
- a summary doc;
- exactly one commit.

| Phase | Scope | Status |
|------:|-------|:------:|
| 1 | Foundation: FVM project, design system base, typed routes with a 2-tab shell and the task routes, DI root, CI | ✅ Done |
| 2 | Core data layer: models, drift, the fake API, repositories, use cases, settings storage | ✅ Done |
| 3 | The Tasks list: seed on first launch, toggle, swipe to delete with Undo, pull to refresh, every state | ✅ Done |
| 4 | Task detail and the Add / Edit form: validation, an adaptive date picker, the discard guard, delete with a confirmation | ✅ Done |
| 5 | Settings: System / Light / Dark app-wide from the first frame, dynamic color (Android 12+), Reset demo data, About | ✅ Done |
| 6 | Documentation, `tool/rename.dart`, CI | ⏳ Next |

---

## ✨ The Tasks Sample (the plan)

- ✅ **Tasks:** seeded from the fake API on first launch; mark done, swipe to delete with Undo, pull to refresh (the server's tasks are merged in, and your edits are never overwritten)
- 🗓️ **Due dates:** optional, shown as days, with **Overdue** marked by an icon and the word (never color alone)
- ✏️ **Add and edit:** a title, notes and a due date, in a full-screen form with validation and a discard guard
- 🔎 **Detail:** a task's notes and dates, Edit, and Delete with a confirmation
- ⚙️ **Settings:** System / Light / Dark, dynamic color (Android 12+), Reset demo data, About
- ♿ **Accessible:** dark mode and large text on every screen, labelled controls, checked by a test tour that grows with the app

---

## 🧰 Tech Stack

Packages arrive in the phase that first needs them, and the list stays short: every package is one a new app is likely to keep.

| Area | Choice | Since |
|------|--------|:-----:|
| Toolchain | Flutter 3.47.6 · Dart 3.13, pinned per project with [FVM](https://fvm.app) (`.fvmrc`) | 1 |
| Platforms | Android · iOS | 1 |
| UI | [`material_ui`](https://pub.dev/packages/material_ui): Material 3 as a standalone package; [`cupertino_ui`](https://pub.dev/packages/cupertino_ui) for the iOS touches (alerts, the date wheel, switches) | 1, 4 |
| Navigation | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| Dependency injection | `get_it` + `injectable` (a code-generated composition root, `@preResolve` for the preferences) | 1 |
| Models | `freezed` (immutable domain models) + `json_serializable` (checked DTOs) | 2 |
| Database | `drift` + `drift_flutter` (SQLite, typed queries, streams; schema exported from v1) | 2 |
| Preferences | `shared_preferences` (`SharedPreferencesWithCache`, loaded before the first frame) | 2 |
| Time and text | `clock` (an injectable "now"), `characters` (title lengths in grapheme clusters), `intl` (dates) | 2–3 |
| State | `flutter_bloc`: Cubits, one per screen, with one-time effects as serials; one app-wide `SettingsCubit` | 3, 5 |
| Platform | `dynamic_color` (the wallpaper's palette, Android 12+), `package_info_plus` (About) | 5 |
| Lints / CI | `flutter_lints` + strict analyzer modes; GitHub Actions | 1 |
| Testing | `flutter_test`, `fake_async`, `bloc_test`, `mocktail`, an in-memory drift database and preferences store | 1–3 |

No other packages are planned: a new app adds its own.

---

## 🏛️ Architecture

A clean, layered architecture with a one-directional data flow:

```
View ─▶ Cubit ─▶ UseCase ─▶ Repository ─▶ drift (the store) / the fake API (the seed)
  ▲                                            │
  └──────────── drift streams ◀────────────────┘
```

```
lib/
├── app/        → root widget (MaterialApp.router, themes)
├── core/       → common (Result, errors), design system, navigation, database, network (the fake API), storage
├── data/       → repository implementations + mappers
├── domain/     → models, pure rules, repository contracts, use cases (pure Dart)
├── features/   → one folder per screen (Page + View + Cubit)
└── di/         → composition root (get_it + injectable)
```

**Data flow:**

```
                 ┌──────────── reads: drift streams ────────────┐
                 ▼                                              │
View ◀── Cubit ◀── UseCase ◀── TaskRepository ── TasksDao ── drift (SQLite)
                                   │                    ▲
                                   │ seed · refresh ·   │ one transaction each
                                   ▼ reset              │
                                TaskApi (FakeTaskApi) ──┘  TaskDto → Task → TaskRow
```

- **drift is the source of truth.** Screens watch its streams; the API only seeds the store on first launch, adds the server's new tasks on a refresh, and replaces everything on Reset demo data.
- **The device owns the tasks.** Adding, editing, completing and deleting are local writes. A refresh never overwrites a stored task (`ON CONFLICT DO NOTHING`), and a tombstone keeps a deleted task from coming back.
- **Three models per record:** `TaskDto` (the API's JSON) → `Task` (the app's) ↔ `TaskRow` (drift), with mappers that check the server's data before anything is written.
- **Writes return a `Result`** (`Ok` or `Err` with a sealed `AppException`) and never throw.
- **Settings are app-wide:** a `SettingsCubit` above `MaterialApp.router` applies the theme mode and dynamic color to every screen at once, starting from the preferences loaded before the first frame.
- **A Cubit per screen** turns use cases into one immutable state. One-time effects (a SnackBar, the Undo offer) carry a *serial*, so each fires once; the View shows them and navigates, never the Cubit.

**Navigation:**

```
GoRouter (initialLocation: /tasks)
  │
  ├─ tab shell     StatefulShellRoute ── MainShell (NavigationBar)
  │                  /tasks · /settings
  │
  └─ root-level    /tasks/new             → the form, a full-screen dialog
     screens       /tasks/:taskId         → a task, pushed above the tabs
                   /tasks/:taskId/edit    → the form over its task
```

Key rules:
- **Typed routes only:** no string paths in widgets.
- **Screens above the tabs** are pushed on the root navigator, so Back and the iOS edge swipe return to the tab with its state intact. Links work: `/tasks/t1/edit` opens the form over its task, and a screen opened cold by a link gets a Close button.
- **Navigation happens in Views,** never in Cubits.
- **Layer boundaries:** `domain/` is pure Dart, Views never import `data/`, and only `data/` touches the database and the API.

---

## 🗂️ Folder Structure

```
FlutterCleanStarter/
├── .fvmrc                          # pinned Flutter version (3.47.6)
├── .github/workflows/flutter-ci.yml
├── analysis_options.yaml           # lints + strict analyzer modes
├── build.yaml                      # lint-free generated files
├── lib/
│   ├── main.dart                   # binding → configureDependencies() → runApp
│   ├── app/                        # StarterApp: themes and the router
│   ├── core/
│   │   ├── common/                 # Result, AppException, guardWrite, IdGenerator
│   │   ├── design_system/          # theme/ (AppTheme, AppColors, tokens), widgets/ (state views, ConfirmDialog, DatePickerField, SectionHeader), date_labels, large_text
│   │   ├── navigation/             # app_routes (+ .g.dart), app_router, the Close fallback
│   │   ├── network/                # AssetJsonLoader, NetworkSimulator, [TaskApi, FakeTaskApi, dto/TaskDto]
│   │   ├── platform/               # MaterialYouColorSource (dynamic_color)
│   │   ├── database/               # AppDatabase, [tables/tasks, daos/tasks_dao]
│   │   └── storage/                # SettingsLocalDataSource, [TasksPreferences]
│   ├── data/
│   │   ├── mapper/                 # [task_mappers]
│   │   └── repository/             # SettingsRepositoryImpl, [TaskRepositoryImpl]
│   ├── domain/
│   │   ├── model/                  # AppSettings, CalendarDate, DeviceColors, AppInfo, [Task, TaskDraft]
│   │   ├── calculation/            # [task_rules: validation, overdue, ordering]
│   │   ├── repository/             # SettingsRepository, [TaskRepository]
│   │   ├── service/                # DynamicColorSource
│   │   └── usecase/                # settings_use_cases, [task_use_cases]
│   ├── features/                   # shell, [tasks, task_detail, task_form], settings (page, cubit/SettingsCubit, [cubit/tasks_demo_*, widgets/tasks_demo_section])
│   └── di/                         # injection.dart (+ .config.dart), app_module.dart
├── assets/json/                    # [seed_tasks.json]
├── drift_schemas/                  # every exported schema version
└── test/                           # mirrors lib/, plus app/ (the accessibility tour) and helpers/
```

`[…]` marks the sample feature: what you delete to start your own app.

---

## 🌐 The Fake API and Persistence

- **No server, no key.** `FakeTaskApi` implements `TaskApi` by reading `assets/json/seed_tasks.json` after a simulated 600 ms delay. The seed's due dates are relative (`"dueInDays": 2`), so a fresh demo always has one task due soon and one overdue; once stored, a due date never moves. To see the offline handling, set `NetworkSimulator.shouldThrowError` to `true`.
- **Tasks live in drift** (`tasks`, plus `deleted_tasks` tombstones). The database enforces its own rules with `CHECK`s: a title that isn't blank, UTC times, an update never before the creation.
- **Settings live in `SharedPreferencesWithCache`,** loaded before the first frame. Only the keys that changed are written.
- **Replacing the fake API** means writing a `TaskApi` with `dio` (or `http`) and registering it instead of `FakeTaskApi`: nothing above the data layer changes.

---

## ▶️ How to Run

Prerequisites:
- [FVM](https://fvm.app);
- Xcode, for iOS;
- the Android SDK, with Java 17+ (Android Studio's bundled JDK works).

```bash
fvm install            # installs the version pinned in .fvmrc (3.47.6)
fvm flutter pub get
fvm flutter run        # pick an Android emulator or an iOS simulator
```

Generated code (`*.g.dart`, `*.config.dart`) is committed, so the app runs straight after cloning. After changing annotated code, regenerate it:

```bash
fvm dart run build_runner build
```

---

## 🧬 Starting a New App From It

The full guide (`docs/TEMPLATE_USAGE.md`) and the rename script (`tool/rename.dart`) arrive in Phase 6: rename the package and IDs, delete the sample feature's files, and add your own features in its shape.

---

## ✅ Testing

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed .
fvm flutter test
```

**361 tests** after Phase 5:
- **Settings:** the app-wide Cubit (no flash of the default theme, changes saved and followed, the dynamic seed); Reset demo data (the sample back, offline unchanged, one at a time); the view (segments, a radio list at large text, the dynamic color switch only with wallpaper colors, the reset asking first); app flows (Dark on every screen and from the first frame, Light over a dark device, dynamic color in light and dark and switched off, reset online and offline, About); `overdue` and `done` readable on seven wallpaper hues in both themes; the dynamic color source on iOS, old Android and a failing plugin.
- **Task detail and the form:** both Cubits on the real data stack (`@factoryParam` ids; not found; toggle; delete never flashing "not found"; validation shown only after Save, the use case never reached when invalid; one save at a time; edits elsewhere never overwriting what's typed; what counts as a change); both views with a mocked Cubit (the discard guard on Close and on the system back gesture, Save disabled while saving, closing once); the adaptive confirm dialog and date picker on Android and iOS; app flows (add, add with a date, discard, edit, toggle, delete with and without confirming, links to missing tasks).
- **The Tasks screen:** the Cubit on the real data stack (the seed's loading, error and Try again with no "No tasks" flash; refresh messages; toggle; delete at once, Undo, a failed delete; changes from elsewhere); the view in every state with a mocked Cubit (swipe, pull, the SnackBars once); the card (overdue, due, done, the icon at large text, screen-reader labels and a Delete action); app flows on the real DI graph, including the Undo SnackBar sitting above the Add button.
- **Domain:** `CalendarDate`; the title and notes rules at their limits (grapheme clusters); overdue at its edges; the list's order; the use cases refusing what the form would.
- **Database (in memory):** every `CHECK`; seed, merge and reset each in one transaction; a refresh that never overwrites an edit or revives a deleted task; delete and Undo; the exported schema matching the tables.
- **Network and mappers:** the bundled seed decodes and maps, its relative dates, latency and failures, damaged JSON; every mapping rule.
- **Repositories:** on a real data stack (`DataStack`: in-memory drift and preferences, the real fake API, a fixed clock) with a scripted API for failures: seeding exactly once, refresh, add, edit, toggle, delete and restore, reset, offline and damaged data; settings read, defaults, only changed keys written.
- **Navigation:** typed locations, ids encoded; the app on its real DI graph: both tabs, a tab keeping its screen, Add as a full-screen dialog with Close, a task pushed above the tabs with Back, Edit over its task, links (`/tasks/new`, `/tasks/t1`, `/tasks/t1/edit`) with a Close button, an unknown location.
- **Design system:** the themes (from the seed, from any seed or scheme), `AppColors` (`lerp`, `copyWith`, the context shorthand), and WCAG AA contrast of `overdue` and `done` on the page, cards and filled fields in both themes; the large-text rule.
- **DI:** the real composition root resolves every repository and use case, with the settings loaded before the first frame.
- **The accessibility tour:** every screen and state (Tasks: the demo, empty, offline, the Undo SnackBar; a task, not found, its Delete dialog; the form with its errors, the discard dialog and the date picker; Settings with and without dynamic color, the reset dialog), in light and dark at 200 % text: no overflow, tap targets ≥ 48 × 48, labels, contrast. The tab labels keep their size at 300 % (a long press shows them).

CI (`.github/workflows/flutter-ci.yml`) runs on every push to `main` and every pull request. It installs the FVM-pinned Flutter, checks that the committed generated code is up to date and complete, then runs format, analyze and test.

---

## 📱 Same Template on Other Platforms

| Edition | Stack | Repo |
|---------|-------|------|
| Android | Kotlin · Jetpack Compose · Hilt · Room · DataStore | [MuhammadFaheemAkram/AndroidCleanStarter](https://github.com/MuhammadFaheemAkram/AndroidCleanStarter) |
| iOS | Swift 6 · SwiftUI · SwiftData · `@AppStorage` | [MuhammadFaheemAkram/SwiftStarterKit](https://github.com/MuhammadFaheemAkram/SwiftStarterKit) |
| **Flutter** | Dart · Flutter · Bloc · drift | this repo |

| Concept | Android | iOS | Flutter |
|---|---|---|---|
| UI | Jetpack Compose | SwiftUI | widgets + `material_ui` (adaptive where it matters) |
| Settings | DataStore, a dark-mode toggle, dynamic color | `@AppStorage`, a System / Light / Dark picker | `SharedPreferencesWithCache` + an app-wide Cubit; System / Light / Dark, dynamic color on Android 12+ |
| Navigation | Navigation Compose, bottom nav | `TabView` + `NavigationStack` + `Route` | `StatefulShellRoute` + typed routes |
| Persistence | Room + DataStore | SwiftData + `@AppStorage` | drift + `SharedPreferencesWithCache` |
| Fake API | Retrofit-style service | protocol + bundled JSON | `TaskApi` + `FakeTaskApi` reading bundled JSON |
| Screen state | ViewModel + StateFlow | `@Observable` | Cubit |
| One-time effects | sealed `Effect` + Channel | a dismiss signal | `BlocListener` on a serial |
| DI | Hilt modules | `AppEnvironment` | `get_it` + `injectable` |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (generated code checked, format, analyze, test) |

The full table (state, persistence, the fake API, tests) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)
- [Phase 2 — Core Data Layer](docs/PHASE_2_SUMMARY.md)
- [Phase 3 — The Tasks List](docs/PHASE_3_SUMMARY.md)
- [Phase 4 — Create / Edit + Detail](docs/PHASE_4_SUMMARY.md)
- [Phase 5 — Settings](docs/PHASE_5_SUMMARY.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (an onboarding gate, authentication, notifications, a real API with `dio`, flavors, localization) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse

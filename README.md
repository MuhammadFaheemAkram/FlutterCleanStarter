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
| 2 | Core data layer: models, drift, the fake API, repositories, settings storage | ⏳ Next |
| 3 | The Tasks list | |
| 4 | Task detail and the Add / Edit form | |
| 5 | Settings | |
| 6 | Documentation, `tool/rename.dart`, CI | |

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
| UI | [`material_ui`](https://pub.dev/packages/material_ui): Material 3 as a standalone package | 1 |
| Navigation | `go_router` + `go_router_builder` (typed routes, `StatefulShellRoute`) | 1 |
| Dependency injection | `get_it` + `injectable` (a code-generated composition root) | 1 |
| Lints / CI | `flutter_lints` + strict analyzer modes; GitHub Actions | 1 |
| Testing | `flutter_test` | 1 |

Planned: `freezed`, `json_serializable`, `drift`, `shared_preferences`, `clock`, `intl` (Phase 2); `flutter_bloc`, `bloc_test`, `mocktail` (Phase 3); `characters`, `cupertino_ui` (Phase 4); `dynamic_color`, `package_info_plus` (Phase 5).

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
├── core/       → design system, navigation, (later) the database, the fake API, settings storage
├── data/       → repository implementations + mappers               (Phase 2)
├── domain/     → models, pure rules, contracts, use cases            (Phase 2)
├── features/   → one folder per screen (Page + View + Cubit)
└── di/         → composition root (get_it + injectable)
```

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
│   │   ├── design_system/          # theme/ (AppTheme, AppColors, tokens), widgets/ (state views, SectionHeader), large_text
│   │   └── navigation/             # app_routes (+ .g.dart), app_router, the Close fallback
│   ├── features/                   # shell, tasks, task_detail, task_form, settings
│   └── di/                         # injection.dart (+ .config.dart)
└── test/                           # mirrors lib/, plus app/ (the accessibility tour) and helpers/
```

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

**49 tests** after Phase 1:
- **Navigation:** typed locations, ids encoded; the app on its real DI graph: both tabs, a tab keeping its screen, Add as a full-screen dialog with Close, a task pushed above the tabs with Back, Edit over its task, links (`/tasks/new`, `/tasks/t1`, `/tasks/t1/edit`) with a Close button, an unknown location.
- **Design system:** the themes (from the seed, from any seed or scheme), `AppColors` (`lerp`, `copyWith`, the context shorthand), and WCAG AA contrast of `overdue` and `done` on the page, cards and filled fields in both themes; the large-text rule.
- **DI:** the real composition root builds.
- **The accessibility tour:** every screen, in light and dark at 200 % text: no overflow, tap targets ≥ 48 × 48, labels, contrast. The tab labels keep their size at 300 % (a long press shows them).

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
| Navigation | Navigation Compose, bottom nav | `TabView` + `NavigationStack` + `Route` | `StatefulShellRoute` + typed routes |
| DI | Hilt modules | `AppEnvironment` | `get_it` + `injectable` |
| CI | `android-ci.yml` | `ios-ci.yml` | `flutter-ci.yml` (generated code checked, format, analyze, test) |

The full table (state, persistence, the fake API, tests) grows with the phases.

---

## 📚 Documentation

- [Phase 1 — Foundation](docs/PHASE_1_SUMMARY.md)

---

## 🗺️ Roadmap

The phases above. Ideas after them (an onboarding gate, authentication, notifications, a real API with `dio`, flavors, localization) are collected in `docs/ROADMAP.md` in Phase 6.

---

## 📄 License

[MIT](LICENSE) © 2026 BitFuse

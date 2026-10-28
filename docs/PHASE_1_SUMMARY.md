# Phase 1 — Foundation

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 1, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 1 builds the frame the rest of the template hangs on:
- a **pinned toolchain** and strict analysis, with CI from the first commit;
- a **design system base:** themes from one seed, the two colors that carry meaning (`overdue`, `done`), tokens and the shared state views;
- **navigation:** two tabs (Tasks, Settings), and the task screens above them, each reachable by a typed route and by a link;
- **placeholder screens** with their final app bars, so the shape of the app is visible and testable now;
- an **accessibility tour** that checks every screen from day one.

A template is copied, so the foundation matters more here than in an app: whatever it does, every app built from it does too.

---

## 🧱 What Was Implemented

- **Project:** `flutter_clean_starter` (org `co.bitfuse.flutter`, display name "Clean Starter"), Flutter 3.47.6 pinned by FVM, Android and iOS, `material_ui`. The app ID is `co.bitfuse.flutter.cleanstarter` on both platforms (`flutter create` derives a different one for each).
- **Quality gates:**
  - `analysis_options.yaml`: flutter_lints plus strict casts, inference and raw types;
  - `build.yaml`: lint-free generated parts;
  - GitHub Actions CI: generated code up to date with nothing left untracked, then format, analyze and test;
  - the MIT license.
- **Design system:**
  - `AppTheme`: Material 3 light and dark themes from a teal seed (`#00696E`, the `fidelity` variant so the primary stays close to it). `AppTheme.fromSeed(color, brightness)` takes any seed (Android's dynamic color will pass the wallpaper's), and `fromScheme` any `ColorScheme`;
  - `AppColors` (a `ThemeExtension`): `overdue` and `done`, each a text color that reaches WCAG AA on the page, cards and filled fields in both themes (tested). A new app replaces these two with its own;
  - spacing, radius and icon-size tokens; `LoadingView`, `ErrorView`, `EmptyStateView`, `SectionHeader`; the large-text rule (`context.prefersStackedLayout` above 130 %).
- **Navigation (typed `go_router` routes):**
  - a `StatefulShellRoute` with two tabs: Tasks (`/tasks`) and Settings (`/settings`);
  - above the tabs: the form for a new task at `/tasks/new` (a full-screen dialog), a task at `/tasks/:taskId`, and its edit form as the child `edit` (a full-screen dialog over its task);
  - `/tasks/new` is declared **before** `/tasks/:taskId`, so "new" is never read as an id (tested);
  - "Page not found" for an unknown location, with "Go to Tasks";
  - no first-launch gate: the router's doc comment says where one goes.
- **Screens:** Tasks (with the Add button), Task (with Edit), New task / Edit task (one page, `taskId` or not), Settings. Each has its final app bar. A task opened cold by a link gets a Close button to Tasks; the form's Close goes to its task, or to Tasks (conventions §11.47).
- **DI:** the `get_it` + `injectable` composition root, empty for now.
- **Tests:** 49.

### Differences from the plan

- **`AppTheme.fromSeed` and `fromScheme`.** The spec names `fromSeed(color, brightness)`; `fromScheme` stays too, so a scheme from anywhere (a design tool, a brand) can drive the theme. Both are tested.
- **No `cupertino_ui` yet.** No screen needs a Cupertino widget until the form's date picker (Phase 4); it arrives then, with the rest of the packages added in the phase that first uses them.
- **Mutation checks from Phase 1.** Three were run: `/tasks/:taskId` declared first, the form not a full-screen dialog, the tab labels scaling with the text. Each made a test fail.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **FVM pinning:** `.fvmrc` makes the Flutter version part of the repository; the machine's global version stays untouched.
- **Typed routes:** `@TypedGoRoute` classes generate `location`, `go` and `push`; a route with a parameter can't be built without it, and ids are encoded into the path (`a b/c` → `a%20b%2Fc`, tested).
- **Route order matters:** go_router takes the first match, so a fixed segment (`/tasks/new`) goes before a parameter (`/tasks/:taskId`).
- **One page, two routes:** `NewTaskRoute` and `EditTaskRoute` build the same `TaskFormPage`; a `null` id means "new".
- **Child routes for "over its parent":** the edit form is a child of `/tasks/:taskId`, so a link to it opens with the task underneath, and Close returns to it.
- **A tab path and a root-level path side by side:** `/tasks` is a tab; `/tasks/t1` is a screen above the shell, covering the tab bar.
- **`StatefulShellRoute.indexedStack`:** a navigator per tab, kept alive, so each tab keeps its stack and scroll position.
- **Full-screen dialogs:** `MaterialPage(fullscreenDialog: true)` slides up and shows a Close button: Material's counterpart of an iOS sheet.
- **`ThemeExtension`:** colors Material has no slot for, switching and animating (`lerp`) with the theme, read with `context.appColors`.
- **`ColorScheme.fromSeed` with `DynamicSchemeVariant.fidelity`:** a whole palette from one color, keeping the primary close to it.
- **`MediaQuery.withNoTextScaling`** for the tab labels, with the label still available through a long press and to screen readers.
- **Accessibility guidelines in tests:** `meetsGuideline(androidTapTargetGuideline / labeledTapTargetGuideline / textContrastGuideline)`.

---

## 🔁 Data Flow (this phase)

```
App start ─▶ configureDependencies() ─▶ StarterApp ─▶ GoRouter(initialLocation: /tasks)
  the tab shell (MainShell + NavigationBar)
    Tasks ── Add (FAB) ─▶ NewTaskRoute().push ─▶ the form, a full-screen dialog ── Close ─▶ pop
    Settings
  a link ─▶ /tasks/t1        ─▶ the task, with Close ─▶ go(/tasks)
  a link ─▶ /tasks/t1/edit   ─▶ the task, with the form over it ── Close ─▶ pop to the task
  a link ─▶ /nowhere         ─▶ "Page not found" ── Go to Tasks
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `.fvmrc`, `analysis_options.yaml`, `build.yaml`, `.github/workflows/flutter-ci.yml`, `LICENSE` | Toolchain, lints, codegen, CI, license. |
| `lib/core/design_system/**` | Theme, the meaning colors, tokens, state views, the large-text rule. |
| `lib/core/navigation/app_routes.dart` (+ `.g.dart`) | Every typed route. |
| `lib/core/navigation/app_router.dart`, `fallback_close_button.dart` | The router, "Page not found", and the Close fallback for links. |
| `lib/features/shell/main_shell.dart` | The tabs. |
| `lib/features/{tasks,task_detail,task_form,settings}/…_page.dart` | The placeholder screens. |
| `lib/app/starter_app.dart`, `lib/di/injection.dart`, `lib/main.dart` | The app root and DI. |
| `test/app/accessibility_tour_test.dart`, `test/core/**`, `test/di/*`, `test/helpers/*` | The tour, theme and navigation tests, the app harness. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `AppTheme` | final class (namespace) | Themes from a seed or any `ColorScheme` | `core/design_system/theme` |
| `AppColors` | `ThemeExtension` | The overdue and done colors | `core/design_system/theme`: views ask for an intent, not a raw color |
| `StarterApp` | StatefulWidget | Owns the router; the themes | `app/` |
| `MainShellRoute`, `TasksRoute`, `SettingsRoute`, `NewTaskRoute`, `TaskDetailRoute`, `EditTaskRoute` | typed route data | Every destination | `core/navigation` |
| `MainShell`, `AppTab` | StatelessWidget / enum | The tab bar and its tabs | `features/shell` |
| `TaskFormPage` | StatelessWidget | New and Edit, one page | `features/task_form` |

---

## 🌱 Folder Structure Changes

- **New project.** `lib/app`, `lib/core/{design_system,navigation}`, `lib/features/{shell,tasks,task_detail,task_form,settings}`, `lib/di`; `test/` mirroring it, plus `test/app` and `test/helpers`.
- `core/{common,network,database,storage}`, `data/`, `domain/`, `assets/json/` and `tool/` arrive with the phases that fill them.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Project | Gradle setup, the package structure, an `Application` class and `MainActivity` | iOS 17, Swift 6, the full folder structure | FVM-pinned Flutter, strict analysis, `build.yaml`; folders added as they're filled |
| DI | Hilt setup | an `AppEnvironment` composition root | `get_it` + `injectable`, `configureDependencies()` before `runApp` |
| Theme | Material 3 theme | a design system base | Material 3 from a seed, `fromSeed` / `fromScheme` ready for dynamic color, `AppColors` with contrast tests, tokens, state views |
| Navigation | route definitions, bottom navigation | `Route` + `Router`, a `TabView` | typed `go_router` routes: a 2-tab `StatefulShellRoute`, plus the task, new and edit routes already in place |
| Screens | placeholder Tasks and Settings | placeholder Tasks and Settings | the same, plus placeholder Task and form screens with their final app bars |
| Docs | a basic README | README and `PHASE_1_SUMMARY.md` | README v1 and this summary |
| CI | Phase 6 | Phase 6 | Phase 1 |
| Accessibility checks | — | — | a test tour of every screen from Phase 1 |

All three start with the same two tabs. The Flutter edition also declares the task routes now (the iOS set: detail and an edit form), so links and Close behaviour are tested before the screens exist.

---

## 🎤 Interview Notes

**Q: Why is `/tasks/new` declared before `/tasks/:taskId`?**
A: go_router matches routes in order. With the parameter first, "new" would be taken as a task's id and the detail screen would open. A test opens `/tasks/new` and checks the form appears; moving the route breaks it.

**Q: Why do the placeholder screens already have their final app bars?**
A: So navigation can be tested end to end from the first phase: which button opens what, where Close goes for a link opened cold, what the full-screen dialog looks like. Later phases fill the bodies without changing those tests.

**Q: Why a `ThemeExtension` for two colors?**
A: Widgets ask for an intent ("overdue") rather than a hex value, the light and dark variants switch with the theme, and a single test checks their contrast on every surface. An app built from the template swaps the two tokens for its own and keeps the mechanism.

**Q: Why CI in the first commit of a template?**
A: Whoever clones it gets a green pipeline that already checks generated code, formatting, the analyzer and tests. Adding CI later means the first CI run finds problems that piled up.

---

## 📝 Learning Checklist

- ✅ Pin Flutter per project with FVM, and gate every commit with CI
- ✅ Build Material 3 themes from a seed, ready for any seed or `ColorScheme`
- ✅ Add app-specific colors with a `ThemeExtension`, contrast-tested
- ✅ Declare typed routes, a tab shell, child routes, and full-screen dialogs above it
- ✅ Order routes so a fixed segment wins over a parameter
- ✅ Check accessibility guidelines in widget tests
- ⬜ The models, drift, the fake API, the repositories and settings storage (Phase 2)

---

## 🚀 Future Improvements

- **Phase 2:** `CalendarDate`, `Task`, `AppSettings`, `Result` / `AppException`; drift with the `tasks` and `deleted_tasks` tables; the fake API seeded from bundled JSON; the repositories (seed once, refresh by merge, reset) and the use cases.
- **Phase 3:** the Tasks list.
- **Later:** a `NavigationRail` instead of the bar on tablets and in landscape.

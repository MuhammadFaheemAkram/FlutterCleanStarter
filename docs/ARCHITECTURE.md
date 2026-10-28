# Architecture

Flutter Clean Starter is layered, one-directional, and offline-first. This page is the map: what each layer may know, who owns which data, how state, errors, navigation and DI work, and why.

---

## Layers

```
┌──────────────────────────────────────────────────────────────┐
│ features/   Page (creates the Cubit) → View (renders state)  │  widgets, material_ui
│             Cubit + freezed state                            │  flutter_bloc
├──────────────────────────────────────────────────────────────┤
│ domain/     models · rules · repository contracts · use cases│  pure Dart
│             service interfaces (DynamicColorSource)          │
├──────────────────────────────────────────────────────────────┤
│ data/       repository implementations · mappers             │
├──────────────────────────────────────────────────────────────┤
│ core/       database (drift) · network (the fake API, DTOs)  │
│             storage (preferences) · platform · common        │
│             design_system · navigation                       │
└──────────────────────────────────────────────────────────────┘
   di/        the composition root: chooses every implementation
```

**Import rules:**
- `domain/` imports no Flutter, no drift, no JSON: it is testable with plain `test`.
- Views never import `data/` or `core/database`; they talk to their Cubit.
- Cubits depend on use cases (and, for the app-wide settings, the settings repository), never on DAOs or the API.
- Only `data/` turns DTOs and rows into domain models.
- `core/database/` never imports `material_ui` or the JSON packages (drift exports `Table`, `Column` and `JsonKey`; conventions §11.1).
- Only Pages, `main.dart` and the app widget resolve from `getIt`; everything else gets its dependencies through its constructor.

---

## Who owns what

| Data | Source of truth | Written by | Read by |
|------|-----------------|------------|---------|
| Tasks | drift (`tasks`) | the device: add, edit, complete, delete, restore; the seed, a refresh (new tasks only) and a reset | screens, through drift streams |
| Deleted tasks | drift (`deleted_tasks`, tombstones) | a delete (and Undo, reset) | a refresh, so it never revives them |
| The demo | the fake API (`assets/json/seed_tasks.json`) | nobody: bundled | the repository, on seed, refresh and reset |
| Settings | `SharedPreferencesWithCache` | `SettingsRepository`, only the keys that changed | `SettingsCubit`, from the first frame |
| "Seeded" | `SharedPreferencesWithCache` (`tasks.seeded`) | the repository, after the seed commits | the seed |

**Screens never read the API.** The API's answers go through the mappers (which check every rule) into drift, and drift streams carry them to the screens. Offline, the screens keep working on what's stored.

---

## Data flow

**Reading:**

```
drift ──watchAll()──▶ TaskRow ──toTask()──▶ Task ──sort(compareTasks)──▶ Stream<List<Task>>
      ──▶ WatchTasksUseCase ──▶ TasksCubit ──emit(TasksState)──▶ TasksView
```

**Writing:**

```
TasksView ── checkbox ──▶ TasksCubit.toggle ──▶ SetTaskCompletedUseCase
  ──▶ TaskRepositoryImpl.setCompleted ──guardWrite──▶ TasksDao.updateTask (+ updatedAt)
  ──▶ Result: Ok, or Err(AppException) ──▶ the Cubit says why, if it failed
drift notices the write ──▶ every stream watching the task re-emits ──▶ every screen updates
```

**Seed, refresh, reset** (the only API calls):

```
FakeTaskApi.fetchTasks()  (latency; NetworkException; DataFormatException)
  ──▶ toTasks(): every record checked, duplicates refused ──▶ toRow()
  seed:    insertAll                          (one batch), then the "seeded" flag
  refresh: skip tombstones, ON CONFLICT DO NOTHING (one transaction)
  reset:   fetch first, then delete tasks and tombstones, insert (one transaction)
```

A failure at any point returns an `Err` and writes nothing.

---

## State

- **One Cubit per screen,** created by its Page (`BlocProvider(create: (_) => getIt<TasksCubit>()..load())`) and closed with it. A Cubit, not a Bloc: no flow here needs event transformers. A debounced search is where a Bloc earns its place.
- **One app-wide Cubit:** `SettingsCubit`, provided above `MaterialApp.router` in `StarterApp`, because the theme belongs to the app. A `BlocBuilder` rebuilds `MaterialApp` only when the theme's inputs change, so navigation is never reset.
- **State is one freezed value per screen,** rendered with an exhaustive `switch` on a status enum (`loading`, `ready`, `empty`, `error`, …). Derived values are getters (`TaskFormState.titleError`, `hasChanges`), so they can't disagree with the fields.
- **One-time effects** (a SnackBar, the Undo offer, closing a form, leaving after a delete) are part of the state: a message with a *serial*, or a status *transition*. The View's `BlocListener` reacts only when the serial or the status changes, so each effect fires once.
- **The View navigates; the Cubit never does.** It emits `saved` or `deleted`; the View pops or goes.

---

## Errors

- `Result<T>` is sealed: `Ok(value)` or `Err(AppException)`.
- `AppException` is sealed too, with a user-facing `message` each: `NetworkException`, `DataFormatException`, `NotFoundException`, `InvalidInputException`, `UnknownException`.
- **Repositories wrap every write in `guardWrite`:** the app's exceptions pass through, anything else (a database error) is logged and becomes `UnknownException`. Nothing throws into a Cubit.
- **Validation is shared:** `TaskRules` is used by the form (to show errors) and by `AddTaskUseCase` / `UpdateTaskUseCase` (to refuse). The database's `CHECK`s are the last guard.

---

## Navigation

Typed `go_router` routes (`go_router_builder`), in `core/navigation/app_routes.dart`:

```
StatefulShellRoute.indexedStack ── MainShell (NavigationBar)
  /tasks         the Tasks tab
  /settings      the Settings tab
root-level (above the tabs, on the root navigator):
  /tasks/new                 the form, a full-screen dialog   (declared before /:taskId)
  /tasks/:taskId             a task, pushed
  /tasks/:taskId/edit        the form over its task (a child route)
```

- **Each tab keeps its own navigator** and state (an `IndexedStack`).
- **Screens above the tabs** cover the tab bar; Back and the iOS edge swipe return to the tab as it was.
- **Links work cold:** a screen with nothing underneath gets a Close button that goes to a sensible home (`fallbackCloseButton`, conventions §11.47); a child route always has its parent underneath, so the edit form pops to its task.
- **"Page not found"** for anything else, with a way back.
- There is no first-launch gate; [TEMPLATE_USAGE](TEMPLATE_USAGE.md#6-add-what-the-template-leaves-out) shows where one goes.

---

## Dependency injection

`get_it` + `injectable`, generated into `di/injection.config.dart`:

- **Classes the app owns annotate themselves:** `@injectable` (a new one per request: Cubits, use cases), `@lazySingleton` (one per app: data sources, the ID generator), `@LazySingleton(as: Interface)` (an implementation chosen for its contract: `TaskRepositoryImpl`, `FakeTaskApi`, `MaterialYouColorSource`).
- **`AppModule` registers what the app doesn't own:** the asset bundle, the `Clock`, the database and its DAO.
- **`@preResolve`** awaits the preferences, the app's info and the wallpaper's color before `runApp`, so the first frame is already right.
- **`@factoryParam`** passes a route's id to a Cubit: `getIt<TaskDetailCubit>(param1: taskId)`.
- **Tests swap pieces** after the real graph is built (`configureTestDependencies`): an in-memory database and preferences, no latency, a fixed clock, mocked plugin channels. Everything else is the real code, so app tests also prove the graph resolves.

---

## Persistence

- **drift**, schema v1, exported to `drift_schemas/`. A change bumps `schemaVersion` and ships with `make-migrations` output and a migration test.
- **The tables enforce their rules:** a title that isn't blank, a `yyyymmdd` due day, UTC times (`GLOB '*Z'`), `updated_at` never before `created_at` (compared with `julianday`, not as text).
- **Writes that belong together share a transaction:** the seed (a batch), a refresh, a delete with its tombstone, a restore, a reset.
- **Never `INSERT OR REPLACE`** (it deletes and re-inserts), and **not `INSERT OR IGNORE`** for "add what's missing" (it silently skips rows that break a `CHECK`; conventions §11.86): `ON CONFLICT DO NOTHING`.
- **Preferences** are `SharedPreferencesWithCache`, with an allow list joined in `AppModule` (the settings' keys and the sample's).

---

## Time

- **Instants are UTC** `DateTime`s, stored as ISO-8601 text (`store_date_time_values_as_text`; conventions §11.14).
- **Due dates are days:** `CalendarDate`, an extension type over a `yyyymmdd` int. "Due Thursday" stays Thursday whatever the time zone.
- **"Now" and "today" come from the injected `Clock`**; tests fix it (`Clock.fixed`) or move it (`DataStack.now`).
- **The demo's due dates are relative** (`"dueInDays": 2`): the fake server turns them into days from today, and once stored they never move.

---

## Platform services

Anything that needs the platform sits behind an interface in `domain/service`, with its implementation in `core/platform`:
- `DynamicColorSource` → `MaterialYouColorSource` (`dynamic_color`), Android 12+ only. The app takes the wallpaper's primary tone and builds its own scheme with `AppTheme.fromSeed`, not the plugin's `ColorScheme` (it's `flutter/material.dart`'s, conventions §11.55).

Cubits and use cases never see a plugin, so their tests need no channels.

---

## Design system and accessibility

- `AppTheme.light()` / `.dark()` from one seed; `fromSeed` (dynamic color) and `fromScheme`; tokens (`AppSpacing`, `AppRadius`, `AppIconSize`).
- `AppColors`, a `ThemeExtension`, for colors that carry meaning (`overdue`, `done`), contrast-tested on every surface, in both themes, and on seven wallpaper palettes.
- Shared widgets: `LoadingView`, `EmptyStateView`, `ErrorView`, `SectionHeader`, `SegmentedChoice`, `DatePickerField` (adaptive), `showConfirmDialog` (adaptive).
- **Rules:**
  - tap targets ≥ 48 × 48, with labels;
  - never color alone ("Overdue" has an icon and the word);
  - headings as semantics headers, and a screen-reader action for anything only a swipe can do;
  - above 130 % text (`context.prefersStackedLayout`), side-by-side controls stack, and list rows keep their icons level with the title (`ListTileTitleAlignment.titleHeight`);
  - the tab labels don't scale, but a long press shows them.
- **The accessibility tour** opens every screen and state in light and dark at 200 % text and checks all of this.

---

## The sample's boundary

The Tasks sample is everything with **`task` in its file name**. Shared code reaches it in a handful of places only: the routes and the first tab, the database's table list, two lines of DI, the Settings page's data section, and the bundled asset. [TEMPLATE_USAGE](TEMPLATE_USAGE.md#remove-the-tasks-sample) lists each; removing the sample by following it leaves an app that analyzes and passes its tests (verified on a scratch copy).

---

## Key decisions

| Decision | Why |
|----------|-----|
| Drift is the single source of truth | Every screen updates from one write, and the app works offline |
| A refresh never overwrites, and tombstones remember deletions | The device owns the tasks; the Android edition's `REPLACE` lost edits and revived deletions |
| Three models per record (DTO, domain, row) | A change to the API or the table stops at a mapper |
| `Result` instead of exceptions | Failure is a value the compiler makes you handle |
| Cubits, one per screen; one app-wide for settings | The simplest state holder that fits; the theme belongs to the app |
| One-time effects as serials and transitions | A rebuild never repeats a SnackBar or a close |
| Typed routes, navigation in Views | A typo is a compile error; Cubits stay testable without a router |
| `@preResolve` for preferences, app info, colors | The first frame is already right: no flash |
| `CalendarDate` for due dates | Days don't belong to a time zone |
| The sample named `task*` | Removing it is mechanical, and checked |

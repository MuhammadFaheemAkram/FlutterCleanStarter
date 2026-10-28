# Using the Template

From clone to your own app:

1. [Clone and run](#1-clone-and-run)
2. [Rename it](#2-rename-it)
3. [Remove the Tasks sample](#remove-the-tasks-sample) (or keep it while you learn the shape)
4. [Add a feature](#4-add-a-feature), layer by layer
5. [Replace the fake API](#5-replace-the-fake-api-with-a-real-one)
6. [Add what the template leaves out](#6-add-what-the-template-leaves-out)
7. [Before you ship](#7-before-you-ship)

Steps 2 and 3 were verified on scratch copies of the repository: the renamed app analyzes, passes its tests and builds on Android and iOS; the app with the sample removed analyzes and passes its tests.

---

## 1. Clone and run

```bash
git clone https://github.com/MuhammadFaheemAkram/FlutterCleanStarter.git my_app
cd my_app
fvm install            # the Flutter version pinned in .fvmrc (3.47.6)
fvm flutter pub get
fvm flutter run
```

Generated code is committed, so it runs at once, offline, with no keys. Start your own history if you like: `rm -rf .git && git init`.

---

## 2. Rename it

```bash
fvm dart run tool/rename.dart --package my_app --app-id com.example.myapp --name "My App" --dry-run
fvm dart run tool/rename.dart --package my_app --app-id com.example.myapp --name "My App"
fvm dart fix --apply --code=directives_ordering
fvm dart format .
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter test
```

`--dry-run` lists the files it would change and writes nothing. Then the real run changes:

| What | Where |
|------|-------|
| The Dart package | `pubspec.yaml`, and every `package:` import in `lib/`, `test/` and `tool/` |
| The Android application ID and namespace | `android/app/build.gradle.kts` |
| The Kotlin package of `MainActivity` | its folder moves to match the new ID, and the old folders go |
| The iOS bundle ID (the app and its tests) | `ios/Runner.xcodeproj/project.pbxproj` |
| The display name | Android's `android:label`, iOS's `CFBundleDisplayName` and `CFBundleName`, and `MaterialApp`'s `title` |

It reads the current names from the project, so it can run again: with the same names it changes nothing, and with new ones it renames from wherever the project is now. `dart fix` (only its import-sorting fix: the others would rewrite the tests' `async {}` stubs) and `dart format` then sort the imports and rewrap the lines the new package name changed.

What it doesn't touch, on purpose:
- **Class names** (`StarterApp`): rename them in your IDE if you want to.
- **Words:** the README, the docs, the LICENSE, the seed's task titles, and test data such as the mocked app name in `test/helpers/test_dependencies.dart`.
- **The app icon and launch screen:** replace them (`flutter_launcher_icons` and `flutter_native_splash` do it in one step).

---

## Remove the Tasks sample

Every file of the sample has **`task` in its name**: that's the rule that makes this mechanical.

### 1. Delete the sample's files

Delete every file and folder whose name contains `task` under `lib/`, `test/` and `assets/`, then the folders left empty (`assets/`, `lib/features/settings/widgets/`, …):

```bash
find lib test assets -iname '*task*' -prune -exec rm -rf {} +
find lib test assets -type d -empty -delete
```

That is:
- `lib/features/{tasks,task_detail,task_form}/`, `lib/features/settings/cubit/tasks_demo_*`, `lib/features/settings/widgets/tasks_demo_section.dart`;
- `lib/core/network/{task_api,fake_task_api}.dart`, `lib/core/network/dto/task_dto*`, `lib/core/database/tables/tasks.dart`, `lib/core/database/daos/tasks_dao*`, `lib/core/storage/tasks_preferences.dart`;
- `lib/data/mapper/task_mappers.dart`, `lib/data/repository/task_repository_impl.dart`;
- `lib/domain/model/task*`, `lib/domain/calculation/task_rules.dart`, `lib/domain/repository/task_repository.dart`, `lib/domain/usecase/task_use_cases.dart`;
- `assets/json/seed_tasks.json`;
- their tests, and the sample's test helpers (`task_fixtures.dart`, `tasks_data_stack.dart`, `fakes/scripted_task_*.dart`).

Also delete `drift_schemas/`: it holds the sample's schema, and your app hasn't shipped one yet.

### 2. Give the shell a first tab

The tab bar needs two tabs; the sample's was the first. Create `lib/features/home/home_page.dart`:

```dart
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The first tab: replace it with your first feature.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const EmptyStateView(
        icon: Icons.home_outlined,
        title: 'Home',
        message: 'Your first feature goes here.',
      ),
    );
  }
}
```

Then:
- **`lib/core/navigation/app_routes.dart`:**
  - import `features/home/home_page.dart` instead of the three task pages;
  - `TasksBranch` → `HomeBranch` (`debugLabel: 'homeTab'`), and `TypedGoRoute<TasksRoute>(path: '/tasks')` → `TypedGoRoute<HomeRoute>(path: '/home')`;
  - `TasksRoute` → `HomeRoute`, building `const HomePage()`;
  - delete section **2. Root-level screens** (`NewTaskRoute`, `TaskDetailRoute`, `EditTaskRoute`) to the end of the file.
- **`lib/core/navigation/app_router.dart`:** `TasksRoute` → `HomeRoute` (twice), and `'Go to Tasks'` → `'Go to Home'`.
- **`lib/features/shell/main_shell.dart`:** in `AppTab`, `tasks('Tasks', Icons.checklist_outlined, Icons.checklist)` → `home('Home', Icons.home_outlined, Icons.home)`.

### 3. Settings without the sample's section

In **`lib/features/settings/settings_page.dart`**, `SettingsPage.build` becomes:

```dart
  @override
  Widget build(BuildContext context) {
    return SettingsView(appInfo: getIt<AppInfo>());
  }
```

and the imports of `tasks_demo_cubit.dart` and `tasks_demo_section.dart` go.

### 4. The database, DI and the bundle

- **`lib/core/database/app_database.dart`:** `@DriftDatabase(tables: [Tasks, DeletedTasks], daos: [TasksDao])` → `@DriftDatabase()`, and the two task imports go. (An app with no table yet still has a working database: add your first table here.)
- **`lib/di/app_module.dart`:** delete the `tasksDao` registration and `...TasksPreferences.allowList`, and their imports.
- **`pubspec.yaml`:** delete the `assets:` entry (`- assets/json/`), or point it at your own assets.

### 5. Regenerate and check

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm dart run drift_dev make-migrations     # exports your schema v1
fvm dart format .
fvm flutter analyze
fvm flutter test
```

What's left: the shell, Settings (appearance, dynamic color, About), the design system, typed routes, DI, the fake network pieces (`AssetJsonLoader`, `NetworkSimulator`), drift, preferences, `Result` / `AppException` / `guardWrite` / `IdGenerator`, `tool/rename.dart`, and their tests. The tests of the shell and Settings don't name the sample: they read the tabs from `AppTab`.

---

## 4. Add a feature

The sample is the template for the template: copy its shape one layer at a time. Say the feature is **notes**:

| Step | File | Copy from |
|------|------|-----------|
| 1. The model (pure Dart, freezed) | `lib/domain/model/note.dart` | `task.dart` |
| 2. Its rules (pure functions) | `lib/domain/calculation/note_rules.dart` | `task_rules.dart` |
| 3. The table, with `CHECK`s | `lib/core/database/tables/notes.dart` | `tables/tasks.dart` |
| 4. The DAO (queries, transactions) | `lib/core/database/daos/notes_dao.dart` | `daos/tasks_dao.dart` |
| 5. List both in `@DriftDatabase`; register the DAO in `AppModule`; bump `schemaVersion` and run `make-migrations` once you've shipped | `app_database.dart`, `app_module.dart` | |
| 6. The API and its DTO (if a server is involved) | `lib/core/network/note_api.dart`, `dto/note_dto.dart` | `task_api.dart`, `task_dto.dart` |
| 7. Mappers (DTO → model ↔ row), validating | `lib/data/mapper/note_mappers.dart` | `task_mappers.dart` |
| 8. The repository contract and its implementation | `domain/repository/note_repository.dart`, `data/repository/note_repository_impl.dart` | `task_repository*.dart` |
| 9. Use cases, one per action | `lib/domain/usecase/note_use_cases.dart` | `task_use_cases.dart` |
| 10. A Cubit and its freezed state per screen | `lib/features/notes/cubit/` | `features/tasks/cubit/` |
| 11. A Page (provides the Cubit) and a View (renders it) | `lib/features/notes/notes_page.dart` | `tasks_page.dart` |
| 12. Routes (a tab is a branch plus an `AppTab`; a pushed screen a top-level route) | `app_routes.dart`, `main_shell.dart` | the task routes |
| 13. Tests at every layer, and tour stops | `test/…` mirroring `lib/` | the sample's tests |

Then `fvm dart run build_runner build --delete-conflicting-outputs`, and add the new Cubits and repositories to an injection test, so a missing registration fails in CI rather than at runtime.

Conventions worth keeping:
- **Reads are drift streams;** the screen watches them, so every write shows everywhere.
- **Writes go through `guardWrite`** and return a `Result`; the Cubit shows the `Err`'s message.
- **One-time effects** are a serial or a status transition in the state, shown by a `BlocListener`; navigation stays in the View.
- **A Cubit gets its id through `@factoryParam`** (`getIt<NoteCubit>(param1: id)`).
- **A screen with a FAB in a tab** gets its own `ScaffoldMessenger` (conventions §11.87).

---

## 5. Replace the fake API with a real one

Everything above the data layer depends on `TaskApi`, not on the fake:

```dart
@LazySingleton(as: TaskApi)
class HttpTaskApi implements TaskApi {
  HttpTaskApi(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskDto>> fetchTasks() async {
    try {
      final response = await _dio.get<List<Object?>>('/tasks');
      return [
        for (final json in response.data!)
          TaskDto.fromJson(json! as Map<String, dynamic>),
      ];
    } on DioException {
      throw const NetworkException();
    } on CheckedFromJsonException {
      throw const DataFormatException();
    }
  }
}
```

Register `Dio` in `AppModule` (with its base URL and interceptors), remove `@LazySingleton(as: TaskApi)` from `FakeTaskApi` (or keep it for tests under an `@Environment`), and nothing else changes: the mappers still check every answer, and the repository still decides what's written. Keep `ScriptedTaskApi` for tests.

A real server usually also wants the device's changes: add a pending-changes table, written in the same transaction as each local edit, and a sync that sends them. The template leaves that out on purpose: it depends on your server's API.

---

## 6. Add what the template leaves out

Each of these is per-app, and each has a sibling BitFuse project that shows it:

| Need | Where it goes | See |
|------|---------------|-----|
| A first-launch / onboarding gate | a `redirect` in `createAppRouter`, reading a preference, with a `refreshListenable` | DevJourney, Evently (`firstLaunchRedirect`) |
| Sign-in and a session | an `AuthBloc` above the router, the redirect reading it, tokens in `flutter_secure_storage` | ConnectHub |
| Local notifications | a `NotificationScheduler` interface in `domain/service`, a pure planner, a diffing sync | Momentum, Evently |
| Background work | `workmanager`, a hand-built background graph, drift shared across isolates | Momentum, Evently |
| Search with a debounce | a Bloc with a `restartable` transformer | ConnectHub, DevJourney, Evently |
| Charts, CSV export | `fl_chart`, `share_plus` | SpendWise |
| Flavors (dev / staging / prod) | `--dart-define-from-file`, an `@Environment` per flavor in `injectable` | the [roadmap](ROADMAP.md) |
| Localization | `intl` + ARB files, `flutter gen-l10n` | the [roadmap](ROADMAP.md) |

---

## 7. Before you ship

- [ ] Your own app icon and launch screen.
- [ ] Release signing: the template's Android release build uses the **debug** keys (see `android/app/build.gradle.kts`); add your keystore. iOS: your team and provisioning in Xcode.
- [ ] **Launch a release build once** (`fvm flutter run --release`): resource shrinking and tree shaking happen only there (conventions §11.85).
- [ ] The README, LICENSE and SECURITY policy are yours, not the template's.
- [ ] The accessibility tour covers every screen and state you added.
- [ ] A privacy policy, if your app collects anything.

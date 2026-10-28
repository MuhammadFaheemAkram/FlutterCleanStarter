# Phase 2 — Core Data Layer + Repositories

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 2, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 2 builds everything below the screens, so the screens in Phases 3–5 only have to show it:
- **the domain:** the `Task` model, due dates as calendar days, the validation rules, the list's order, and one use case per user action;
- **the store:** drift with a `tasks` table and `deleted_tasks` tombstones, whose `CHECK`s refuse bad rows;
- **the fake server:** bundled JSON behind a `TaskApi` interface, with a simulated delay and failure;
- **the repositories:** seed once, refresh by merging, add, edit, toggle, delete with Undo, reset; and the settings, loaded before the first frame.

The data layer is complete and tested, but no screen uses it yet: the app still shows its placeholders.

---

## 🧱 What Was Implemented

- **Common (`core/common`):**
  - `Result` (`Ok` / `Err`) and a sealed `AppException`: network, damaged data, not found, invalid input, unknown;
  - `guardWrite`, which turns any failure into an `Err` (the app's exceptions pass through, anything else is logged and becomes "Something went wrong");
  - `IdGenerator`: random version 4 UUIDs, so tasks can be created offline.
- **Domain (`domain/`, pure Dart):**
  - `CalendarDate`, an extension type over a `yyyymmdd` int: a due date is a day, not an instant;
  - `Task` and `TaskDraft` (freezed), `AppSettings` with `AppThemeMode`;
  - `TaskRules`: a title is required and at most 80 characters, notes at most 1000, both counted as grapheme clusters; `isOverdue` (not done, and due before today); `compareTasks` (open first, soonest due, no date last, newest first);
  - the `TaskRepository` and `SettingsRepository` contracts;
  - the use cases: Watch tasks / one task, Seed, Refresh, Add, Update, Set completed, Delete, Restore, Reset demo data; Watch settings, Update theme mode, Update dynamic color. Add and Update check `TaskRules` before they write.
- **Network (`core/network`):**
  - `TaskApi` and `FakeTaskApi`, which reads `assets/json/seed_tasks.json` after `NetworkSimulator`'s 600 ms;
  - the seed: the iOS edition's five tasks, the welcome one naming this template, and due dates **relative to today** (`"dueInDays"`), so the demo has one task due soon and one overdue;
  - `NetworkSimulator`: the delay, `failRequests` for tests, and `shouldThrowError` as a developer switch;
  - `TaskDto` (json_serializable, `checked: true`). Anything damaged becomes a `DataFormatException`.
- **Database (`core/database`), drift schema v1:**
  - `tasks`, with these `CHECK`s:
    - a title that isn't blank;
    - a due day that looks like `yyyymmdd`;
    - UTC times;
    - `updated_at` never before `created_at`, compared with `julianday`, not as text;
  - `deleted_tasks`: the tombstones;
  - `TasksDao`: seed, merge, delete with tombstone, restore and reset, each in one transaction;
  - `PRAGMA foreign_keys = ON`, and the schema exported to `drift_schemas/`.
- **Mappers (`data/mapper`):** `TaskDto → Task` checks every rule (and duplicate ids) before anything is written; `Task ↔ TaskRow` round-trips exactly.
- **Storage (`core/storage`):** `SettingsLocalDataSource` (the settings' keys) and `TasksPreferences` (the sample's `tasks.seeded` flag, kept apart so removing the sample removes it).
- **Repositories (`data/repository`):**
  - `TaskRepositoryImpl`. `seedIfNeeded` runs once: two calls at once share one seed, and the flag is written only after the seed's transaction commits. The other writes:
    - `refresh` merges the server's tasks;
    - `update` and `setCompleted` write a new `updatedAt` and never `createdAt`;
    - `delete` returns the task for Undo, and `restore` puts it back exactly;
    - `resetDemoData` fetches first, so offline nothing is deleted.
  - `SettingsRepositoryImpl`: the current settings in memory, published to watchers at once, and only changed keys written.
- **DI:**
  - `AppModule` registers the asset bundle, the `Clock`, the database and its DAO, and `SharedPreferencesWithCache` with `@preResolve`;
  - `configureDependencies()` is now async, and `main` awaits it.
- **Tests:** 169 (120 new), and 22 mutation checks.

### Differences from the plan

- **`ON CONFLICT DO NOTHING`, not `INSERT OR IGNORE`.** The spec says "insert-or-ignore by id". A test found that SQLite's `OR IGNORE` also skips a row breaking a `CHECK`, silently. The merge now skips only an id that's already there; a damaged row throws and rolls the refresh back. Recorded as conventions trap §11.86.
- **`characters` arrives now, not in Phase 4:** the use cases validate titles in this phase.
- **`intl` waits for Phase 3,** where dates are first formatted.
- **`TasksPreferences` is its own class,** not a key in `SettingsLocalDataSource`, so the sample can be removed without editing the settings. `AppModule` joins the two allow lists.
- **The order lives in Dart (`compareTasks`), not SQL:** one pure function, unit-tested, applied to the stream.
- **A task with no flag but rows already stored** (the flag's write was lost after the seed committed) gets the flag and no second seed.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Extension types:** `CalendarDate` is an `int` at runtime and a checked type at compile time; its private constructor forces every value through a factory that validates it.
- **Sealed classes:** `Result` and `AppException`; an exhaustive `switch` can't forget the error case.
- **Primary constructors (Dart 3.13):** `final class const Ok<T>(final T value) extends Result<T>;`.
- **freezed** for value equality and `copyWith`; **json_serializable `checked`** for errors that name the field.
- **drift:**
  - tables with `customConstraints`;
  - a DAO with transactions and batches;
  - `insertReturningOrNull(onConflict: DoNothing())`, which answers `null` for a skipped row;
  - streams that re-emit on every write;
  - DateTimes stored as UTC ISO-8601 text;
  - `make-migrations` for schema export.
- **`@preResolve`:** an async dependency (the preferences) awaited before `runApp`, then read synchronously.
- **`@LazySingleton(as: Interface)`:** the implementation is chosen in one place, and use cases depend on the interface.
- **An injectable `Clock`:** every "now" and "today" can be fixed or moved in a test.
- **Grapheme clusters (`characters`):** "👩‍💻" is one character, though `String.length` says 5.
- **Sharing an in-flight future** (`_seeding ??= …`) so concurrent callers get one operation.

---

## 🔁 Data Flow (this phase)

```
first launch ─▶ SeedTasksUseCase ─▶ TaskRepositoryImpl.seedIfNeeded()
                  seeded flag set? ── yes ─▶ Ok(0)
                  tasks stored?    ── yes ─▶ set the flag, Ok(0)
                  FakeTaskApi.fetchTasks()   (600 ms; dueInDays → a day from today)
                    ├─ NetworkException / DataFormatException ─▶ Err, nothing written
                    └─ TaskDto ─toTask()─▶ Task ─toRow()─▶ TaskRow
                         TasksDao.insertAll (one batch) ─▶ set the flag ─▶ Ok(5)

refresh ─▶ fetch ─▶ TasksDao.mergeServerTasks (one transaction)
             skip tombstoned ids · INSERT … ON CONFLICT DO NOTHING ─▶ Ok(added)

delete ─▶ TasksDao.deleteWithTombstone (one transaction) ─▶ Ok(task)  ── Undo ─▶ restore
reset  ─▶ fetch first ─▶ TasksDao.replaceAll (tasks + tombstones cleared, rows written)

drift ─▶ watchAll() ─▶ rows ─toTask()─▶ sort(compareTasks) ─▶ Stream<List<Task>>
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/core/common/{result,app_exception,guard_write,id_generator}.dart` | Errors as values, the write guard, ids. |
| `lib/domain/model/{calendar_date,task,app_settings}.dart` | The domain models. |
| `lib/domain/calculation/task_rules.dart` | Validation, overdue, the order. |
| `lib/domain/repository/*.dart`, `lib/domain/usecase/*.dart` | The contracts and the use cases. |
| `lib/core/network/{task_api,fake_task_api,network_simulator,asset_json_loader}.dart`, `dto/task_dto.dart` | The fake server. |
| `assets/json/seed_tasks.json` | The demo's five tasks. |
| `lib/core/database/{app_database,tables/tasks,daos/tasks_dao}.dart` | drift v1. |
| `drift_schemas/app_database/drift_schema_v1.json` | The exported schema. |
| `lib/core/storage/{settings_local_data_source,tasks_preferences}.dart` | Preferences. |
| `lib/data/mapper/task_mappers.dart`, `lib/data/repository/*.dart` | Mappers and repositories. |
| `lib/di/app_module.dart` | Third-party registrations and `@preResolve`. |
| `test/helpers/{data_stack,test_dependencies,database,result_matchers,task_fixtures}.dart`, `test/helpers/fakes/*` | The test infrastructure. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `Result`, `Ok`, `Err` | sealed class | An outcome that can fail | `core/common`: every layer uses it |
| `AppException` (+ 5 cases) | sealed class | Failures the UI can show | `core/common` |
| `CalendarDate` | extension type | A day with no time or zone | `domain/model` |
| `Task`, `TaskDraft`, `AppSettings` | freezed | The domain models | `domain/model` |
| `TaskRules`, `isOverdue`, `compareTasks` | pure functions | The sample's rules | `domain/calculation`: one-line tests |
| `TaskRepository`, `SettingsRepository` | interfaces | The contracts | `domain/repository` |
| `TaskApi`, `FakeTaskApi`, `TaskDto` | interface / class / DTO | The server | `core/network` |
| `AppDatabase`, `TasksDao`, `TaskRow` | drift | The store | `core/database` |
| `TaskRepositoryImpl`, `SettingsRepositoryImpl` | classes | The implementations | `data/repository` |
| `AppModule` | injectable module | Types the app doesn't own | `di/` |

---

## 🌱 Folder Structure Changes

- **New:** `lib/core/{common,network,network/dto,database,database/tables,database/daos,storage}`, `lib/data/{mapper,repository}`, `lib/domain/{model,calculation,repository,usecase}`, `assets/json/`, `drift_schemas/`; in `test/`, the mirrors of these plus `test/helpers/fakes/`.
- `domain/service/` (dynamic color) and `tool/` come later.

---

## 🧪 Tests (169; 120 new)

| Area | Tests | What they pin |
|------|------:|---------------|
| Repositories | 36 | Seeding once (two calls, offline, damaged data, a lost flag, everything deleted); a refresh that adds, never overwrites, never revives; add, update (never `createdAt`), toggle, not found; delete and an exact Undo; reset (offline and damaged leave everything); the stream's order; settings defaults, unknown values, only changed keys written |
| Database | 24 | Every `CHECK` (blank titles, bad days, local times, an update before the creation, compared as times); one transaction for each of seed, merge and reset; merge skips tombstones and refuses damaged rows; delete and restore; the exported schema |
| Domain | 27 | `CalendarDate`; titles and notes at their limits, in grapheme clusters; overdue at its edges; the order; the use cases refusing invalid input |
| Network and mappers | 26 | The bundled seed decodes and maps; relative dates; latency in fake time; failures; six kinds of damaged JSON; every mapping rule; a lossless row round trip |
| Common and DI | 8 | `guardWrite`, UUIDs, the real container resolving everything with settings preloaded |

**Mutation checks (22), each caught by the whole suite:**
- the merge as `REPLACE`, as `INSERT OR IGNORE`, ignoring tombstones;
- delete without a tombstone, restore keeping it, reset keeping them;
- the seed ignoring its flag, the flag set before the insert, two seeds at once;
- `update` writing `createdAt`, a write keeping `updatedAt`, an update of a missing task answering Ok;
- reset deleting before it fetches;
- overdue including today, no due date first, the oldest first, titles counted in code units, a blank title accepted;
- the mapper accepting an update before the creation or duplicate ids;
- settings writing every key; Add skipping validation.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Models | domain model, DTO, Room entity, mappers | DTO (`Codable`), `@Model`, domain struct, mappers | `TaskDto` (checked JSON), `Task` (freezed), `TaskRow` (drift), mapper extensions that validate |
| Store | Room + `TaskDao` | SwiftData `ModelContainer` | drift v1 with `CHECK`s and tombstones, schema exported |
| Fake API | `TaskApiService` + demo data | `FakeTaskService` + bundled JSON | `FakeTaskApi` + bundled JSON with relative due dates, `NetworkSimulator` |
| Repository | interface + implementation | `TaskRepositoryImpl` + `seedIfNeeded` | the same, plus refresh by merge, delete with tombstone and Undo, reset; every write a `Result` |
| Settings | in Phase 5 (DataStore) | `SettingsStore` + repository | `SettingsLocalDataSource` + repository, `@preResolve` |
| Use cases | Phase 3 | use case types | all of them, Add and Update validating |
| DI | Hilt modules | DI wiring | `AppModule` + annotations; async `configureDependencies` |
| Tests | DAO tests | store tests | every layer: domain, DAO and `CHECK`s, network, mappers, repositories, use cases, DI; 22 mutation checks |

The iOS plan is the closer match (settings and use cases in this phase). Neither native spec says what a refresh does to a task the user edited or deleted. The Android edition's `REPLACE` would overwrite the first and bring back the second, so the Flutter edition merges, and has the tests to prove it.

---

## 🎤 Interview Notes

**Q: Why tombstones?**
A: The server keeps listing the demo tasks. Without a record that the user deleted one, the next refresh would see it missing and add it back. The tombstone is written in the same transaction as the delete, and Undo removes it in the same transaction as the restore.

**Q: Why not `INSERT OR IGNORE` for the merge?**
A: It ignores more than the id clash: a row that breaks a `CHECK` is skipped silently too. `ON CONFLICT (id) DO NOTHING` skips only the clash, so a damaged row still fails the transaction. A test caught the difference.

**Q: Why is a due date an `int`?**
A: "Due Thursday" is a day, not a moment. A `DateTime` belongs to a time zone and can slip to Wednesday after a flight west. A `yyyymmdd` int has no zone, sorts like the dates, and is cheap: the extension type gives it a real API at no runtime cost.

**Q: How do you make sure the seed runs exactly once?**
A: A flag written only after the seed's transaction commits, a check for rows already stored (in case the flag's write was lost), and one shared future while a seed is running. Each of these has a test, and a mutation that breaks each one fails it.

**Q: Why does `update` ignore the task's `createdAt`?**
A: The creation time is a fact about the record, not something an edit can change. The repository writes only the editable fields and a new `updatedAt`, so a caller passing a stale or wrong `createdAt` can't corrupt it.

---

## 📝 Learning Checklist

- ✅ Model errors as values with sealed classes
- ✅ Keep DTO, domain and row models apart, and validate at the mapper
- ✅ Store days as days, and instants as UTC
- ✅ Let the database enforce its own rules with `CHECK`s
- ✅ Merge server data without losing local edits or reviving deletions
- ✅ Group writes in transactions, and prove it with failing rows
- ✅ Load preferences before the first frame with `@preResolve`
- ✅ Test on a real data stack instead of mocks, and break the rules on purpose
- ⬜ The Tasks list (Phase 3)

---

## 🚀 Future Improvements

- **Phase 3:** `TasksCubit` and the Tasks screen: the seed on first launch, the list, toggle, swipe to delete with Undo, pull to refresh, loading, empty and error.
- **Later:** a real `TaskApi` with `dio`; syncing local edits back to a server (a pending-changes table) is a per-app choice the template leaves out.

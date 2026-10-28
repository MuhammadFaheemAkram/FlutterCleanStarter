# Learning Notes

What this template teaches, and the lessons its build turned up. Each phase's own write-up is in `docs/PHASE_*_SUMMARY.md`.

---

## 1. A template is code that gets copied

A bug in an app affects that app. A bug in a template affects every app built from it. So the template is held to two promises more than an app is, and both are tested rather than described:
- **It can be renamed:** `tool/rename.dart` rewrites the package, the app IDs and the display name, and a scratch copy renamed with it analyzes, passes its tests and builds on both platforms.
- **Its sample can be removed:** everything of the sample has `task` in its name, the shared code reaches it in a few listed places, and a scratch copy with it removed still passes.

The removal check found two things no app test could: a database with no tables makes drift's generated code warn (so `build.yaml` now ignores `unused_field` in generated parts), and several shared tests named the sample (so they now read the tabs from `AppTab`).

---

## 2. Offline-first, the simple way

- **One source of truth:** the screens watch drift; the API only fills it.
- **The device owns its data:** a refresh *adds* what the server has new and never overwrites. The Android edition refreshed with `REPLACE`, which threw away edits and brought deleted tasks back.
- **Tombstones remember deletions,** in the same transaction as the delete.
- **Fetch before you delete:** Reset demo data asks the server first, so offline nothing is lost.

## 3. SQL has sharp edges

- `INSERT OR REPLACE` deletes and re-inserts (cascades fire, the row is new).
- `INSERT OR IGNORE` ignores *every* conflict, including a `CHECK` failure: a damaged row vanishes silently. `ON CONFLICT (id) DO NOTHING` skips only the clash (conventions §11.86, found by a test).
- ISO text times compare as text only if they have the same number of fraction digits: `…00.000Z` sorts after `…00.000500Z`. Compare with `julianday`.

## 4. Times and days are different things

- An instant ("created at 09:00 UTC") is a `DateTime` in UTC.
- A day ("due Thursday") is a `CalendarDate`, an extension type over a `yyyymmdd` int: no time, no zone, sorts like the dates, costs nothing at runtime.
- "Now" is injected (`Clock`), so tests can fix it and move it.
- Relative seed dates (`"dueInDays": 2`) keep a demo fresh; once stored, they never move (Evently's lesson, conventions §11.83).

## 5. State, effects and timing

- **Effects as state:** a serial for a SnackBar, a status transition for "saved", so a rebuild never repeats one.
- **Decide after the store has caught up:** a seed answers before drift reports its rows; reading the store once more avoids a flash of "No tasks yet" (§11.32, §11.33).
- **Optimistic removal for `Dismissible`:** the swiped row leaves the state at once, and comes back if the delete fails (§11.13). Undo shows it again at once too: a mutation check found it waiting for drift.
- **Read state at the moment of action:** the form's Close used the state captured at the last build, and a fast tap after typing skipped "Discard changes?". `context.read<Cubit>().state` in the callback fixed it.

## 6. Layout lessons from a device

- **In a tab shell, SnackBars cover the tab screen's FAB:** the shell's outer Scaffold shows them, and it knows nothing of the inner FAB. A `ScaffoldMessenger` per tab screen puts them above it (conventions §11.87, found on the simulator).
- **At large text, an icon beside wrapped text looks detached:** size it with `MediaQuery.textScalerOf` and align it to the first line.
- **Segments don't fit at 200 % text:** switch to a radio list (`prefersStackedLayout`).

## 7. Tests that can fail

- **A real data stack beats mocks** for Cubits and repositories: the timing bugs above only appear against a real store.
- **Make timing deterministic:** a repository wrapper whose delete answers without touching the store turned two "passing by luck" tests into real ones.
- **Mutation checks:** break a rule on purpose and run the whole suite. Over the six phases they found weak tests, an unreachable branch (the edit form's "go to the task" fallback), and gaps (dynamic color in dark mode).
- **The accessibility tour** checks every screen and state at 200 % text, in both themes; it found nothing to fix in Flutter's own date picker except a 47.7 px day cell, which is documented rather than hidden.

## 8. The template's shape, in one line each

- Page creates, View renders, Cubit decides, use case acts, repository stores, mapper checks.
- `Result` for every write; `guardWrite` around every one.
- Typed routes; navigation in Views; Close for links opened cold.
- `@preResolve` for anything the first frame needs.
- Anything platform-shaped behind a `domain/service` interface.

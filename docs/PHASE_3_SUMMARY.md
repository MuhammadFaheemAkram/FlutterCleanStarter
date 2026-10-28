# Phase 3 — The Tasks List

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 3, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 3 puts the first real screen on the data layer. The Tasks tab:
- seeds the demo on first launch (with a loading state, and an error with Try again when offline);
- lists the tasks in order, with what's overdue, due, or done;
- lets you tick a task off, swipe it away (with Undo), and pull to refresh;
- shows each state the template's screens need: loading, empty, error, ready.

It is the template's example of the whole stack in one screen: **View → Cubit → use cases → repository → drift**, with one-time effects and no navigation in the Cubit.

---

## 🧱 What Was Implemented

- **`TasksCubit`** (`features/tasks/cubit`):
  - watches the stored tasks, and seeds on first launch;
  - holds the loading state until the seed has answered *and* the store has been read again;
  - the error state (a failed first seed with nothing stored) and Try again;
  - refresh, with a message for each outcome: "1 new task from the server.", "You're up to date.", or why it failed offline;
  - toggle (done tasks move down the list, because drift re-emits);
  - delete: the row leaves the list at once and the SnackBar offers Undo. A failed delete puts the row back and says why. Undo shows the row again at once.
- **`TasksState`** (freezed): the status, the tasks, today, the error message, and two one-time effects with serials (`message` / `messageSerial`, `undoable` / `undoSerial`).
- **`TasksView`:**
  - `LoadingView`; `ErrorView` with Try again; `EmptyStateView` ("No tasks yet", with Add task);
  - the list under `RefreshIndicator.adaptive`, each card in a `Dismissible` (end-to-start, a red "Delete" background);
  - tap → `TaskDetailRoute`, and the FAB → `NewTaskRoute`. The FAB is hidden while loading and in the error state, so the first seed comes first.
  - its own `ScaffoldMessenger`, so SnackBars sit above the FAB (below).
- **`TaskCard`:**
  - a checkbox labelled for screen readers ("Done: Call Sam");
  - the title, struck through when done, and the first line of the notes;
  - the status: "Overdue · due yesterday" (an icon and words in the overdue color), "Due Fri 30 Oct", or "Done" (in the done color);
  - the created date;
  - a **Delete custom semantics action**, because a swipe can't be done with a screen reader.
  - At large text the status icon grows with the text and stays on its first line.
- **`date_labels.dart`** (design system): `dayLabel` ("today", "tomorrow", "yesterday", "Thu 29 Oct", with the year only when it differs) and `shortDate` ("20 Jul").
- **Tests:** 228 (59 new), and 18 mutation checks.

### Differences from the plan

- **The SnackBar covered the Add button** on the simulator. The tab shell's outer `Scaffold` shows the app's SnackBars, and it knows nothing of the tab screen's FAB. The Tasks screen now has its own `ScaffoldMessenger`. An app-level test checks the SnackBar's bottom is above the FAB's top, and fails without the fix. Recorded as conventions trap §11.87.
- **Two state fields the spec's sketch didn't have:** `errorMessage` (why the first seed failed) and `undoSerial` (the Undo offer is its own one-time effect, separate from messages).
- **The FAB is hidden in the error state:** a task added before the first seed would count as "already seeded", and the demo would never arrive.
- **Refresh reports success too** ("You're up to date.", "1 new task from the server."), not only failures. A pull with no visible change otherwise looks broken.
- **The status icon scales with the text,** after a large-text check on the simulator showed a small icon centred beside three lines of text.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **Page / View split:** the Page creates the Cubit from DI (`BlocProvider(create: …..load())`); the View only renders. View tests pump it with a `MockCubit` in any state.
- **One-time effects as serials:** `BlocListener` with `listenWhen: previous.serial != current.serial`. A rebuild for another reason never shows a SnackBar twice.
- **Optimistic removal for `Dismissible`:** a swiped row must leave the tree in the same frame (conventions §11.13), so the Cubit hides it before the database answers, and shows it again if the delete fails.
- **Deciding after the store has caught up:** a seed can answer before drift's stream reports its rows. The Cubit reads the store once more before leaving the loading state, so there's no "No tasks yet" flash (§11.32, §11.33).
- **Patterns on a list:** `switch (visible) { _ when _seeding => …, null => …, [_, ...] => …, [] when … }`.
- **`RefreshIndicator.adaptive`** with `AlwaysScrollableScrollPhysics`, so a short list can still be pulled.
- **Accessibility:**
  - `CustomSemanticsAction` for the swipe;
  - a labelled `Checkbox`;
  - never color alone (an icon *and* a word);
  - `MediaQuery.textScalerOf` to size an icon to the text.
- **`intl`'s `DateFormat`** for "Thu 29 Oct".
- **Nested Scaffolds and `ScaffoldMessenger`:** which Scaffold shows a SnackBar decides what it can overlap.

---

## 🔁 Data Flow (this phase)

```
TasksPage ─▶ getIt<TasksCubit>()..load()
  load: watchTasks().listen(_stored = …)  ─┐
        seedIfNeeded()  (loading)          │ drift
        then read the store again ─────────┘
        ─▶ ready / empty / error (Try again ─▶ seed again)

checkbox ─▶ toggle ─▶ setCompleted ─▶ drift ─▶ the list re-sorts
swipe    ─▶ delete: hide at once ─▶ delete + tombstone ─▶ undoable, undoSerial+1
             └─ View: "Task deleted · Undo" ─▶ undo: show at once ─▶ restore
pull     ─▶ refresh ─▶ merge ─▶ message, messageSerial+1 ─▶ SnackBar
tap      ─▶ View: TaskDetailRoute(taskId).push   (never the Cubit)
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/features/tasks/cubit/{tasks_cubit,tasks_state}.dart` | The screen's logic and state. |
| `lib/features/tasks/tasks_page.dart` | The Page and the View. |
| `lib/features/tasks/widgets/task_card.dart` | One task in the list. |
| `lib/core/design_system/date_labels.dart` | How the app writes a day. |
| `test/features/tasks/**`, `test/app/tasks_flow_test.dart` | The Cubit, the view, the card, the flows. |
| `test/helpers/wait_for.dart` | Await a Cubit's state, with a timeout. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `TasksCubit` | Cubit (`@injectable`) | Seed, watch, refresh, toggle, delete and Undo | `features/tasks/cubit`: belongs to its screen |
| `TasksState`, `TasksStatus` | freezed / enum | What the screen draws | `features/tasks/cubit` |
| `TasksPage`, `TasksView` | widgets | Create the Cubit; render the state | `features/tasks` |
| `TaskCard` | widget | One task | `features/tasks/widgets`: the sample's own widget |
| `dayLabel`, `shortDate` | functions | Dates as words | `core/design_system`: any feature can use them |

---

## 🌱 Folder Structure Changes

- **New:** `lib/features/tasks/{cubit,widgets}/`; `test/features/tasks/{cubit,widgets}/`.
- The Tasks placeholder became the real screen; the other placeholders are unchanged.

---

## 🧪 Tests (228; 59 new)

| Area | New | What they pin |
|------|----:|---------------|
| `TasksCubit` (real data stack) | 17 | Loading until the seed and the store agree; error and Try again; empty vs error; refresh messages; toggle re-sorts; delete at once; Undo, also before drift reports the delete; a failed delete; changes from elsewhere |
| `TaskCard` | 11 | Notes excerpt, due, overdue in both themes, done, taps, the checkbox's label, the Delete action, the icon at large text |
| `TasksView` (`MockCubit`) | 10 | Every state, the FAB's rule, swipe direction, pull to refresh, the Undo and message SnackBars once |
| App flows | 10 | First launch seeds; offline then Try again; empty then Add; toggle saved; swipe and Undo; a deleted task stays deleted after a refresh; offline refresh; open a task and back; the tab keeps its list; the SnackBar above the FAB |
| Accessibility tour | 6 | Tasks with the demo, empty, offline, and the Undo SnackBar, light and dark |
| Date labels | 5 | today / tomorrow / yesterday, this year, another year |

The app harness now waits out loading screens frame by frame (a spinner never lets `pumpAndSettle` finish). `pumpStarter` starts with the demo stored, or empty, or offline.

**Mutation checks (18), each caught by the whole suite:**
- no read after the seed;
- delete not optimistic;
- a failed delete left hidden;
- Undo left hidden;
- the seed's error shown as empty;
- loading not held during the seed;
- an offline refresh, or a failed toggle, left silent;
- the FAB shown while offline;
- the message or Undo SnackBar shown on every rebuild;
- swiping both ways;
- no screen-reader Delete;
- done not struck through;
- overdue not marked;
- SnackBars in the shell's Scaffold;
- the status icon centred, or a fixed size.

At first, the tests missed two of these (a failed delete, and Undo) because drift's own stream hid the bug. A repository wrapper whose delete answers without touching the store made them deterministic, and found that **Undo didn't republish**: the restored row stayed hidden until drift happened to emit again. Fixed.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Screen logic | `TasksViewModel` + `TasksUiState` | `TasksViewModel` + `TasksState` | `TasksCubit` + `TasksState` (freezed) |
| Use cases | Observe, Refresh, Toggle, Delete | (from Phase 2) | Watch, Seed, Refresh, SetCompleted, Delete, Restore |
| Seed | — | seeds on first launch | seeds once, with loading, error and Try again |
| Delete | a delete option on the card | swipe to delete | swipe with Undo, plus a screen-reader Delete action (the detail screen's confirmed Delete comes in Phase 4) |
| Refresh | "if practical" | pull to refresh | `RefreshIndicator.adaptive`, merging without losing edits, with a message either way |
| Card | `TaskCard` | rows | `TaskCard`: due / overdue / done with icons and words, created date |
| States | loading, empty, error | loading, empty, error | the same, decided only once the store has caught up with the seed |
| Tests | ViewModel and use case unit tests | use case and view model tests | Cubit on a real data stack, the view with a `MockCubit`, the card, app flows, the accessibility tour, 18 mutation checks |

Both native specs plan the same screen; the Flutter edition adds Undo (a swipe is easy to do by accident), overdue (the iOS fields include a due date), and the two timing details only tests on a real store revealed.

---

## 🎤 Interview Notes

**Q: Why does the Cubit hide a swiped task before the database answers?**
A: `Dismissible` requires the row to leave the widget tree in the same frame it's dismissed; rebuilding it back in throws. The database answers asynchronously, so the Cubit removes the row from its state at once, and puts it back if the delete fails.

**Q: How does a SnackBar fire exactly once?**
A: The state carries a serial number alongside the message. The view's `BlocListener` listens only when the serial changes, so the same message in a later state (after a toggle, say) doesn't show it again.

**Q: Why read the store again after the seed?**
A: The seed's future completes when the transaction commits, but drift's stream reports the new rows a moment later. Deciding on the stream's last value then means deciding on the empty list from before the seed, which is a flash of "No tasks yet". Reading once more gives the state after the seed.

**Q: Why does the Tasks screen have its own `ScaffoldMessenger`?**
A: In a tab shell there are two Scaffolds. The app's messenger shows SnackBars in the outer one, which doesn't know the inner one's FAB, so "Undo" covered "Add". A messenger per tab screen lays SnackBars out in the screen's own Scaffold, above its FAB.

---

## 📝 Learning Checklist

- ✅ Split a screen into Page (DI) and View (rendering), and test the View with a `MockCubit`
- ✅ Model one-time effects as serials and react with `BlocListener`
- ✅ Swipe to delete with Undo, safely
- ✅ Decide loading / empty / error only once the store has caught up
- ✅ Make a swipe-only action reachable by screen readers
- ✅ Test a Cubit on a real data stack, and make timing bugs deterministic
- ⬜ Task detail and the Add / Edit form (Phase 4)

---

## 🚀 Future Improvements

- **Phase 4:** task detail (watch one task, toggle, delete with a confirmation, not found) and the Add / Edit form (validation, the adaptive date picker, the discard guard).
- **Later:** filters (open / done / overdue) and search; sections by due date; a `today` that moves at midnight while the app is open.

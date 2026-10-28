# Phase 4 — Create / Edit + Detail

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 4, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 4 completes the sample feature's round trip:
- **a task's own screen:** everything about it, tick it off, edit it, delete it after asking, and "Task not found" for a stale link;
- **one form for Add and Edit:** validation shown only after the first Save, an adaptive date picker, a Done switch when editing, a discard guard, and a form that closes itself once saved;
- **links:** `/tasks/:id` and `/tasks/:id/edit` open cold and still find their way back.

It shows the template's form pattern: a Cubit takes its id through `@factoryParam`, derives errors rather than storing them, and announces "saved" as a one-time effect.

---

## 🧱 What Was Implemented

- **Task detail (`features/task_detail`):**
  - `TaskDetailCubit` (`@factoryParam` id): it watches the task, so an edit shows at once and a deletion elsewhere turns the screen into "Task not found". It toggles, and deletes once the View has asked. It never flashes "not found" for its own delete, and a failed delete stays on the task and says why.
  - `TaskDetailView`:
    - the title as a heading, the status line (overdue, due or done), and a Done switch (`SwitchListTile.adaptive`);
    - notes, the due date in full, and when the task was created and last updated (the device's 12- or 24-hour clock);
    - Edit and Delete in the app bar. Delete asks first through the adaptive confirm dialog (a Material dialog, or an iOS alert with a red Delete).
    - Close when opened by a link; once deleted, it leaves.
- **The form (`features/task_form`):**
  - `TaskFormCubit` (`@factoryParam String?`: `null` is a new task) and `TaskFormState`:
    - The errors are getters over `TaskRules`, shown after the first Save.
    - `hasChanges` compares the fields with the stored task (or with empty, ignoring spaces).
    - An edit reads the task once, so a change elsewhere never overwrites what's being typed.
    - Save runs only while editing (no double saves); invalid input never reaches the use case; `saved` is the closing effect.
  - `TaskFormView`:
    - the title (autofocused for a new task), the notes, the due date, and Done when editing;
    - Save in the app bar, which becomes a labelled spinner while saving;
    - a save error under the form, as a live region;
    - "Task not found" for a stale edit link.
    - The discard guard: `PopScope` for the system back gesture, and Close asks the same "Discard changes?".
- **Design system:**
  - `showConfirmDialog` (adaptive, from Evently);
  - `DatePickerField` and `pickDate`: Material's calendar on Android, a wheel in a sheet on iOS, Clear, and `CalendarDate` in and out;
  - `longDayLabel` ("Thursday 29 October 2026") and `dateTimeLabel` ("20 Jul 2026, 14:05").
- **`TaskStatusLine`:** the card's status line, now shared with the detail screen.
- **Tests:** 307 (79 new), and 18 mutation checks.

### Differences from the plan

- **The Close button read a stale state.** Its callback used the state from the last build. A keystroke updates the Cubit at once but rebuilds a frame later, so typing and tapping Close in that gap closed without asking. Close now reads the Cubit's state at tap time. An app flow found it.
- **The form has no "go to the task" fallback.** The edit form is a *child* route of its task, so even a cold link opens it with the task underneath, and Close always pops. A mutation check found the fallback unreachable, so it was removed. Only `/tasks/new` needs the go-to-Tasks fallback.
- **The Material date picker is excluded from the tour's tap-target check.** Its day cells are 47.7 px wide at 200 % text (seven must fit the dialog). That is Flutter's own widget; its labels and contrast are still checked.
- **`TaskFormState` adds `saveError` and `today`** to the spec's sketch: why a save failed, and where the picker opens.
- **No Undo after deleting from the detail screen:** it asks first, as the spec says. Undo stays on the list's swipe, where a delete can be accidental.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **`@factoryParam`:** `getIt<TaskFormCubit>(param1: taskId)`, with a nullable id for "new". The Cubit stays router-free and is trivial to construct in a test.
- **Derived state:** errors and `hasChanges` are getters on a freezed class (`const TaskFormState._()`), so they can't drift from the fields.
- **One-time effects as transitions:** `listenWhen: previous.status != saved && current.status == saved`, so the form closes once, whatever rebuilds after.
- **`PopScope` + `onPopInvokedWithResult`:** guards the system back gesture. A custom Close button shares the same dialog.
- **Read state at the moment of action:** `context.read<Cubit>().state` in a callback, not a value captured during `build`.
- **Adaptive widgets:**
  - `showAdaptiveDialog` + `AlertDialog.adaptive` + `CupertinoDialogAction(isDestructiveAction:)`;
  - `SwitchListTile.adaptive`;
  - `showDatePicker` vs `CupertinoDatePicker` in a sheet, chosen by `Theme.of(context).platform`.
- **Child routes and Close:** a child route always has its parent underneath, so a fallback for "nothing to pop" belongs only on top-level routes.
- **Semantics:** a heading (`header: true, container: true`), a live region for the save error, and a label for the busy Save button.

---

## 🔁 Data Flow (this phase)

```
list ─ tap ─▶ TaskDetailRoute(id) ─▶ getIt<TaskDetailCubit>(param1: id)..load()
                watchTask(id) ─▶ ready / notFound
  Done switch ─▶ toggle ─▶ drift ─▶ the screen (and the list) update
  Delete ─▶ confirm dialog ─▶ delete ─▶ deleting ─▶ deleted ─▶ the View leaves
  Edit ─▶ EditTaskRoute(id) ─▶ getIt<TaskFormCubit>(param1: id)..load()
                                 watchTask(id).first ─▶ the fields, once

FAB ─▶ NewTaskRoute ─▶ getIt<TaskFormCubit>(param1: null)   (editing at once)
  type ─▶ titleChanged / notesChanged / dueChanged
  Save ─▶ showErrors ─▶ invalid? stop : saving ─▶ Add / Update use case
           ─▶ saved ─▶ the View closes (once) ─▶ drift shows the change
  Close / back with changes ─▶ "Discard changes?" ─▶ Keep editing | Discard
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/features/task_detail/{task_detail_page,cubit/*}.dart` | The task's screen. |
| `lib/features/task_form/{task_form_page,cubit/*}.dart` | The Add / Edit form. |
| `lib/features/tasks/widgets/task_status_line.dart` | Overdue / due / done, shared. |
| `lib/core/design_system/widgets/{confirm_dialog,date_picker_field}.dart` | Adaptive dialog and date field. |
| `test/features/{task_detail,task_form}/**`, `test/app/task_form_flow_test.dart` | Cubits, views, flows. |
| `test/core/design_system/widgets/*` | The dialog and the picker, on both platforms. |
| `test/helpers/fakes/scripted_deletes.dart` | A repository whose delete can be scripted. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `TaskDetailCubit`, `TaskDetailState` | Cubit / freezed | One task: watch, toggle, delete | `features/task_detail` |
| `TaskFormCubit`, `TaskFormState` | Cubit / freezed (with getters) | Add and Edit: fields, errors, changes, save | `features/task_form` |
| `TaskDetailView`, `TaskFormView` | widgets | Render; navigate; ask | the Pages pass `onLeave` / `onClose`, so tests can see them |
| `TaskStatusLine` | widget | Overdue / due / done | `features/tasks/widgets`: the sample's |
| `showConfirmDialog`, `DatePickerField`, `pickDate` | design system | Adaptive dialog and date input | `core/design_system`: any feature |

---

## 🌱 Folder Structure Changes

- **New:** `lib/features/task_detail/cubit/`, `lib/features/task_form/cubit/`, `lib/core/design_system/widgets/{confirm_dialog,date_picker_field}.dart`; `test/features/{task_detail,task_form}/…`, `test/core/design_system/widgets/`.
- The detail and form placeholders became the real screens; Settings is still a placeholder.

---

## 🧪 Tests (307; 79 new)

| Area | New | What they pin |
|------|----:|---------------|
| `TaskFormCubit` | 13 | A new form; errors only after Save; invalid input never sent; saving once; what counts as a change; editing every field and Done; edits elsewhere not overwriting; not found; a failed save |
| `TaskFormView` | 13 | New vs edit, typing reaches the Cubit, errors, the busy Save, a save error, closing once, the discard guard (Close, Keep editing, Discard, the back gesture), not found |
| `TaskDetailView` | 11 | Everything shown, empty fields, the heading, the switch, Delete asks (Cancel / confirm), leaving once, while deleting, not found, a message |
| `TaskDetailCubit` | 8 | Ready, not found, toggle, edits elsewhere, delete without "not found", deleted elsewhere, a failed delete, nothing while not ready |
| App flows | 12 | Add; Save with no title; add with a picked date; discard; `/tasks/new` by link; edit from the detail; the Done switch; delete confirmed and cancelled; links to missing tasks and forms; an edit link returning to its task |
| Accessibility tour | 12 | A task, not found, its Delete dialog; the form's errors, the discard dialog, the date picker; the edit form not found |
| Design-system widgets | 8 | The confirm dialog on Android and iOS (and its destructive action); the date field: empty, Clear, Material's calendar, cancelling, the iOS wheel |
| Date labels | 2 | The long day; the date and time on a 12- or 24-hour clock |

**Mutation checks (18), each caught by the whole suite:**
- errors before the first Save; the form skipping its own check; Save twice;
- spaces counting as a change; Done not a change; an edit dropping Done;
- no discard guard; closing or leaving on every rebuild; Save enabled while saving; a Done switch on a new task;
- `/tasks/new` by link popping the last page;
- the detail showing "not found" for its own delete; a failed delete stuck in "deleting"; delete without asking;
- the Material picker on iOS; Clear doing nothing; a 12-hour clock always.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Screens | Add Task only | Task Detail + Create/Edit | the iOS set: a detail route with an id, one form for Add and Edit |
| Form logic | `AddTaskViewModel` + `AddTaskUiState` | `CreateTaskViewModel` (edit mode) | `TaskFormCubit` (`@factoryParam String?`), errors and changes derived |
| One-time effect | `AddTaskEffect` (navigate back) | a dismiss effect | `saved` status, a `BlocListener` on the transition |
| Presentation | a screen | a sheet | a full-screen dialog (Close, a discard guard) |
| Delete | — | with confirmation | an adaptive confirm dialog (iOS alert, red Delete) |
| Date input | — | — | adaptive: Material calendar / iOS wheel, as a `CalendarDate` |
| Tests | Compose UI tests | validation and view model tests | Cubits on a real data stack, views with mocked Cubits, both platforms' dialogs and pickers, app flows, the tour, 18 mutation checks |

The Android edition only adds tasks; the iOS one plans detail, edit and a confirmed delete. The Flutter edition takes the iOS set and adds the discard guard and the adaptive date picker (the iOS fields include a due date).

---

## 🎤 Interview Notes

**Q: Why are the form's errors getters, not fields?**
A: A stored error can disagree with the text it describes. A getter over `TaskRules` is always right, and `showErrors` decides only *when* to show them. The use case runs the same rules, so nothing invalid gets past the form unnoticed.

**Q: How does the form close exactly once?**
A: `saved` is a status, and the View listens for the *transition* into it (`previous != saved && current == saved`). Any later rebuild, or a duplicate emission, doesn't close it again; a test emits `saved` twice and expects one close.

**Q: What was the bug with Close?**
A: The callback used the `state` captured when the widget last built. Typing updates the Cubit immediately but rebuilds a frame later, so a tap in that gap saw "no changes" and closed without asking. Reading `context.read<Cubit>().state` at tap time fixes it.

**Q: Why does the detail screen ignore the task disappearing after its own delete?**
A: It's watching the task, so the delete makes the stream emit `null`, which normally means "not found". While it is deleting, that `null` is expected: the screen goes to `deleted` and leaves, instead of flashing "Task not found".

---

## 📝 Learning Checklist

- ✅ Pass a route's id to a Cubit with `@factoryParam`
- ✅ Derive validation and "unsaved changes" from state
- ✅ Close a form once, with a one-time effect
- ✅ Guard against losing input with `PopScope`, and read state at the moment of the tap
- ✅ Use adaptive dialogs, switches and date pickers
- ✅ Make deep links to child routes find their way back
- ⬜ Settings: appearance, dynamic color, reset demo data, About (Phase 5)

---

## 🚀 Future Improvements

- **Phase 5:** the app-wide `SettingsCubit` above the router (System / Light / Dark, dynamic color on Android 12+), Reset demo data, About.
- **Later:** a title character counter; reminders for due dates (as in Momentum); attachments.

# Interview Notes

Questions this project answers, with short answers. Each phase's summary has more.

---

## Architecture

**Q: Walk me through the layers.**
A: View → Cubit → use case → repository → drift or the API. `domain/` is pure Dart (models, rules, contracts, use cases); `data/` implements the contracts and maps between DTOs, domain models and rows; `core/` holds the database, the fake API, storage, the design system and navigation; `di/` chooses the implementations. Views never see `data/`, Cubits never see a DAO.

**Q: Why three models for one task?**
A: The API's JSON (`TaskDto`), the app's model (`Task`) and the table's row (`TaskRow`) change for different reasons. With a mapper between each, a renamed JSON field or a new column stops at the mapper, and the mapper is where the server's data is checked before it's stored.

**Q: Why use cases that just forward to the repository?**
A: They are where a rule that spans repositories, or a check before a write, goes, and they keep a Cubit's dependencies to exactly what its screen does. `AddTaskUseCase` already does real work: it refuses what `TaskRules` refuses.

## Data

**Q: How does the refresh avoid losing a user's edit?**
A: It only inserts: `ON CONFLICT (id) DO NOTHING`, in one transaction. A stored task is never overwritten, and a tombstone table skips tasks the user deleted.

**Q: Why not `INSERT OR IGNORE`?**
A: It ignores a `CHECK` failure as well as the id clash, so a damaged row would disappear without an error. A test caught it.

**Q: How is the first-launch seed made to run exactly once?**
A: A preference is set only after the seed's transaction commits; rows already stored count as seeded (if the flag's write was lost); and concurrent calls share one future. Each has a test that fails when the rule is broken.

**Q: Why is a due date an `int`?**
A: It's a day, not a moment. A `yyyymmdd` integer has no zone, sorts and compares like dates, and makes a range a `BETWEEN`. An extension type gives it an API at no runtime cost.

## State and UI

**Q: Cubit or Bloc?**
A: Cubit by default: every action here is a method call with no timing rules. A Bloc earns its place with event transformers, like a debounced, restartable search.

**Q: How do you show a SnackBar exactly once?**
A: The state carries the message with a serial; the `BlocListener` fires only when the serial changes. Closing a form listens for the transition into `saved`, not the status itself.

**Q: Why is `SettingsCubit` above `MaterialApp`?**
A: The theme is the app's, not a screen's. It starts from preferences loaded before `runApp`, so the first frame is already in the right theme; a `buildWhen` keeps the router from rebuilding.

**Q: How does swipe-to-delete with Undo stay safe?**
A: The Cubit hides the row in the same frame (a dismissed `Dismissible` can't come back into the tree), deletes with a tombstone, and offers the deleted task for Undo. A failed delete shows the row again; Undo shows it again at once.

## Testing

**Q: How do you test a Cubit?**
A: Against a real data stack: the real repository on an in-memory drift database, the real fake API with no latency, a clock I can move. Views get a `MockCubit` in one state per test; app flows run on the real DI graph.

**Q: How do you know a test would catch a bug?**
A: Mutation checks: break the rule (drop a transaction, flip a comparison), run the whole suite, expect a failure. Each phase ran them; the misses became new tests, and one found dead code.

**Q: What does the accessibility tour check?**
A: Every screen and state, light and dark, at 200 % text: no overflow, tap targets of 48 × 48, labels on everything tappable, AA contrast.

## Template

**Q: How do you make a template that people can actually strip down?**
A: Name everything of the sample alike (`task*`), keep shared code from depending on it beyond a short, written list of edits, and check it: follow the guide on a copy and run the analyzer and the tests.

**Q: What does the rename script do, and how do you trust it?**
A: It rewrites the package (pubspec and every import), the Android application ID, namespace and `MainActivity` folder, the iOS bundle IDs and the display names, reading the current names from the project so it can run twice. Its tests run it on a copy of the real files, and a renamed scratch copy analyzes, tests and builds on both platforms.

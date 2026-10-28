# Phase 6 — Documentation & CI

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 6, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 6 turns a working app into a template people can use:
- **the guide** to starting an app from it ([TEMPLATE_USAGE](TEMPLATE_USAGE.md)), and **the rename script** it relies on (`tool/rename.dart`);
- **proof that both work:** the sample removed by following the guide, and the project renamed with the script, each on a fresh copy;
- **the docs** a reader needs (architecture, testing, learning and interview notes, roadmap, screenshots) and **the files** a contributor needs (CONTRIBUTING, a code of conduct, a security policy, a changelog, issue and PR templates);
- **one last check of the key rules:** each broken on purpose, against the whole suite, plus a release-build launch.

---

## 🧱 What Was Implemented

- **`tool/rename.dart`** (pure Dart, no packages):
  - It renames the package (`pubspec.yaml` and every `package:` import in `lib/`, `test/` and `tool/`), the Android application ID and namespace, `MainActivity`'s Kotlin package (its folder moves, the old ones go), the iOS bundle IDs (the app and its tests), and the display names (Android's label, `CFBundleDisplayName` and `CFBundleName`, `MaterialApp`'s title).
  - It reads the current names from the project, so a second run changes nothing and a later rename starts from wherever the project is.
  - `--dry-run` lists the files and writes nothing; invalid options are refused with a reason.
  - 20 tests run it on a copy of the project's real files.
- **The sample made removable:**
  - every file of it has `task` in its name;
  - shared tests no longer name it: the shell's tests read the tabs from `AppTab`; the sample's cases moved to `task*` files (the tour, navigation, DI, schema, settings flows); the test clock moved to `test_clock.dart`; `pumpStarter` takes `beforeLaunch:` instead of `withDemo:`;
  - `SettingsView` takes the sample's section as a `dataSection` parameter, so the shared view doesn't import it.
- **TEMPLATE_USAGE:** clone; rename (and what the script leaves alone); remove the sample (two `find` commands, a Home tab to create, six shared edits, regenerate); add a feature layer by layer; replace the fake API with `dio`; what the template leaves out, with the sibling project that shows each; a pre-release checklist.
- **Docs:** ARCHITECTURE, TESTING, LEARNING_NOTES, INTERVIEW_NOTES, ROADMAP, SCREENSHOTS (with alt text); the final README.
- **Open-source files:** CONTRIBUTING (the architecture rules, keeping the sample removable and the rename working), CODE_OF_CONDUCT (Contributor Covenant 2.1), SECURITY (what the template holds, and what an app built on it must review), CHANGELOG (a version per phase), and the `.github` issue and PR templates. CI was already current.
- **Tests:** 385 (24 new), and 35 mutation checks.
- **Found on the simulator, at the largest text:** a list row's icon (Reset demo data, About) drifted to the middle of the wrapped row, away from its title. The theme now aligns every `ListTile`'s icon with the title (`ListTileTitleAlignment.titleHeight`).
- **A release build** launches on the Android 16 emulator: it seeds the demo on first launch and draws in the wallpaper's colors, with no errors in the log.

### What the template checks found

Both checks ran on fresh copies of the repository, by the guide's exact steps (a script applies them):
- **Removing the sample:**
  - With no tables, drift's generated database code keeps an unused field, which is a *warning*, so `flutter analyze` and CI would fail. `build.yaml` now ignores `unused_field` in generated parts, with a comment saying why.
  - The edits leave a file to reformat, so the guide's last step runs `fvm dart format .`.
  - Several shared tests named the sample. They were rewritten or split (above).
  - **Result:** no file with `task` in its name is left; analyze reports no issues; the remaining 138 tests pass.
- **Renaming:**
  - A new package name changes the imports' alphabetical order, and a broad `dart fix --apply` also rewrote the tests' `async {}` stubs into `return null;`, tripping another lint. The guide and the script's "Next" line now run `dart fix --apply --code=directives_ordering`, then `dart format`.
  - The rename script's own tests hard-coded the template's names, so they failed after a rename. They now read the current names from the project, as the script does.
  - **Result:** the dry run lists 111 files; the rename changes them; a second run changes nothing; format and analyze are clean; all 385 tests pass; the Android and iOS debug builds succeed, as `com.example.mytasks`, "My Tasks".

### Differences from the plan

- **The tour's "Task" and "Edit task" stops were checking "Task not found":** a link opened cold, with nothing stored, shows that. They now store the demo first and check what's on screen. A coverage gap, found while splitting the tests.
- **No `API_SIMULATION` or `DATA_MODEL` docs:** the spec lists the seven docs above; the fake API and the two tables are covered in ARCHITECTURE and the README.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **A pure-Dart tool** (`dart:io` only), structured as a function over a directory (`renameProject(root, options)`), so it's testable on a temporary copy, with a thin `main` for the command line.
- **Idempotence by reading state, not assuming it:** the script finds the current names in the files.
- **Generated code and lints:** `source_gen`'s `ignore_for_file` options for generated parts; why a warning differs from a lint.
- **`dart fix` scoped to one code** (`--code=directives_ordering`).
- **Null-aware collection elements** (`?dataSection` in a list).
- **Tests that hold after a rename or a removal:** read names from the project; read the tabs from `AppTab`; tap a button by type, not by its text.
- **Mutation testing as a final gate,** against the whole suite rather than chosen files.

---

## 🔁 Data Flow (this phase)

```
tool/rename.dart --package P --app-id I --name N [--dry-run]
  read: pubspec name · build.gradle.kts applicationId · AndroidManifest label
  package changed?  pubspec.yaml, every package: import in lib/ test/ tool/
  app ID changed?   build.gradle.kts, project.pbxproj (+ .RunnerTests), move MainActivity
  name changed?     AndroidManifest label, Info.plist (2 keys), MaterialApp title
  ──▶ the files changed (or that would be)
then: dart fix (directives_ordering) → dart format → pub get → build_runner → test

TEMPLATE_USAGE "Remove the Tasks sample"
  delete *task* (lib, test, assets) → a Home tab → 6 shared edits
  → build_runner → make-migrations → dart format → analyze → test
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `tool/rename.dart`, `test/tool/rename_test.dart` | The rename script and its tests. |
| `docs/{TEMPLATE_USAGE,ARCHITECTURE,TESTING,LEARNING_NOTES,INTERVIEW_NOTES,ROADMAP,SCREENSHOTS}.md` | The guides. |
| `docs/screenshots/*.png` | The screenshots. |
| `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md` | Open-source files. |
| `.github/ISSUE_TEMPLATE/{bug_report,feature_request}.md`, `.github/PULL_REQUEST_TEMPLATE.md` | Templates. |
| `test/helpers/{accessibility,test_clock}.dart` | The tour's steps; the shared clock. |
| `test/app/{tasks_accessibility_tour,tasks_demo_flow}_test.dart`, `test/core/navigation/task_routes*_test.dart`, `test/core/database/tasks_schema_test.dart`, `test/di/tasks_injection_test.dart`, `test/features/settings/widgets/tasks_demo_section_test.dart` | The sample's tests, split out of shared ones. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `RenameOptions` | value | The new names, parsed and validated | `tool/` |
| `renameProject` | function | Renames a project directory; returns the files | `tool/`: testable on any folder |
| `RenameException` | exception | Not this template (a file or a name missing) | `tool/` |
| `SettingsView.dataSection` | parameter | A feature's settings, between Appearance and About | keeps the shared view free of the sample |

---

## 🌱 Folder Structure Changes

- **New:** `tool/`, `test/tool/`, `docs/screenshots/`, `.github/ISSUE_TEMPLATE/`; the guides in `docs/`; the open-source files at the root.
- **Renamed:** `test/helpers/data_stack.dart` → `tasks_data_stack.dart`, `fakes/scripted_deletes.dart` → `scripted_task_deletes.dart` (sample files have `task` in their names).

---

## 🧪 Tests (385; 24 new)

| Area | New | What they pin |
|------|----:|---------------|
| The rename script | 20 | Every file it changes; `MainActivity` moved and the old folders gone; a second run changing nothing; renaming again; a dry run writing nothing; only what differs changing; an error outside a project; nine invalid options |
| Navigation | 1 | "Settings has its own path" (the route tests split into shared and sample) |
| Settings view | 1 | A feature's section between Appearance and About |
| DI | 1 | The sample's graph resolves on its own (split from the shared composition-root test) |
| Design system | 1 | List rows keep their icons level with the title |

The rest moved between files without changing what they check, except the tour's "Task" and "Edit task" stops, which now check the screen they show.

**Mutation checks (35), each caught by the whole suite** (on the final code):
- **the refresh:** as `REPLACE`, as `INSERT OR IGNORE`, ignoring tombstones;
- **tombstones:** none written, none removed by Undo or a reset;
- **the seed:** its flag ignored or set before the insert, two seeds at once;
- **times:** `createdAt` written, `updatedAt` kept;
- **reset:** deleting before it fetches;
- **rules:** overdue including today, titles counted in code units, duplicate server ids accepted, validation skipped by the use case or by the form;
- **settings:** every key written, the theme starting from the defaults, dynamic color ignoring its switch, the dark theme ignoring the wallpaper;
- **the list:** no read after the seed, delete not optimistic, Undo left hidden, SnackBars on every rebuild or in the shell's Scaffold;
- **the form and the detail:** no discard guard, closing on every rebuild, the detail showing "not found" for its own delete;
- **the rename script:** a dry run writing, the tests' bundle ID kept, empty folders left, only `CFBundleDisplayName` renamed, the tests' imports kept, a package with capitals accepted.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Template usage | `TEMPLATE_USAGE.md` | `TEMPLATE_USAGE.md` | the guide, plus `tool/rename.dart`, both checked on fresh copies |
| Renaming | by hand (package, applicationId) | by hand (bundle ID, target) | one script for both platforms, idempotent, with a dry run |
| Removing the sample | described | described | every sample file named `task*`, six shared edits, checked: analyze and tests pass |
| Final docs | README, ARCHITECTURE, TESTING, ROADMAP, the conventions' set | README (SwiftData → Core Data note, how to start a new app), LEARNING / INTERVIEW notes | the same set, plus TEMPLATE_USAGE, SCREENSHOTS with alt text |
| Open-source files | CONTRIBUTING, CODE_OF_CONDUCT, LICENSE, CHANGELOG, SECURITY, templates | the same | the same |
| CI | `android-ci.yml`, in Phase 6 | `ios-ci.yml`, in Phase 6 | `flutter-ci.yml` since Phase 1 |
| Final checks | cleanup | cleanup | a release-build launch, and a mutation pass of the key rules and the script |

Both native specs ask for a TEMPLATE_USAGE. The Flutter edition adds the script and makes both promises checkable, which is where this phase's three fixes came from.

---

## 🎤 Interview Notes

**Q: How do you know your template can be stripped down?**
A: I did it, by the guide's steps, on a fresh copy, with a script, so it's repeatable. It failed the first time: an empty drift database generates a warning, and some shared tests named the sample. Both are fixed, and the check is in the docs.

**Q: How is the rename script safe to run twice?**
A: It never assumes the old names. It reads the package from `pubspec.yaml`, the app ID from `build.gradle.kts` and the name from the manifest, and only changes what differs. A test runs it twice and expects no changes the second time.

**Q: Why didn't `dart fix --apply` just work after a rename?**
A: It applies every available fix, and one rewrote `async {}` test stubs into `return null;`, which another lint then flags. Scoping it to `--code=directives_ordering` does only what the rename needs: re-sorting imports.

**Q: What's the point of a final mutation pass?**
A: Coverage says a line ran; a mutation says a test notices when the line is wrong. Thirty-five of the rules that matter most were broken one at a time against the whole suite, on the final code; every one was caught.

---

## 📝 Learning Checklist

- ✅ Write a tool that renames a Flutter project for both platforms, and test it on a copy
- ✅ Make a sample feature removable, and prove it
- ✅ Keep shared tests independent of the sample
- ✅ Document a template for the people who will copy it
- ✅ Ship the open-source file set
- ✅ Re-run the key rules as mutations, and launch a release build
- ✅ All six phases

---

## 🚀 Future Improvements

See the [roadmap](ROADMAP.md): an onboarding gate, authentication, notifications and background work, a real API with `dio`, flavors, localization, a multi-package version, a launch screen that follows the device, tablets.

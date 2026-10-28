<!-- Thanks for contributing to Flutter Clean Starter! -->

## Summary

<!-- What does this PR change, and why? -->

## Changes

-

## Checklist

- [ ] `fvm flutter analyze` reports no issues.
- [ ] `fvm dart format --output=none --set-exit-if-changed .` passes.
- [ ] `fvm flutter test` passes; new logic is covered by tests where practical (rules at their edges).
- [ ] Generated code is regenerated and committed (`fvm dart run build_runner build`).
- [ ] Architecture boundaries are respected (View → Cubit → UseCase → Repository); screens read drift, not the API.
- [ ] A refresh still never overwrites a local edit or revives a deleted task.
- [ ] A schema change bumps `schemaVersion` and ships with `make-migrations` output and a migration test.
- [ ] The sample is still removable: new sample files have `task` in their name, and TEMPLATE_USAGE lists any new shared edit.
- [ ] `tool/rename.dart` still covers every file holding the package name, the app ID or the display name.
- [ ] UI changes work in dark mode and at large text sizes, and new screens or states are in the accessibility tour.
- [ ] A release build launches, if a plugin or native setup changed.
- [ ] Docs are updated if behaviour or structure changed.
- [ ] Commit messages follow Conventional Commits.

## Screenshots (if UI changed)

| Before | After |
|--------|-------|
|        |       |

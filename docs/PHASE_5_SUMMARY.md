# Phase 5 — Settings

> A beginner-to-intermediate friendly write-up covering:
> - what shipped in Phase 5, and why;
> - the Flutter / Dart concepts it demonstrates;
> - how the Android and iOS editions planned the same phase.

---

## 🎯 Phase Goal

Phase 5 replaces the last placeholder, the Settings tab, and shows the template's one app-wide piece of state:
- **appearance:** System / Light / Dark, applied to every screen at once and from the very first frame of the next launch;
- **dynamic color:** the wallpaper's colors on Android 12+, behind an interface, and not offered where the device has none;
- **Reset demo data:** the sample's tasks back, after asking; offline, nothing changes;
- **About:** the app's name and version.

---

## 🧱 What Was Implemented

- **`SettingsCubit`** (`features/settings/cubit`): app-wide, provided **above** `MaterialApp.router` in `StarterApp`.
  - It starts from `SettingsRepository.current`, the preferences loaded before the first frame (`@preResolve`), so the app never flashes the default theme.
  - It follows every change, and sets the theme mode and dynamic color through their use cases.
  - `SettingsState.dynamicSeed` is the wallpaper's color when dynamic color is on and the device has one, otherwise `null` (the app's teal).
- **`StarterApp`:** a `BlocBuilder` (rebuilding only for the seed or the mode) gives `MaterialApp.router` its theme, dark theme and `themeMode`. The router is untouched, so changing the theme never resets navigation.
- **Dynamic color:**
  - `DynamicColorSource` (`domain/service`) is the interface; `MaterialYouColorSource` (`core/platform`) reads the wallpaper's palette through `dynamic_color`, on Android only, and answers `null` when the plugin fails.
  - The app builds its own scheme from that color with `AppTheme.fromSeed`, not the plugin's `ColorScheme` (conventions §11.55).
  - `DeviceColors` is read before the first frame (`@preResolve`).
- **`AppInfo`** (`package_info_plus`), also read before the first frame: About shows "Version 1.0.0 (1)" with no loading state.
- **The Settings screen:**
  - **Appearance:** a `SegmentedChoice` (three segments), or a radio list at large text; then the Dynamic color switch, only where the device has wallpaper colors.
  - **Data:** Reset demo data, with an adaptive confirm dialog, a busy spinner, and a SnackBar with the outcome ("Demo data restored: 5 tasks." or why it failed).
  - **About:** the name, the version, and one line on what the template is.
- **The sample's part of Settings:** `TasksDemoCubit` and `TasksDemoSection` are named `tasks_*`, so removing the sample removes them (and one line in `SettingsView`).
- **Design system:** `SegmentedChoice` (from DevJourney): segments, or wrapping chips at large text.
- **Tests:** 361 (54 new), and 11 mutation checks.

### Differences from the plan

- **One mutation survived at first:** the dark theme ignoring the wallpaper. No test checked dynamic color in dark mode; one does now.
- **The meaning colors are checked on wallpapers, too.** With dynamic color the surfaces follow the wallpaper, but `overdue` and `done` stay fixed. A test checks AA contrast on seven wallpaper hues, in both themes; all pass.
- **The iOS launch screen is still white.** The native launch screen shows before Flutter's first frame and can't read the app's setting. Flutter's own first frame is dark when Dark is saved (tested). A launch screen that follows the device's appearance is on the roadmap.
- **No open-source licenses page in About:** the spec asks for the name, the version and a line on the template, nothing more.

---

## 💙 Flutter / Dart Concepts Demonstrated

- **App-wide vs screen state:** the one Cubit provided above `MaterialApp`, and why (the theme belongs to the app). Every other Cubit is created by its Page.
- **`@preResolve` for first-frame correctness:** preferences, the wallpaper's color and the app's version, all awaited before `runApp`.
- **`buildWhen`** to rebuild `MaterialApp` only when the theme's inputs change.
- **`ThemeMode`** from an app enum with an exhaustive `switch`.
- **Material You without the plugin's `ColorScheme`:** take the palette's primary tone, then `ColorScheme.fromSeed`, so the app keeps one theme builder.
- **A platform service behind an interface:** `DynamicColorSource` in the domain, the plugin in `core/platform`, a fake in tests, a mocked channel in app tests (conventions §11.58).
- **Adaptive layout at large text:** segments become a radio list (`RadioGroup` + `RadioListTile`), and chips wrap.
- **`ListTile` semantics:** a trailing spinner's label merges into the row's.

---

## 🔁 Data Flow (this phase)

```
main ─▶ configureDependencies()
          @preResolve: SharedPreferencesWithCache, AppInfo, DeviceColors (wallpaper color)
     ─▶ StarterApp ─▶ BlocProvider(SettingsCubit(settings.current, deviceColors)..load())
                       └─ BlocBuilder(buildWhen: seed or mode changed)
                            └─ MaterialApp.router(theme / darkTheme from the seed, themeMode)

Settings ─ Dark ─▶ SettingsCubit.setThemeMode ─▶ UpdateThemeModeUseCase
                    ─▶ SettingsRepositoryImpl.update (only the changed key written)
                    ─▶ watch() ─▶ SettingsCubit ─▶ MaterialApp rebuilds ─▶ every screen dark

Settings ─ Reset demo data ─▶ confirm ─▶ TasksDemoCubit.reset ─▶ ResetDemoDataUseCase
            ─▶ fetch, then replace in one transaction ─▶ drift ─▶ the Tasks tab updates
            ─▶ "Demo data restored: 5 tasks."   (offline: why, and nothing changed)
```

---

## 📁 Important Files Added

| File | Purpose |
|------|---------|
| `lib/features/settings/cubit/{settings_cubit,settings_state}.dart` | The app-wide settings. |
| `lib/features/settings/cubit/{tasks_demo_cubit,tasks_demo_state}.dart`, `widgets/tasks_demo_section.dart` | Reset demo data (the sample's). |
| `lib/features/settings/settings_page.dart` | The Settings screen. |
| `lib/domain/service/dynamic_color_source.dart`, `lib/core/platform/material_you_color_source.dart` | Dynamic color, behind an interface. |
| `lib/domain/model/device_info.dart` | `DeviceColors`, `AppInfo`. |
| `lib/core/design_system/widgets/segmented_choice.dart` | Segments, or chips at large text. |
| `test/app/settings_flow_test.dart`, `test/features/settings/**` | Flows, Cubits, the view. |

---

## 🧩 Important Types Added

| Type | Kind | Responsibility | Why it lives here |
|------|------|----------------|-------------------|
| `SettingsCubit`, `SettingsState` | Cubit / freezed | The theme mode and dynamic color, app-wide | `features/settings/cubit`, provided by `StarterApp` |
| `TasksDemoCubit`, `TasksDemoState`, `TasksDemoSection` | Cubit / freezed / widget | Reset demo data | the sample's, removable with it |
| `DynamicColorSource` | interface | The wallpaper's color | `domain/service` |
| `MaterialYouColorSource` | class | Reads it through `dynamic_color` | `core/platform` |
| `DeviceColors`, `AppInfo` | values | What the device offers; the app's version | `domain/model` |
| `SegmentedChoice` | widget | One of a few values | `core/design_system` |

---

## 🌱 Folder Structure Changes

- **New:** `lib/domain/service/`, `lib/core/platform/`, `lib/features/settings/{cubit,widgets}/`; `test/features/settings/`, `test/core/platform/`.
- Every placeholder screen is now real.

---

## 🧪 Tests (361; 54 new)

| Area | New | What they pin |
|------|----:|---------------|
| Theme contrast under dynamic color | 14 | `overdue` and `done` at AA on seven wallpaper hues, light and dark |
| `SettingsCubit`, `TasksDemoCubit` | 10 | Starting from the stored settings; changes saved and followed; the dynamic seed's three cases; reset online, offline, once |
| App flows | 10 | Dark on every screen, saved; Dark from the first frame; Light over a dark device and back to System; dynamic color in light and dark, switched off, absent; reset online and offline; About |
| `SettingsView` | 9 | Segments; a radio list at large text; the dynamic color switch only with wallpaper colors; reset asks, Cancel, confirm, busy, outcome; About |
| Accessibility tour | 4 | Settings with dynamic color; the reset dialog; light and dark |
| `MaterialYouColorSource` | 3 | iOS (the plugin never asked), old Android, a failing plugin |
| `SegmentedChoice`, `DeviceColors`, `AppInfo` | 4 | Segments vs chips; when dynamic color is offered; the version label |

**Mutation checks (11), each caught by the whole suite** (one after its test was added):
- the theme starting from the defaults;
- Light following the system;
- dynamic color ignoring its switch;
- the dark theme ignoring the wallpaper (**missed at first**);
- a theme mode change not rebuilding the app;
- the dynamic color switch shown everywhere;
- no radio list at large text;
- reset without asking, or twice;
- the plugin asked on iOS;
- a plugin error escaping.

---

## 🤖🍏 Android / iOS Comparison

From the two native specs:

| Concept | Android (Kotlin) | iOS (Swift) | Flutter (Dart) |
|---|---|---|---|
| Storage | DataStore | `SettingsStore` (`@AppStorage`) | `SharedPreferencesWithCache`, loaded before the first frame (from Phase 2) |
| Appearance | a dark-mode toggle | a System / Light / Dark picker driving `preferredColorScheme` | System / Light / Dark (a toggle can't say "follow the device"), app-wide through a Cubit above `MaterialApp` |
| Dynamic color | a toggle (`UpdateDynamicColorUseCase`) | — | Android 12+ only, behind `DynamicColorSource`; the switch hidden elsewhere |
| Reset demo data | — | re-seed | replace with the server's, in one transaction, after asking; offline, nothing changes |
| About | — | About | name and version (`package_info_plus`), and a line on the template |
| Screen logic | `SettingsViewModel` | `SettingsViewModel` | `SettingsCubit` (app-wide) + `TasksDemoCubit` (the sample's) |
| Tests | settings tests | settings tests | Cubits, the view, app flows (the first frame included), contrast on wallpaper palettes, the platform source, 11 mutation checks |

Android contributes dynamic color; iOS contributes the three-way picker, Reset demo data and About. The Flutter edition takes all four.

---

## 🎤 Interview Notes

**Q: Why is `SettingsCubit` the only Cubit above `MaterialApp`?**
A: The theme belongs to the app, not to a screen: `MaterialApp` needs it to draw anything. Every other Cubit is created by its Page and closed with it. Keeping the exception to one makes the rule easy to see.

**Q: How do you avoid a flash of the wrong theme at launch?**
A: The preferences are awaited before `runApp` (`@preResolve`), and the Cubit's initial state is the repository's current settings, not a default. A test pumps the app with Dark saved and checks the very first frame.

**Q: Why not use `dynamic_color`'s `ColorScheme` directly?**
A: It's `package:flutter/material.dart`'s class, and this app uses `material_ui`'s. Taking only the wallpaper's primary tone and building the scheme with the app's own `AppTheme.fromSeed` also keeps one path for every theme.

**Q: What did the mutation pass find?**
A: That nothing tested dynamic color in dark mode: the app could have ignored the wallpaper there and every test would still pass. One flow test closes it.

---

## 📝 Learning Checklist

- ✅ Provide app-wide state above `MaterialApp` and rebuild only what changes
- ✅ Load preferences, device colors and the app's version before the first frame
- ✅ Put a platform feature behind an interface, and fake it in tests
- ✅ Adapt a control to large text (segments → radio list)
- ✅ Check meaning colors against every palette they can meet
- ✅ Keep the sample's part of a shared screen removable
- ⬜ Documentation, `tool/rename.dart`, and the removal and rename checks (Phase 6)

---

## 🚀 Future Improvements

- **Phase 6:** the docs set, `TEMPLATE_USAGE.md` and `tool/rename.dart`, both verified on scratch copies, a release build, and screenshots.
- **Later:** an iOS launch screen that follows the device's appearance; open-source licenses in About; a text-size or language setting.

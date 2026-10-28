# Screenshots

Captured on Wednesday 28 October 2026 on an **iPhone 17 Pro simulator** (iOS, debug build, status bar fixed at 9:41) and an **Android 16 emulator** (Pixel 10 Pro, a **release** build, for dynamic color), then downscaled to 1000 px tall. Everything on screen is the demo, seeded on a fresh install; its due dates are counted from that day.

## Light

| Tasks | A task | Edit task |
|:---:|:---:|:---:|
| <img src="screenshots/tasks-light.png" width="250" alt="The Tasks list: Swap the fake API for a real one, Overdue, due yesterday, in red with a warning icon; Explore the architecture, due Fri 30 Oct with a calendar icon; Rename the project; Welcome to Flutter Clean Starter; Run the test suite, ticked, struck through and marked Done in green; each with a line of notes and its created date; an Add button"> | <img src="screenshots/task-light.png" width="250" alt="A task: Explore the architecture, Due Fri 30 Oct, a Done switch, Notes: Open docs/ARCHITECTURE.md to see how the layers fit together, Due date Friday 30 October 2026, History: Created 21 Jul 2026; Edit and Delete in the app bar"> | <img src="screenshots/edit-light.png" width="250" alt="Edit task as a full-screen dialog with Close and Save: Title, Notes (optional), Due date Friday 30 October 2026 with a Clear button, and a Done switch"> |

| The iOS date wheel | Task deleted, with Undo |
|:---:|:---:|
| <img src="screenshots/date-wheel-light.png" width="250" alt="A bottom sheet over the form: Due date with a Done button, and a month, day and year wheel on October 30 2026"> | <img src="screenshots/undo-light.png" width="250" alt="The Tasks list without Rename the project, and a 'Task deleted' SnackBar with Undo, sitting above the Add button"> |

## Dark

| Tasks | Delete, asked first | Settings |
|:---:|:---:|:---:|
| <img src="screenshots/tasks-dark.png" width="250" alt="The Tasks list in dark mode: the overdue line in a light red, Done in a light green, the same five tasks"> | <img src="screenshots/delete-dark.png" width="250" alt="An iOS alert over the task Swap the fake API for a real one: Delete this task? “Swap the fake API for a real one” will be deleted. Cancel, and Delete in red"> | <img src="screenshots/settings-dark.png" width="250" alt="Settings in dark mode: Appearance with System, Light and Dark segments; Data, Reset demo data, Replace every task with the sample tasks; About, Clean Starter, Version 1.0.0 (1), and a line on what the template is"> |

## Large text (iOS's largest accessibility size)

| Tasks | Settings |
|:---:|:---:|
| <img src="screenshots/large-text-tasks.png" width="250" alt="The Tasks list at the largest text size: the title Swap the fake API for a real one over three lines, the notes cut to one line, Overdue, due yesterday over three lines with its icon grown and level with the first line, and the created date"> | <img src="screenshots/large-text-settings.png" width="250" alt="Settings at the largest text size: Appearance as a radio list, System selected, then Light and Dark, each label whole; Data, Reset demo data, with its icon level with the title"> |

## Android dynamic color

| Tasks in the wallpaper's colors | Settings, with the switch |
|:---:|:---:|
| <img src="screenshots/android-dynamic-tasks.png" width="250" alt="The Tasks list on Android, tinted blue from the wallpaper: the same five tasks, overdue still in red, Done in green, a blue Add button"> | <img src="screenshots/android-dynamic-settings.png" width="250" alt="Settings on Android: Appearance segments, a Dynamic color switch on, Use the colors of your wallpaper; Data, Reset demo data; About, Clean Starter, Version 1.0.0 (1)"> |

## What to look for

- **Never color alone:** "Overdue" has an icon and the word; "Done" has a tick, a struck-through title and the word. The overdue red and done green keep WCAG AA contrast in both themes and on wallpaper palettes (tested).
- **Adaptive where it matters:** an iOS alert with a red destructive action, an iOS switch, and a date wheel in a sheet on iOS; Material's calendar on Android.
- **The Undo SnackBar sits above the Add button,** not over it (the Tasks screen has its own `ScaffoldMessenger`).
- **At the largest text,** segments become a radio list, row icons stay level with their titles, and the status icon grows with its text.
- **Dynamic color** is offered only where the device has wallpaper colors: Android 12+, not iOS.

## Retaking them

1. A fresh install on the iPhone 17 Pro simulator: `xcrun simctl uninstall booted co.bitfuse.flutter.cleanstarter`, then `fvm flutter run`.
2. Fix the status bar: `xcrun simctl status_bar booted override --time 9:41 --batteryState charged --batteryLevel 100`.
3. Dark mode and text size: `xcrun simctl ui booted appearance dark`, `xcrun simctl ui booted content_size accessibility-extra-extra-extra-large`.
4. Capture with `xcrun simctl io booted screenshot <file>.png`, and downscale with `sips -Z 1000`.
5. Afterwards: `xcrun simctl status_bar booted clear`, `appearance light`, `content_size large`.
6. For dynamic color, an Android 12+ emulator with a colorful wallpaper; `adb exec-out screencap -p > <file>.png`.

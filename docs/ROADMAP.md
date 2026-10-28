# Roadmap

The six build phases are complete. These are the ideas after them: each is something many apps need, but not every app, so the template points to how rather than shipping it.

## Template features

- **A first-launch / onboarding gate:** a `redirect` in `createAppRouter` reading a preference, with a `refreshListenable` (as in DevJourney and Evently).
- **Authentication:** a session `AuthBloc` above the router, the redirect reading it, tokens in `flutter_secure_storage`, and a 401 that ends the session (as in ConnectHub).
- **Notifications and background work,** behind `domain/service` interfaces, with a pure planner and a diffing sync (as in Momentum and Evently).
- **A real API with `dio`:** interceptors for auth and logging, retries with backoff, and a pending-changes table to send local edits (see [TEMPLATE_USAGE](TEMPLATE_USAGE.md#5-replace-the-fake-api-with-a-real-one)).
- **Flavors** (dev / staging / prod): `--dart-define-from-file`, an `@Environment` per flavor in `injectable`, and an app ID suffix per flavor.
- **Localization:** `intl` + ARB files with `flutter gen-l10n`; the date labels already go through `intl`.
- **A multi-package version:** the layers as packages (project 08, ModularHub).
- **`tool/rename.dart` also renaming class names** (`StarterApp`) and the README's title.
- **An iOS launch screen that follows the device's appearance** (today's is white before the first frame).
- **Tablets and landscape:** a `NavigationRail` instead of the bar, and a list beside the detail.

## The Tasks sample

- Filters (open, done, overdue) and search.
- Sections by due date (Overdue, Today, This week, Later).
- A "today" that moves at midnight while the app is open.
- Reminders for due dates.
- A title counter in the form.

## Quality

- Golden tests for the design system's widgets, in both themes.
- Integration tests on a device (`integration_test`), in CI on an emulator.
- A coverage report in CI.

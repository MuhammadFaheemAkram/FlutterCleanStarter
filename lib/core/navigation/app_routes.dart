import 'package:flutter_clean_starter/features/settings/settings_page.dart';
import 'package:flutter_clean_starter/features/shell/main_shell.dart';
import 'package:flutter_clean_starter/features/task_detail/task_detail_page.dart';
import 'package:flutter_clean_starter/features/task_form/task_form_page.dart';
import 'package:flutter_clean_starter/features/tasks/tasks_page.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'app_routes.g.dart';

// Typed routes: every destination is a class, and `go_router_builder`
// generates its path parsing, `location` getter and `go`/`push` helpers. A
// typo or a missing parameter is a compile error instead of a runtime "page
// not found".
//
// The tree has two parts:
// 1. the tab shell: Tasks and Settings;
// 2. root-level screens, pushed *above* the shell: a task, and the task form.
//
// A new feature adds its routes here: a tab is a new branch (and an `AppTab`),
// a pushed screen a new top-level route.

// ---------------------------------------------------------------------------
// 1. The tab shell

/// `StatefulShellRoute` gives every tab its own Navigator and keeps inactive
/// tabs alive in an IndexedStack, so switching tabs preserves each tab's
/// state (a scroll position, a half-done choice).
@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<TasksBranch>(
      routes: [TypedGoRoute<TasksRoute>(path: '/tasks')],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [TypedGoRoute<SettingsRoute>(path: '/settings')],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(navigationShell: navigationShell);
  }
}

// A named navigator key per tab makes each back stack addressable (and
// readable in debugging tools).

class TasksBranch extends StatefulShellBranchData {
  const TasksBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'tasksTab');
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();

  static final GlobalKey<NavigatorState> $navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settingsTab');
}

class TasksRoute extends GoRouteData with $TasksRoute {
  const TasksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TasksPage();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

// ---------------------------------------------------------------------------
// 2. Root-level screens
//
// Declared at the top level, so they live in the *root* Navigator: pushing
// one covers the tab bar, and Back (or the iOS swipe) returns to the tab with
// its state intact.

/// `/tasks/new`: the form for a new task, as a full-screen dialog (it slides
/// up and has a Close button), Material's counterpart of an iOS sheet.
///
/// Declared before [TaskDetailRoute]: go_router matches in order, and
/// `/tasks/:taskId` would otherwise read "new" as a task's id.
@TypedGoRoute<NewTaskRoute>(path: '/tasks/new')
class NewTaskRoute extends GoRouteData with $NewTaskRoute {
  const NewTaskRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const TaskFormPage(),
      );
}

/// `/tasks/:taskId`: one task, with its edit form as a child, so a link to
/// the form opens with the task underneath and Close returns to it.
@TypedGoRoute<TaskDetailRoute>(
  path: '/tasks/:taskId',
  routes: [TypedGoRoute<EditTaskRoute>(path: 'edit')],
)
class TaskDetailRoute extends GoRouteData with $TaskDetailRoute {
  const TaskDetailRoute({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TaskDetailPage(taskId: taskId);
}

/// `/tasks/:taskId/edit`: the same form as [NewTaskRoute], filled in.
class EditTaskRoute extends GoRouteData with $EditTaskRoute {
  const EditTaskRoute({required this.taskId});

  final String taskId;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      MaterialPage<void>(
        key: state.pageKey,
        fullscreenDialog: true,
        child: TaskFormPage(taskId: taskId),
      );
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, unused_field

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mainShellRoute,
  $newTaskRoute,
  $taskDetailRoute,
];

RouteBase get $mainShellRoute => StatefulShellRouteData.$route(
  factory: $MainShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: TasksBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/tasks',
          hasOverriddenOnExit: false,
          factory: $TasksRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SettingsBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/settings',
          hasOverriddenOnExit: false,
          factory: $SettingsRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $TasksRoute on GoRouteData {
  static TasksRoute _fromState(GoRouterState state) => const TasksRoute();

  @override
  String get location => GoRouteData.$location('/tasks');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $newTaskRoute => GoRouteData.$route(
  path: '/tasks/new',
  hasOverriddenOnExit: false,
  factory: $NewTaskRoute._fromState,
);

mixin $NewTaskRoute on GoRouteData {
  static NewTaskRoute _fromState(GoRouterState state) => const NewTaskRoute();

  @override
  String get location => GoRouteData.$location('/tasks/new');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $taskDetailRoute => GoRouteData.$route(
  path: '/tasks/:taskId',
  hasOverriddenOnExit: false,
  factory: $TaskDetailRoute._fromState,
  routes: [
    GoRouteData.$route(
      path: 'edit',
      hasOverriddenOnExit: false,
      factory: $EditTaskRoute._fromState,
    ),
  ],
);

mixin $TaskDetailRoute on GoRouteData {
  static TaskDetailRoute _fromState(GoRouterState state) =>
      TaskDetailRoute(taskId: state.pathParameters['taskId']!);

  TaskDetailRoute get _self => this as TaskDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/tasks/${Uri.encodeComponent(_self.taskId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EditTaskRoute on GoRouteData {
  static EditTaskRoute _fromState(GoRouterState state) =>
      EditTaskRoute(taskId: state.pathParameters['taskId']!);

  EditTaskRoute get _self => this as EditTaskRoute;

  @override
  String get location =>
      GoRouteData.$location('/tasks/${Uri.encodeComponent(_self.taskId)}/edit');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

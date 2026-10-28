import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Creates the app's [GoRouter].
///
/// A factory rather than a global: the app widget owns one router for its
/// lifetime, and every widget test starts from a fresh one.
///
/// There is no first-launch gate: an app that needs onboarding adds a
/// `redirect` here (with a `refreshListenable` for the flag it reads).
GoRouter createAppRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? const TasksRoute().location,
    routes: $appRoutes,
    errorBuilder: (context, state) =>
        _NotFoundPage(location: state.uri.toString()),
  );
}

/// Shown when a location matches no route, e.g. a mistyped deep link.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyStateView(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'Nothing lives at "$location".',
        action: FilledButton.tonal(
          onPressed: () => const TasksRoute().go(context),
          child: const Text('Go to Tasks'),
        ),
      ),
    );
  }
}

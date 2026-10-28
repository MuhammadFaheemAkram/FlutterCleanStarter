import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: themes and the router.
///
/// This `State` owns the router and disposes it. The router is created once,
/// not in `build`: a new router on every rebuild would reset navigation. The
/// app-scoped `SettingsCubit` goes here, above `MaterialApp.router`, for the
/// theme mode and dynamic color.
class StarterApp extends StatefulWidget {
  const StarterApp({super.key, this.initialLocation});

  /// Lets tests start on a deep link. The app itself starts on Tasks.
  final String? initialLocation;

  @override
  State<StarterApp> createState() => _StarterAppState();
}

class _StarterAppState extends State<StarterApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clean Starter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}

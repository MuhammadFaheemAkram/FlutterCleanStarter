import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_router.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_state.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The root widget: the app-wide settings, the themes, and the router.
///
/// This `State` owns the router and disposes it. The router is created once,
/// not in `build`: a new router on every rebuild would reset navigation.
/// The `SettingsCubit` sits above `MaterialApp.router`, so a theme change
/// rebuilds the app's theme, never its routes.
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
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..load(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.dynamicSeed != current.dynamicSeed ||
            previous.settings.themeMode != current.settings.themeMode,
        builder: (context, state) {
          final seed = state.dynamicSeed;
          return MaterialApp.router(
            title: 'Clean Starter',
            debugShowCheckedModeBanner: false,
            theme: seed == null
                ? AppTheme.light()
                : AppTheme.fromSeed(Color(seed), Brightness.light),
            darkTheme: seed == null
                ? AppTheme.dark()
                : AppTheme.fromSeed(Color(seed), Brightness.dark),
            themeMode: switch (state.settings.themeMode) {
              AppThemeMode.system => ThemeMode.system,
              AppThemeMode.light => ThemeMode.light,
              AppThemeMode.dark => ThemeMode.dark,
            },
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

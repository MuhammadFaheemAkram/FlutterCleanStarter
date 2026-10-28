import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:flutter_clean_starter/domain/model/app_settings.dart';
import 'package:flutter_clean_starter/domain/model/device_info.dart';
import 'package:flutter_clean_starter/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_clean_starter/features/settings/widgets/tasks_demo_section.dart';
import 'package:material_ui/material_ui.dart';

/// The Settings tab. The app-wide `SettingsCubit` is already above the
/// router; this Page adds the screen's own Cubits and the app's info.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The Tasks sample's section (Reset demo data) and its Cubit. Without
    // the sample, this is just `SettingsView(appInfo: getIt<AppInfo>())`.
    return BlocProvider(
      create: (_) => getIt<TasksDemoCubit>(),
      child: SettingsView(
        appInfo: getIt<AppInfo>(),
        dataSection: const TasksDemoSection(),
      ),
    );
  }
}

/// Appearance, a feature's data section, and About.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.appInfo, this.dataSection});

  final AppInfo appInfo;

  /// A feature's own settings (the Tasks sample's Reset demo data), between
  /// Appearance and About.
  final Widget? dataSection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.large),
        children: [
          const SectionHeader('Appearance'),
          const _Appearance(),
          ?dataSection,
          const SectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(appInfo.name),
            subtitle: Text('Version ${appInfo.versionLabel}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.xSmall,
            ),
            child: Text(
              'A starter template for Flutter apps: clean architecture, '
              'dependency injection, a local database, a fake API, '
              'navigation, tests and CI, with a small Tasks sample to '
              'replace with your own features.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Appearance extends StatelessWidget {
  const _Appearance();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final state = context.watch<SettingsCubit>().state;
    final mode = state.settings.themeMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Three segments fit a phone at normal sizes; at large text a radio
        // list keeps every label whole.
        if (context.prefersStackedLayout)
          RadioGroup<AppThemeMode>(
            groupValue: mode,
            onChanged: (mode) {
              if (mode != null) cubit.setThemeMode(mode);
            },
            child: Column(
              children: [
                for (final option in AppThemeMode.values)
                  RadioListTile<AppThemeMode>(
                    value: option,
                    title: Text(option.label),
                  ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.xSmall,
            ),
            child: SegmentedChoice<AppThemeMode>(
              values: AppThemeMode.values,
              labelOf: (mode) => mode.label,
              selected: mode,
              onSelected: cubit.setThemeMode,
            ),
          ),
        // Android 12+ only: elsewhere the device has no wallpaper palette.
        if (state.deviceColors.supportsDynamicColor)
          SwitchListTile.adaptive(
            title: const Text('Dynamic color'),
            subtitle: const Text('Use the colors of your wallpaper'),
            value: state.settings.dynamicColor,
            onChanged: (enabled) => cubit.setDynamicColor(enabled: enabled),
          ),
      ],
    );
  }
}

import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// The Settings tab: a placeholder until Phase 5 (appearance, dynamic color,
/// Reset demo data, About).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyStateView(
        icon: Icons.tune,
        title: 'Settings',
        message:
            'Appearance, dynamic color and the demo data arrive in '
            'Phase 5.',
      ),
    );
  }
}

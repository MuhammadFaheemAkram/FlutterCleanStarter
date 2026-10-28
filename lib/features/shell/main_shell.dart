import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The tabs, in the order of the shell's branches.
enum AppTab {
  tasks('Tasks', Icons.checklist_outlined, Icons.checklist),
  settings('Settings', Icons.settings_outlined, Icons.settings);

  const AppTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Hosts the bottom [NavigationBar] around the active tab.
///
/// [navigationShell] holds the tab navigators in an IndexedStack; this widget
/// only decides which branch is visible. Each tab screen brings its own
/// `Scaffold` and `AppBar`.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _selectTab(int index) {
    // Re-tapping the active tab returns it to its initial location (the
    // platform convention on both Android and iOS).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      // The tab labels keep their size whatever the text setting, as the
      // platforms' own tab bars do. A long press shows the label in a
      // tooltip, and screen readers read it.
      bottomNavigationBar: MediaQuery.withNoTextScaling(
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _selectTab,
          destinations: [
            for (final tab in AppTab.values)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
                tooltip: tab.label,
              ),
          ],
        ),
      ),
    );
  }
}

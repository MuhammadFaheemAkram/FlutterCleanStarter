import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:material_ui/material_ui.dart';

/// The Tasks tab: a placeholder until the list arrives with the data layer.
///
/// Its app bar and Add button are final; navigation happens here, in the
/// view, never in a Cubit.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const EmptyStateView(
        icon: Icons.checklist_outlined,
        title: 'No tasks yet',
        message: 'The list, stored on the device, arrives in Phase 3.',
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: () => const NewTaskRoute().push<void>(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

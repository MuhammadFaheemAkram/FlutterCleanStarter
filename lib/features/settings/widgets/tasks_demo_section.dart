import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/design_system/design_system.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_cubit.dart';
import 'package:flutter_clean_starter/features/settings/cubit/tasks_demo_state.dart';
import 'package:material_ui/material_ui.dart';

/// "Data": Reset demo data, after asking. The sample feature's section of
/// Settings: an app without the Tasks sample deletes this file, its Cubit,
/// and the one line that shows it.
class TasksDemoSection extends StatelessWidget {
  const TasksDemoSection({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final cubit = context.read<TasksDemoCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset demo data?',
      message:
          'Every task is replaced with the sample tasks. Tasks you added or '
          'changed are lost.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (confirmed) await cubit.reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TasksDemoCubit>().state;
    return BlocListener<TasksDemoCubit, TasksDemoState>(
      listenWhen: (previous, current) =>
          previous.messageSerial != current.messageSerial,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message ?? ''))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reset demo data'),
            subtitle: const Text('Replace every task with the sample tasks'),
            enabled: !state.resetting,
            trailing: state.resetting
                ? Semantics(
                    label: 'Resetting',
                    child: const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    ),
                  )
                : null,
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }
}

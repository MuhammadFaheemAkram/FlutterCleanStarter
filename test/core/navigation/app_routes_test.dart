import 'package:flutter_clean_starter/core/navigation/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tab routes have their own paths', () {
    expect(const TasksRoute().location, '/tasks');
    expect(const SettingsRoute().location, '/settings');
  });

  test('screens above the tabs build their locations from typed data', () {
    expect(const NewTaskRoute().location, '/tasks/new');
    expect(const TaskDetailRoute(taskId: 't1').location, '/tasks/t1');
    expect(const EditTaskRoute(taskId: 't1').location, '/tasks/t1/edit');
  });

  test('ids are encoded in the path', () {
    expect(const TaskDetailRoute(taskId: 'a b/c').location, '/tasks/a%20b%2Fc');
  });
}

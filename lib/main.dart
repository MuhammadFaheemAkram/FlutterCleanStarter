import 'package:flutter_clean_starter/app/starter_app.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  // Bindings must exist before any async setup touches plugins or assets.
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const StarterApp());
}

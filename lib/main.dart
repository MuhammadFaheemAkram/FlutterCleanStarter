import 'package:flutter_clean_starter/app/starter_app.dart';
import 'package:flutter_clean_starter/di/injection.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // Bindings must exist before any setup touches plugins or assets.
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const StarterApp());
}

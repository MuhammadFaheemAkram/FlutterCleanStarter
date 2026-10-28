import 'package:flutter_clean_starter/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// The app's single service locator.
///
/// Only `main.dart`, the app widget and Page widgets resolve dependencies
/// from it. Everything else receives them through its constructor, so tests
/// can pass fakes directly.
final GetIt getIt = GetIt.instance;

/// Composition root: the one place where concrete implementations are chosen
/// and wired together (the role of Hilt modules in the Android edition, and
/// `AppEnvironment` in the iOS one).
///
/// `injectable` generates `getIt.init()` from the annotations under `lib/`.
/// It becomes async once the preferences must be ready before the first
/// frame (`@preResolve`).
@InjectableInit()
void configureDependencies() => getIt.init();

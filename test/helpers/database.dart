import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_clean_starter/core/database/app_database.dart';

/// A fresh in-memory database. `closeStreamsSynchronously` lets widget tests
/// end without waiting on drift's stream timers (conventions §11.24).
AppDatabase newTestDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

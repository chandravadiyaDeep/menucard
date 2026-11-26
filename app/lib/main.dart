import 'package:flutter/material.dart';
import 'app.dart';
import 'data/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Open local SQLite storage before rendering the owner workspace.
  final database = AppDatabase();
  runApp(MenuCardApp(database: database));
}

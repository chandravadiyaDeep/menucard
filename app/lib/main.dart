import 'package:flutter/material.dart';

import 'app.dart';
import 'data/menu_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load the durable local menu before exposing the owner workspace.
    final repository = await MenuRepository.open();
    runApp(MenuCardApp(repository: repository));
  } catch (error) {
    // Never replace an unreadable menu with an empty document without consent.
    runApp(MenuCardStartupError(error: error));
  }
}

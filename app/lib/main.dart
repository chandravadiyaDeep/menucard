import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/menu_repository.dart';
import 'data/offline_account_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Detect pre-account installs before MenuRepository creates a first-run JSON file.
    final documents = await getApplicationDocumentsDirectory();
    final hadExistingMenu = await File(p.join(documents.path, 'shop-menu.json')).exists();

    // Open private menu and account JSON repositories before showing the workspace.
    final repository = await MenuRepository.open();
    final accounts = await OfflineAccountRepository.open(
      grandfatherExistingInstall: hadExistingMenu,
    );
    runApp(MenuCardApp(repository: repository, accountRepository: accounts));
  } catch (error) {
    // Preserve unreadable local data rather than silently replacing it.
    runApp(MenuCardStartupError(error: error));
  }
}

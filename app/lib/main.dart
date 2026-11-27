import 'package:material_ui/material_ui.dart';
import 'app.dart';
import 'data/menu_repository.dart';
import 'data/offline_account_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Open private menu and account JSON repositories before showing the workspace.
    final repository = await MenuRepository.open();
    final accounts = await OfflineAccountRepository.open();
    runApp(MenuCardApp(repository: repository, accountRepository: accounts));
  } catch (error) {
    // Preserve unreadable local data rather than silently replacing it.
    runApp(MenuCardStartupError(error: error));
  }
}

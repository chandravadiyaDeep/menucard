import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/app.dart';
import 'package:menucard/data/menu_repository.dart';

void main() {
  testWidgets('MenuCard home and navigation render without hanging', (tester) async {
    debugPrint('MenuCard widget smoke: create local repository');
    final sandbox = await Directory.systemTemp.createTemp('menucard-widget-');
    final repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
    await repository.saveShop(
      name: 'Test Cafe',
      description: 'A local test shop',
      translationLocale: 'en',
      defaultLocale: 'en',
    );

    debugPrint('MenuCard widget smoke: mount application');
    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));

    debugPrint('MenuCard widget smoke: assert dashboard');
    expect(find.text('MenuCard'), findsOneWidget);
    expect(find.textContaining('Your menu,'), findsOneWidget);
    expect(find.text('Test Cafe'), findsOneWidget);

    debugPrint('MenuCard widget smoke: navigate to menu');
    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Build your menu.'), findsOneWidget);

    debugPrint('MenuCard widget smoke: dispose and cleanup');
    await tester.pumpWidget(const SizedBox.shrink());
    repository.dispose();
    await sandbox.delete(recursive: true);
    debugPrint('MenuCard widget smoke: complete');
  });
}

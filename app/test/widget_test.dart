import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/app.dart';
import 'package:menucard/data/menu_repository.dart';

void main() {
  testWidgets('MenuCard dashboard displays saved shop profile', (tester) async {
    late Directory sandbox;
    late MenuRepository repository;

    // Run real file operations outside the widget test's fake-async clock.
    await tester.runAsync(() async {
      sandbox = await Directory.systemTemp.createTemp('menucard-widget-');
      repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
      await repository.saveShop(
        name: 'Test Cafe',
        description: 'A local test shop',
        translationLocale: 'en',
        defaultLocale: 'en',
      );
    });

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MenuCard'), findsOneWidget);
    expect(find.textContaining('Your menu,'), findsOneWidget);
    expect(find.text('Test Cafe'), findsOneWidget);

    // Dispose the widget before closing its local repository and test directory.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      repository.dispose();
      await sandbox.delete(recursive: true);
    });
  });
}

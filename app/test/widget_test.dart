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
  testWidgets('first-run setup offers language and shop-type questions', (tester) async {
    late Directory sandbox;
    late MenuRepository repository;

    // Use a real temporary JSON file so onboarding is backed by the production repository.
    await tester.runAsync(() async {
      sandbox = await Directory.systemTemp.createTemp('menucard-onboarding-');
      repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
    });

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(find.text('New to MenuCard?'), 250);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Let’s set up your shop'), findsOneWidget);
    expect(find.text('2. Which language should your menu use?'), findsOneWidget);
    expect(find.text('3. What kind of shop do you run?'), findsOneWidget);
    expect(find.text('Create my menu'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      repository.dispose();
      await sandbox.delete(recursive: true);
    });
  });

}

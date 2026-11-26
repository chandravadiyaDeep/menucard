import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/app.dart';
import 'package:menucard/data/menu_repository.dart';

void main() {
  testWidgets('owner dashboard renders saved menu and opens menu studio', (tester) async {
    late Directory sandbox;
    late MenuRepository repository;

    // Real file I/O must run outside the widget test's fake-async clock.
    await tester.runAsync(() async {
      sandbox = await Directory.systemTemp.createTemp('menucard-widget-');
      repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
      await repository.saveShop(
        name: 'Test Cafe',
        description: 'A local test shop',
        translationLocale: 'en',
        defaultLocale: 'en',
      );
      await repository.saveCategory(title: 'Drinks', locale: 'en');
      final category = repository.document.categories.single;
      await repository.saveItem(
        categoryId: category.id,
        name: 'Masala Chai',
        description: 'Freshly brewed tea',
        locale: 'en',
        priceMinor: 1500,
        available: true,
      );
    });

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('MenuCard'), findsOneWidget);
    expect(find.textContaining('Your menu,'), findsOneWidget);
    expect(find.text('Test Cafe'), findsOneWidget);
    // Verify that the primary navigation opens the real menu editor screen.
    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Build your menu.'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Masala Chai'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      repository.dispose();
      await sandbox.delete(recursive: true);
    });
  });
}

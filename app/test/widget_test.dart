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

  testWidgets('menu search narrows dishes across categories', (tester) async {
    late Directory sandbox;
    late MenuRepository repository;

    // Seed a local shop and sample menu before opening the editor.
    await tester.runAsync(() async {
      sandbox = await Directory.systemTemp.createTemp('menucard-search-');
      repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
      await repository.saveShop(
        name: 'Search Cafe',
        description: '',
        translationLocale: 'en',
        defaultLocale: 'en',
      );
      await repository.saveCategory(title: 'Drinks', locale: 'en');
      await repository.saveCategory(title: 'Snacks', locale: 'en');
      final drinks = repository.document.categories.first;
      final snacks = repository.document.categories.last;
      await repository.saveItem(
        categoryId: drinks.id,
        name: 'Masala Chai',
        description: 'Ginger tea',
        locale: 'en',
        priceMinor: 2000,
        available: true,
      );
      await repository.saveItem(
        categoryId: snacks.id,
        name: 'Samosa',
        description: 'Potato snack',
        locale: 'en',
        priceMinor: 1500,
        available: false,
      );
    });

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('My menu'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) => widget is TextField &&
          widget.decoration?.hintText == 'Search dishes, descriptions or categories',
    );
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'chai');
    await tester.pumpAndSettle();

    expect(find.text('Masala Chai'), findsOneWidget);
    expect(find.text('Samosa'), findsNothing);
    expect(find.text('No matching menu items'), findsNothing);

    // Empty results expose one-tap filter reset instead of trapping the owner.
    await tester.enterText(searchField, 'not-a-real-dish');
    await tester.pumpAndSettle();
    expect(find.text('Clear all filters'), findsOneWidget);
    await tester.tap(find.text('Clear all filters'));
    await tester.pumpAndSettle();
    expect(find.text('Masala Chai'), findsOneWidget);
    expect(find.text('Samosa'), findsOneWidget);

    // Availability chips narrow the menu without changing the saved items.
    await tester.tap(find.text('Paused'));
    await tester.pumpAndSettle();
    expect(find.text('Samosa'), findsOneWidget);
    expect(find.text('Masala Chai'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      repository.dispose();
      await sandbox.delete(recursive: true);
    });
  });

  testWidgets('customer preview is reachable from Home and My menu', (tester) async {
    late Directory sandbox;
    late MenuRepository repository;

    // Preview navigation is tested without invoking the native WebView plugin.
    await tester.runAsync(() async {
      sandbox = await Directory.systemTemp.createTemp('menucard-preview-entry-');
      repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
      await repository.saveShop(
        name: 'Preview Cafe',
        description: '',
        translationLocale: 'en',
        defaultLocale: 'en',
      );
      await repository.saveCategory(title: 'Drinks', locale: 'en');
      await repository.saveItem(
        categoryId: repository.document.categories.single.id,
        name: 'Masala Chai',
        description: 'Fresh ginger tea',
        locale: 'en',
        priceMinor: 2000,
        available: true,
      );
    });

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('home-customer-preview')), findsOneWidget);

    await tester.tap(find.text('My menu'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('menu-customer-preview')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      repository.dispose();
      await sandbox.delete(recursive: true);
    });
  });

}

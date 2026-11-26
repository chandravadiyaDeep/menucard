import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/app.dart';
import 'package:menucard/data/menu_repository.dart';

void main() {
  testWidgets('MenuCard V1 home workspace renders its navigation and local state', (tester) async {
    final sandbox = await Directory.systemTemp.createTemp('menucard-widget-');
    final repository = await MenuRepository.openAt(File('${sandbox.path}/menu.json'));
    await repository.saveShop(
      name: 'Test Cafe',
      description: 'A local test shop',
      translationLocale: 'en',
      defaultLocale: 'en',
    );

    await tester.pumpWidget(MenuCardApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('MenuCard'), findsOneWidget);
    expect(find.textContaining('Your menu,'), findsOneWidget);
    expect(find.text('Test Cafe'), findsOneWidget);
    expect(find.text('My menu'), findsOneWidget);
    expect(find.text('Publish'), findsOneWidget);

    await tester.tap(find.text('My menu'));
    await tester.pumpAndSettle();
    expect(find.text('Build your menu.'), findsOneWidget);

    // Dispose the widget tree before closing its ChangeNotifier repository.
    await tester.pumpWidget(const SizedBox.shrink());
    repository.dispose();
    await sandbox.delete(recursive: true);
  });
}

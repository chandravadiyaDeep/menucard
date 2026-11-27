import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/data/menu_repository.dart';
import 'package:menucard/design/menu_template_catalog.dart';

void main() {
  late Directory sandbox;
  late File file;
  late MenuRepository repository;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('menucard-tests-');
    file = File('${sandbox.path}/shop-menu.json');
    repository = await MenuRepository.openAt(file);
  });

  tearDown(() async {
    repository.dispose();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('new install creates a versioned local JSON document', () async {
    expect(await file.exists(), isTrue);
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    expect(data['schema_version'], 1);
    expect(data['revision'], 1);
    expect(data['local_publish'], isA<Map>());
  });

  test('shop, category and item changes survive a reload', () async {
    await repository.saveShop(
      name: 'Nukkad Cafe',
      description: 'Tea and snacks',
      translationLocale: 'en',
      defaultLocale: 'en',
      address: 'Main market',
      phone: '9999999999',
    );
    await repository.saveCategory(title: 'Tea', locale: 'en');
    final category = repository.document.categories.single;
    await repository.saveItem(
      categoryId: category.id,
      name: 'Masala chai',
      description: 'Freshly brewed',
      locale: 'en',
      priceMinor: 1500,
      available: true,
    );

    final reloaded = await MenuRepository.openAt(file);
    expect(reloaded.document.shop.name['en'], 'Nukkad Cafe');
    expect(reloaded.document.categories.single.items.single.nameFor('en', 'en'), 'Masala chai');
    expect(reloaded.document.categories.single.items.single.priceMinor, 1500);
    reloaded.dispose();
  });

  test('public JSON omits local publishing metadata and private file paths', () async {
    await repository.saveShop(
      name: 'Demo Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    await repository.saveCategory(title: 'Drinks', locale: 'en');
    final category = repository.document.categories.single;
    await repository.saveItem(
      categoryId: category.id,
      name: 'Water',
      description: '',
      locale: 'en',
      priceMinor: 1000,
      available: true,
      imagePath: '${sandbox.path}/private-image.jpg',
    );

    final publicJson = repository.document.toPublicJson();
    expect(publicJson.containsKey('local_publish'), isFalse);
    expect(publicJson.containsKey('qr_menu_url'), isFalse);
    final item = (publicJson['categories'] as List).single['items'].single as Map;
    expect(item.containsKey('image_path'), isFalse);
    expect(item['image'], 'assets/images/private-image.jpg');
  });

  test('negative price is rejected without changing the stored revision', () async {
    await repository.saveShop(
      name: 'Demo Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    await repository.saveCategory(title: 'Drinks', locale: 'en');
    final before = repository.document.revision;
    await expectLater(
      repository.saveItem(
        categoryId: repository.document.categories.single.id,
        name: 'Water',
        description: '',
        locale: 'en',
        priceMinor: -1,
        available: true,
      ),
      throwsArgumentError,
    );
    expect(repository.document.revision, before);
  });

  test('category deletion requires an explicit child-item decision', () async {
    await repository.saveShop(
      name: 'Demo Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    await repository.saveCategory(title: 'Snacks', locale: 'en');
    final category = repository.document.categories.single;
    await repository.saveItem(
      categoryId: category.id,
      name: 'Samosa',
      description: '',
      locale: 'en',
      priceMinor: 1200,
      available: true,
    );
    await expectLater(repository.deleteCategory(category.id, deleteItems: false), throwsArgumentError);
    expect(repository.document.categories.single.items, hasLength(1));
    await repository.deleteCategory(category.id, deleteItems: true);
    expect(repository.document.categories, isEmpty);
  });

  test('QR menu link saves locally without requiring a website publish confirmation', () async {
    await repository.saveQrMenuUrl('https://example.com/menu');

    expect(repository.document.qrMenuUrl, 'https://example.com/menu');
    expect(repository.document.publishedUrl, isNull);

    final reloaded = await MenuRepository.openAt(file);
    expect(reloaded.document.qrMenuUrl, 'https://example.com/menu');
    reloaded.dispose();

    await expectLater(
      repository.saveQrMenuUrl('http://example.com/menu'),
      throwsArgumentError,
    );
    await expectLater(
      repository.saveQrMenuUrl('https://user:password@example.com/menu'),
      throwsArgumentError,
    );
  });

  test('published confirmation requires HTTPS and does not change menu revision', () async {
    await repository.saveShop(
      name: 'Demo Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    final revision = repository.document.revision;
    await expectLater(repository.confirmPublished('http://example.com'), throwsArgumentError);
    await expectLater(
      repository.confirmPublished('https://example.com/menu/'),
      throwsArgumentError,
    );
    // The owner must export this exact revision before confirming the upload.
    await repository.recordExported(revision);
    await repository.confirmPublished('https://example.com/menu/');
    expect(repository.document.publishedUrl, 'https://example.com/menu/');
    expect(repository.document.publishedRevision, revision);
    expect(repository.document.revision, revision);
  });

  test('corrupt primary JSON recovers from the last valid copy', () async {
    await repository.saveShop(
      name: 'Saved Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    final savedName = repository.document.shop.name['en'];
    await file.writeAsString('{invalid json');
    final recovered = await MenuRepository.openAt(file);
    expect(recovered.document.shop.name['en'], savedName);
    recovered.dispose();
  });

  test('parallel owner actions are serialized without losing menu changes', () async {
    await repository.saveShop(
      name: 'Concurrent Cafe',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );

    // Simulate fast repeated taps that trigger multiple local writes together.
    await Future.wait([
      repository.saveCategory(title: 'Hot Drinks', locale: 'en'),
      repository.saveCategory(title: 'Cold Drinks', locale: 'en'),
      repository.saveCategory(title: 'Snacks', locale: 'en'),
    ]);

    expect(repository.document.categories, hasLength(3));
    final reloaded = await MenuRepository.openAt(file);
    expect(reloaded.document.categories, hasLength(3));
    reloaded.dispose();
  });

  test('editing and moving an item preserves its stable ID and updates price', () async {
    await repository.saveShop(
      name: 'Edit Test Shop',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    await repository.saveCategory(title: 'Drinks', locale: 'en');
    await repository.saveCategory(title: 'Snacks', locale: 'en');
    final drinks = repository.document.categories[0];
    final snacks = repository.document.categories[1];

    await repository.saveItem(
      categoryId: drinks.id,
      name: 'Lemon Soda',
      description: 'Fresh',
      locale: 'en',
      priceMinor: 2000,
      available: true,
    );
    final original = repository.document.categories.firstWhere((entry) => entry.id == drinks.id).items.single;

    await repository.saveItem(
      id: original.id,
      categoryId: snacks.id,
      name: 'Lemon Soda Large',
      description: 'Updated',
      locale: 'en',
      priceMinor: 3000,
      available: false,
    );

    // Repository mutations replace the document snapshot, so assert against the latest state.
    final latestDrinks = repository.document.categories.firstWhere((entry) => entry.id == drinks.id);
    final latestSnacks = repository.document.categories.firstWhere((entry) => entry.id == snacks.id);
    expect(latestDrinks.items, isEmpty);
    expect(latestSnacks.items, hasLength(1));
    expect(latestSnacks.items.single.id, original.id);
    expect(latestSnacks.items.single.priceMinor, 3000);
    expect(latestSnacks.items.single.available, isFalse);
    expect(latestSnacks.items.single.nameFor('en', 'en'), 'Lemon Soda Large');
  });


  test('template library provides at least 100 unique ready-made designs', () {
    expect(MenuTemplateCatalog.all.length, greaterThanOrEqualTo(100));
    expect(MenuTemplateCatalog.all.map((entry) => entry.id).toSet(), hasLength(MenuTemplateCatalog.all.length));
    expect(MenuTemplateCatalog.byId(MenuTemplateCatalog.defaultId).layoutId, 'classic');
  });

  test('selected ready-made design persists and is included in customer JSON', () async {
    await repository.saveShop(
      name: 'Template Test Cafe',
      description: '',
      translationLocale: 'en',
      defaultLocale: 'en',
    );
    await repository.setTemplate('editorial-terracotta');

    final publicJson = repository.document.toPublicJson();
    expect(publicJson['template_id'], 'editorial-terracotta');
    expect(publicJson.containsKey('template_selected'), isFalse);

    final reloaded = await MenuRepository.openAt(file);
    expect(reloaded.document.templateId, 'editorial-terracotta');
    expect(reloaded.document.templateSelected, isTrue);
    reloaded.dispose();
  });

}

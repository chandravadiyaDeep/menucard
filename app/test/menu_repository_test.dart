import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/data/menu_repository.dart';

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
}

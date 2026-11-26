import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'menu_document.dart';

/// Owns all local JSON reads, writes and menu mutations.
class MenuRepository extends ChangeNotifier {
  MenuRepository._(this.file, this._document);

  final File file;
  MenuDocument _document;
  static const _uuid = Uuid();

  MenuDocument get document => _document;

  static Future<MenuRepository> open() async {
    final directory = await getApplicationDocumentsDirectory();
    return openAt(File(p.join(directory.path, 'shop-menu.json')));
  }

  /// File injection makes repository behavior testable without platform plugins.
  static Future<MenuRepository> openAt(File file) async {
    await file.parent.create(recursive: true);
    if (!await file.exists()) {
      final document = MenuDocument.createDefault();
      final repository = MenuRepository._(file, document);
      await repository._write(document);
      return repository;
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        throw const FormatException('The local menu is not a JSON object.');
      }
      return MenuRepository._(file, MenuDocument.fromJson(Map<String, dynamic>.from(decoded)));
    } catch (primaryError) {
      // Recover only from a previously validated backup; never silently erase the damaged file.
      final backup = File('${file.path}.bak');
      if (await backup.exists()) {
        try {
          final decoded = jsonDecode(await backup.readAsString());
          if (decoded is Map) {
            final recovered = MenuDocument.fromJson(Map<String, dynamic>.from(decoded));
            final repository = MenuRepository._(file, recovered);
            await repository._write(recovered);
            return repository;
          }
        } catch (_) {
          // Both copies are invalid; report the recovery failure below.
        }
      }
      throw FormatException('Your local menu could not be read. Keep this app data intact and contact support. Details: $primaryError');
    }
  }

  Future<void> saveShop({
    required String name,
    required String description,
    required String translationLocale,
    required String defaultLocale,
    String? phone,
    String? address,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Enter your shop name.');
    }
    await _mutate((next) {
      _ensureLanguage(next, translationLocale);
      _ensureLanguage(next, defaultLocale);
      next.shop.name[translationLocale] = cleanName;
      next.shop.description[translationLocale] = description.trim();
      next.shop.phone = phone?.trim() ?? '';
      next.shop.address = address?.trim() ?? '';
      next.defaultLocale = defaultLocale;
    });
  }

  Future<void> saveCategory({
    String? id,
    required String title,
    required String locale,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('Enter a category name.');
    }
    await _mutate((next) {
      _ensureLanguage(next, locale);
      final category = id == null
          ? MenuCategory(id: _uuid.v4(), sortOrder: next.categories.length, translations: {})
          : next.categories.firstWhere((entry) => entry.id == id,
              orElse: () => throw ArgumentError('Category no longer exists.'));
      category.translations.putIfAbsent(locale, () => {})['title'] = cleanTitle;
      if (id == null) {
        next.categories.add(category);
      }
    });
  }

  Future<void> deleteCategory(String id, {required bool deleteItems}) async {
    await _mutate((next) {
      final category = next.categories.firstWhere((entry) => entry.id == id,
          orElse: () => throw ArgumentError('Category no longer exists.'));
      if (category.items.isNotEmpty && !deleteItems) {
        throw ArgumentError('Choose what to do with the items in this category.');
      }
      next.categories.removeWhere((entry) => entry.id == id);
      for (var index = 0; index < next.categories.length; index++) {
        next.categories[index].sortOrder = index;
      }
    });
  }

  Future<void> saveItem({
    String? id,
    required String categoryId,
    required String name,
    required String description,
    required String locale,
    required int priceMinor,
    required bool available,
    String? imagePath,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Enter an item name.');
    }
    if (priceMinor < 0) {
      throw ArgumentError('Price cannot be negative.');
    }
    await _mutate((next) {
      _ensureLanguage(next, locale);
      final category = next.categories.firstWhere((entry) => entry.id == categoryId,
          orElse: () => throw ArgumentError('Choose a valid category.'));
      MenuItem item;
      if (id == null) {
        item = MenuItem(
          id: _uuid.v4(),
          sortOrder: category.items.length,
          priceMinor: priceMinor,
          available: available,
          translations: {},
          imagePath: imagePath,
        );
      } else {
        item = next.categories
            .expand((entry) => entry.items)
            .firstWhere((entry) => entry.id == id,
                orElse: () => throw ArgumentError('Menu item no longer exists.'));
        for (final other in next.categories) {
          other.items.removeWhere((entry) => entry.id == id);
        }
        item.sortOrder = category.items.length;
      }
      item.priceMinor = priceMinor;
      item.available = available;
      item.imagePath = imagePath;
      item.translations.putIfAbsent(locale, () => {})
        ..['name'] = cleanName
        ..['description'] = description.trim();
      category.items.add(item);
    });
  }

  Future<void> deleteItem(String id) async {
    await _mutate((next) {
      var removed = false;
      for (final category in next.categories) {
        removed = category.items.removeWhere((item) => item.id == id) > 0 || removed;
      }
      if (!removed) {
        throw ArgumentError('Menu item no longer exists.');
      }
    });
  }

  Future<void> setItemAvailability(String id, bool available) async {
    await _mutate((next) {
      final item = next.categories
          .expand((category) => category.items)
          .firstWhere((entry) => entry.id == id,
              orElse: () => throw ArgumentError('Menu item no longer exists.'));
      item.available = available;
    });
  }

  Future<String> importImage(File source) async {
    final extension = p.extension(source.path).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
      throw ArgumentError('Choose a JPG, PNG or WebP image.');
    }
    if (await source.length() > 10 * 1024 * 1024) {
      throw ArgumentError('Choose an image smaller than 10 MB.');
    }
    final imageDirectory = Directory(p.join(file.parent.path, 'images'));
    await imageDirectory.create(recursive: true);
    final destination = File(p.join(imageDirectory.path, '${_uuid.v4()}$extension'));
    await source.copy(destination.path);
    return destination.path;
  }

  Future<String> importImageBytes(String fileName, List<int> bytes) async {
    final extension = p.extension(fileName).toLowerCase();
    if (!['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
      throw ArgumentError('A backup contains an unsupported image format.');
    }
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw ArgumentError('A backup image is empty or larger than 10 MB.');
    }
    final imageDirectory = Directory(p.join(file.parent.path, 'images'));
    await imageDirectory.create(recursive: true);
    final destination = File(p.join(imageDirectory.path, '${_uuid.v4()}$extension'));
    await destination.writeAsBytes(bytes, flush: true);
    return destination.path;
  }

  Future<void> restoreDocument(MenuDocument restored) async {
    final next = restored.copy();
    next.revision = (_document.revision > next.revision ? _document.revision : next.revision) + 1;
    next.updatedAt = DateTime.now();
    next.exportedRevision = 0;
    next.validate();
    await _write(next);
    _document = next;
    notifyListeners();
  }

  Future<void> recordExported(int revision) async {
    final next = _document.copy();
    next.exportedRevision = revision;
    await _write(next);
    _document = next;
    notifyListeners();
  }

  Future<void> confirmPublished(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw ArgumentError('Enter a valid public HTTPS menu URL without credentials or fragments.');
    }
    if (_document.exportedRevision != _document.revision) {
      throw ArgumentError('Export the latest menu revision before confirming it as published.');
    }
    final next = _document.copy();
    next.publishedUrl = uri.toString();
    next.publishedRevision = next.revision;
    next.publishedAt = DateTime.now();
    await _write(next);
    _document = next;
    notifyListeners();
  }

  Future<void> _mutate(void Function(MenuDocument next) mutation) async {
    final next = _document.copy();
    mutation(next);
    next.revision = _document.revision + 1;
    next.updatedAt = DateTime.now();
    next.validate();
    await _write(next);
    _document = next;
    notifyListeners();
  }

  void _ensureLanguage(MenuDocument document, String locale) {
    if (!['en', 'gu', 'hi'].contains(locale)) {
      throw ArgumentError('Choose English, Gujarati or Hindi.');
    }
    if (!document.languages.contains(locale)) {
      document.languages.add(locale);
    }
  }

  /// Writes a validated temporary file, atomically swaps it, then refreshes recovery copy.
  Future<void> _write(MenuDocument document) async {
    document.validate();
    final temporary = File('${file.path}.tmp');
    final backup = File('${file.path}.bak');
    await file.parent.create(recursive: true);
    final encoded = const JsonEncoder.withIndent('  ').convert(document.toStorageJson());
    await temporary.writeAsString(encoded, flush: true);

    // Preserve the last valid main file before replacing it. The backup copy
    // is itself staged and renamed so an interrupted copy cannot corrupt it.
    if (await file.exists()) {
      final backupTemporary = File('${backup.path}.tmp');
      await file.copy(backupTemporary.path);
      await backupTemporary.rename(backup.path);
    }

    // On Android, rename within the same directory atomically replaces the file.
    await temporary.rename(file.path);
  }
}

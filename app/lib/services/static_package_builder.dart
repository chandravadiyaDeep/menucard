import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/menu_document.dart';
import '../data/menu_repository.dart';

/// Builds static customer packages and portable private backups on-device.
class StaticPackageBuilder {
  Future<File> buildWebsitePackage(MenuDocument document) async {
    document.validate();
    if (document.shop.name.values.every((name) => name.trim().isEmpty)) {
      throw ArgumentError('Add your shop name before publishing.');
    }

    final archive = Archive();
    await _addAsset(archive, 'index.html', 'assets/publish/index.html');
    await _addAsset(archive, 'assets/menu.css', 'assets/publish/assets/menu.css');
    await _addAsset(archive, 'assets/menu.js', 'assets/publish/assets/menu.js');

    // Public JSON has no device paths or private publish metadata.
    final publicJson = document.toPublicJson();
    final imagePaths = <String>{};
    for (final category in document.categories) {
      for (final item in category.items) {
        if (item.imagePath != null) {
          imagePaths.add(item.imagePath!);
        }
      }
    }
    for (final imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw FileSystemException('A menu image is missing. Edit the item and choose its photo again.', imagePath);
      }
      final fileName = p.basename(imagePath);
      final bytes = await imageFile.readAsBytes();
      archive.addFile(ArchiveFile('assets/images/$fileName', bytes.length, bytes));
    }

    final jsonBytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(publicJson)),
    );
    archive.addFile(ArchiveFile('menu.json', jsonBytes.length, jsonBytes));

    final zipBytes = ZipEncoder().encode(archive);
    final directory = await getTemporaryDirectory();
    final shopSlug = document.shopId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    final output = File(p.join(directory.path, 'menucard-$shopSlug-r${document.revision}.zip'));
    await output.writeAsBytes(zipBytes, flush: true);
    return output;
  }

  /// Creates a private ZIP backup with relative image paths, so it can move devices safely.
  Future<File> buildPrivateBackup(MenuDocument document) async {
    document.validate();
    final archive = Archive();
    final snapshot = document.toStorageJson();
    final categories = snapshot['categories'] as List<dynamic>;
    final seenImages = <String>{};

    for (final rawCategory in categories) {
      final category = Map<String, dynamic>.from(rawCategory as Map);
      final items = category['items'] as List<dynamic>? ?? [];
      for (var index = 0; index < items.length; index++) {
        final item = Map<String, dynamic>.from(items[index] as Map);
        final imagePath = item['image_path']?.toString();
        if (imagePath != null) {
          final image = File(imagePath);
          if (!await image.exists()) {
            throw FileSystemException('A menu image is missing and cannot be backed up.', imagePath);
          }
          final name = p.basename(imagePath);
          final archiveName = 'images/$name';
          item['image_path'] = archiveName;
          if (seenImages.add(archiveName)) {
            final bytes = await image.readAsBytes();
            archive.addFile(ArchiveFile(archiveName, bytes.length, bytes));
          }
        }
        items[index] = item;
      }
      rawCategory
        ..clear()
        ..addAll(category);
    }

    final jsonBytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot)),
    );
    archive.addFile(ArchiveFile('menu-backup.json', jsonBytes.length, jsonBytes));
    final zipBytes = ZipEncoder().encode(archive);
    final directory = await getTemporaryDirectory();
    final output = File(p.join(directory.path, 'menucard-private-backup-r${document.revision}.zip'));
    await output.writeAsBytes(zipBytes, flush: true);
    return output;
  }

  /// Restores only the documented JSON and image entries; rejects path traversal entries.
  Future<void> restorePrivateBackup(List<int> bytes, MenuRepository repository) async {
    if (bytes.isEmpty || bytes.length > 50 * 1024 * 1024) {
      throw ArgumentError('Choose a valid backup ZIP smaller than 50 MB.');
    }
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    ArchiveFile? backupEntry;
    for (final entry in archive.files) {
      if (entry.isFile && entry.name == 'menu-backup.json') {
        backupEntry = entry;
        break;
      }
    }
    if (backupEntry == null) {
      throw const FormatException('This ZIP is not a MenuCard backup.');
    }

    final decoded = jsonDecode(utf8.decode(backupEntry.content as List<int>));
    if (decoded is! Map) {
      throw const FormatException('The backup menu JSON is invalid.');
    }
    final snapshot = Map<String, dynamic>.from(decoded);
    final categories = snapshot['categories'];
    if (categories is! List) {
      throw const FormatException('The backup categories are invalid.');
    }

    for (final rawCategory in categories) {
      final category = Map<String, dynamic>.from(rawCategory as Map);
      final items = category['items'] as List<dynamic>? ?? [];
      for (var index = 0; index < items.length; index++) {
        final item = Map<String, dynamic>.from(items[index] as Map);
        final savedPath = item['image_path']?.toString();
        if (savedPath != null) {
          if (!savedPath.startsWith('images/') || savedPath.contains('..') || savedPath.substring(7).contains('/')) {
            throw const FormatException('The backup contains an unsafe image path.');
          }
          ArchiveFile? imageEntry;
          for (final entry in archive.files) {
            if (entry.isFile && entry.name == savedPath) {
              imageEntry = entry;
              break;
            }
          }
          if (imageEntry == null) {
            throw const FormatException('A backup image is missing.');
          }
          final fileName = savedPath.substring(7);
          item['image_path'] = await repository.importImageBytes(fileName, imageEntry.content as List<int>);
        }
        items[index] = item;
      }
      rawCategory
        ..clear()
        ..addAll(category);
    }

    final restored = MenuDocument.fromJson(snapshot);
    await repository.restoreDocument(restored);
  }

  Future<void> _addAsset(Archive archive, String archivePath, String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
  }
}

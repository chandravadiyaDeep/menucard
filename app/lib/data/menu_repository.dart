import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';

class MenuRepository {
  MenuRepository(this.db);

  final AppDatabase db;
  static const _uuid = Uuid();

  Future<void> saveShop({
    required String name,
    required String locale,
    String? phone,
    String? address,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Enter a shop name.');
    }
    await (db.update(db.shopProfile)..where((row) => row.id.equals(1))).write(
      ShopProfileCompanion(
        name: Value(cleanName),
        defaultLocale: Value(locale),
        phone: Value(_emptyToNull(phone)),
        address: Value(_emptyToNull(address)),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  Future<void> addCategory(String title, String locale) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) throw ArgumentError('Enter a category name.');
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      await db.into(db.menuCategories).insert(
            MenuCategoriesCompanion.insert(
              id: id,
              sortOrder: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.contentTranslations).insert(
            ContentTranslationsCompanion.insert(
              entityType: 'category',
              entityId: id,
              fieldKey: 'title',
              locale: locale,
              value: cleanTitle,
            ),
          );
    });
  }

  Future<void> addItem({
    required String categoryId,
    required String name,
    required String description,
    required String locale,
    required double price,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Enter an item name.');
    if (!price.isFinite || price < 0) {
      throw ArgumentError('Enter a valid non-negative price.');
    }
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      await db.into(db.menuItems).insert(
            MenuItemsCompanion.insert(
              id: id,
              categoryId: categoryId,
              priceMinor: (price * 100).round(),
              sortOrder: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db.into(db.contentTranslations).insert(
            ContentTranslationsCompanion.insert(
              entityType: 'item',
              entityId: id,
              fieldKey: 'name',
              locale: locale,
              value: cleanName,
            ),
          );
      if (description.trim().isNotEmpty) {
        await db.into(db.contentTranslations).insert(
              ContentTranslationsCompanion.insert(
                entityType: 'item',
                entityId: id,
                fieldKey: 'description',
                locale: locale,
                value: description.trim(),
              ),
            );
      }
    });
  }

  Stream<List<CategoryWithItems>> watchMenu(String locale, String fallback) {
    return db.select(db.menuCategories).watch().asyncMap((categories) async {
      final result = <CategoryWithItems>[];
      for (final category in categories) {
        final title = await _translation(
          'category', category.id, 'title', locale, fallback,
        );
        final entries = await (db.select(db.menuItems)
              ..where((row) => row.categoryId.equals(category.id)))
            .get();
        final items = <MenuItemView>[];
        for (final item in entries) {
          final itemName = await _translation(
            'item', item.id, 'name', locale, fallback,
          );
          final desc = await _translation(
            'item', item.id, 'description', locale, fallback,
          );
          items.add(MenuItemView(
            id: item.id,
            name: itemName,
            description: desc,
            priceMinor: item.priceMinor,
            available: item.isAvailable,
          ));
        }
        result.add(CategoryWithItems(
          id: category.id,
          title: title,
          items: items,
        ));
      }
      return result;
    });
  }

  Future<String> _translation(
    String entityType,
    String entityId,
    String field,
    String locale,
    String fallback,
  ) async {
    final values = await (db.select(db.contentTranslations)
          ..where((row) =>
              row.entityType.equals(entityType) &
              row.entityId.equals(entityId) &
              row.fieldKey.equals(field)))
        .get();
    String? find(String language) {
      for (final row in values) {
        if (row.locale == language && row.value.trim().isNotEmpty) return row.value;
      }
      return null;
    }
    return find(locale) ?? find(fallback) ??
        values.firstWhere(
          (row) => row.value.trim().isNotEmpty,
          orElse: () => ContentTranslation(
            id: 0,
            entityType: entityType,
            entityId: entityId,
            fieldKey: field,
            locale: locale,
            value: '',
          ),
        ).value;
  }

  String? _emptyToNull(String? value) {
    final cleaned = value?.trim() ?? '';
    return cleaned.isEmpty ? null : cleaned;
  }
}

class CategoryWithItems {
  const CategoryWithItems({
    required this.id,
    required this.title,
    required this.items,
  });
  final String id;
  final String title;
  final List<MenuItemView> items;
}

class MenuItemView {
  const MenuItemView({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.available,
  });
  final String id;
  final String name;
  final String description;
  final int priceMinor;
  final bool available;
}

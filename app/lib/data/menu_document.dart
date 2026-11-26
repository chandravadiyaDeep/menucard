/// The versioned local JSON document that owns all shop/menu data.
class MenuDocument {
  MenuDocument({
    required this.shopId,
    required this.revision,
    required this.updatedAt,
    required this.defaultLocale,
    required this.languages,
    required this.shop,
    required this.categories,
    this.publishedUrl,
    this.publishedRevision = 0,
    this.publishedAt,
    this.exportedRevision = 0,
  });

  static const schemaVersion = 1;

  final String shopId;
  int revision;
  DateTime updatedAt;
  String defaultLocale;
  List<String> languages;
  ShopProfile shop;
  List<MenuCategory> categories;

  // Local-only publishing state. This is deliberately excluded from public JSON.
  String? publishedUrl;
  int publishedRevision;
  DateTime? publishedAt;
  int exportedRevision;

  factory MenuDocument.createDefault() {
    final now = DateTime.now();
    return MenuDocument(
      shopId: 'shop-${now.microsecondsSinceEpoch}',
      revision: 1,
      updatedAt: now,
      defaultLocale: 'en',
      languages: ['en', 'gu', 'hi'],
      shop: ShopProfile(),
      categories: [],
    );
  }

  factory MenuDocument.fromJson(Map<String, dynamic> json) {
    if (json['schema_version'] != schemaVersion) {
      throw FormatException(
        'This menu uses schema version ${json['schema_version']}, which this app cannot read.',
      );
    }
    final shopJson = _asMap(json['shop'], 'shop');
    final categoryValues = json['categories'];
    if (categoryValues is! List) {
      throw const FormatException('The menu categories field is invalid.');
    }
    final publish = json['local_publish'] is Map
        ? Map<String, dynamic>.from(json['local_publish'] as Map)
        : <String, dynamic>{};

    final document = MenuDocument(
      shopId: _requiredString(json['shop_id'], 'shop_id'),
      revision: _positiveInt(json['revision']),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          (throw const FormatException('The menu update date is invalid.')),
      defaultLocale: _requiredString(json['default_locale'], 'default_locale'),
      languages: (json['languages'] as List? ?? const ['en'])
          .map((value) => value.toString())
          .toSet()
          .toList(),
      shop: ShopProfile.fromJson(shopJson),
      categories: categoryValues
          .map((value) => MenuCategory.fromJson(_asMap(value, 'category')))
          .toList(),
      publishedUrl: publish['url']?.toString(),
      publishedRevision: _nonNegativeInt(publish['revision']),
      publishedAt: DateTime.tryParse(publish['at']?.toString() ?? ''),
      exportedRevision: _nonNegativeInt(publish['exported_revision']),
    );
    document.validate();
    return document;
  }

  /// Parse and serialize once to produce a safe independent editing snapshot.
  MenuDocument copy() => MenuDocument.fromJson(toStorageJson());

  Map<String, dynamic> toStorageJson() => {
        ...toPublicJson(),
        'categories': categories.map((category) => category.toStorageJson()).toList(),
        'local_publish': {
          'url': publishedUrl,
          'revision': publishedRevision,
          'at': publishedAt?.toIso8601String(),
          'exported_revision': exportedRevision,
        },
      };

  /// The customer-facing JSON contains only fields intended to be public.
  Map<String, dynamic> toPublicJson() => {
        'schema_version': schemaVersion,
        'shop_id': shopId,
        'revision': revision,
        'updated_at': updatedAt.toIso8601String(),
        'currency': 'INR',
        'default_locale': defaultLocale,
        'languages': languages,
        'shop': shop.toJson(),
        'categories': categories.map((category) => category.toPublicJson()).toList(),
      };

  void validate() {
    if (shopId.trim().isEmpty) throw const FormatException('Shop ID is missing.');
    if (revision < 1) throw const FormatException('Menu revision must be positive.');
    if (!['en', 'gu', 'hi'].contains(defaultLocale)) {
      throw const FormatException('Choose English, Gujarati or Hindi as the default language.');
    }
    if (languages.isEmpty || languages.any((language) => !['en', 'gu', 'hi'].contains(language))) {
      throw const FormatException('The menu contains an unsupported language.');
    }
    if (categories.length > 500) throw const FormatException('A menu can contain at most 500 categories.');

    final categoryIds = <String>{};
    final itemIds = <String>{};
    var totalItems = 0;
    for (final category in categories) {
      if (category.id.isEmpty || !categoryIds.add(category.id)) {
        throw const FormatException('The menu contains a duplicate or empty category ID.');
      }
      if (category.translations.values.every((value) => (value['title'] ?? '').trim().isEmpty)) {
        throw const FormatException('Every category needs a title in at least one language.');
      }
      totalItems += category.items.length;
      for (final item in category.items) {
        if (item.id.isEmpty || !itemIds.add(item.id) || item.priceMinor < 0) {
          throw const FormatException('A menu item has an invalid ID or price.');
        }
        if (item.translations.values.every((value) => (value['name'] ?? '').trim().isEmpty)) {
          throw const FormatException('Every menu item needs a name in at least one language.');
        }
        final imagePath = item.imagePath;
        if (imagePath != null &&
            (imagePath.contains('..') || imagePath.trim().isEmpty || !imagePath.startsWith('/'))) {
          throw const FormatException('A menu image reference is invalid.');
        }
      }
    }
    if (totalItems > 5000) throw const FormatException('A menu can contain at most 5,000 items.');
  }
}

class ShopProfile {
  ShopProfile({
    Map<String, String>? name,
    Map<String, String>? description,
    this.address = '',
    this.phone = '',
  })  : name = name ?? <String, String>{'en': ''},
        description = description ?? <String, String>{};

  Map<String, String> name;
  Map<String, String> description;
  String address;
  String phone;

  factory ShopProfile.fromJson(Map<String, dynamic> json) => ShopProfile(
        name: _stringMap(json['name']),
        description: _stringMap(json['description']),
        address: json['address']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
      };
}

class MenuCategory {
  MenuCategory({
    required this.id,
    required this.sortOrder,
    required this.translations,
    List<MenuItem>? items,
  }) : items = items ?? [];

  String id;
  int sortOrder;
  Map<String, Map<String, String>> translations;
  List<MenuItem> items;

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: _requiredString(json['id'], 'category.id'),
        sortOrder: _nonNegativeInt(json['sort_order']),
        translations: _translationMap(json['translations']),
        items: (json['items'] as List? ?? const [])
            .map((value) => MenuItem.fromJson(_asMap(value, 'item')))
            .toList(),
      );

  String titleFor(String locale, String fallback) =>
      _translatedValue(translations, 'title', locale, fallback);

  Map<String, dynamic> toStorageJson() => {
        'id': id,
        'sort_order': sortOrder,
        'translations': translations,
        'items': items.map((item) => item.toStorageJson()).toList(),
      };

  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'sort_order': sortOrder,
        'translations': translations,
        'items': items.map((item) => item.toPublicJson()).toList(),
      };
}

class MenuItem {
  MenuItem({
    required this.id,
    required this.sortOrder,
    required this.priceMinor,
    required this.available,
    required this.translations,
    this.imagePath,
  });

  String id;
  int sortOrder;
  int priceMinor;
  bool available;
  Map<String, Map<String, String>> translations;
  String? imagePath;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: _requiredString(json['id'], 'item.id'),
        sortOrder: _nonNegativeInt(json['sort_order']),
        priceMinor: _nonNegativeInt(json['price_minor']),
        available: json['available'] != false,
        translations: _translationMap(json['translations']),
        imagePath: json['image_path']?.toString(),
      );

  String nameFor(String locale, String fallback) =>
      _translatedValue(translations, 'name', locale, fallback);

  String descriptionFor(String locale, String fallback) =>
      _translatedValue(translations, 'description', locale, fallback);

  Map<String, dynamic> toStorageJson() => {
        'id': id,
        'sort_order': sortOrder,
        'price_minor': priceMinor,
        'available': available,
        'image_path': imagePath,
        'translations': translations,
      };

  Map<String, dynamic> toPublicJson() {
    final name = imagePath == null ? null : imagePath!.split(RegExp(r'[/\\]')).last;
    return {
      'id': id,
      'sort_order': sortOrder,
      'price_minor': priceMinor,
      'available': available,
      'image': name == null ? null : 'assets/images/$name',
      'translations': translations,
    };
  }
}

String _translatedValue(
  Map<String, Map<String, String>> translations,
  String field,
  String locale,
  String fallback,
) {
  for (final language in <String>{locale, fallback, ...translations.keys}) {
    final value = translations[language]?[field];
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return '';
}

Map<String, String> _stringMap(dynamic value) {
  if (value is! Map) return {};
  return value.map((key, item) => MapEntry(key.toString(), item?.toString() ?? ''));
}

Map<String, Map<String, String>> _translationMap(dynamic value) {
  if (value is! Map) return {};
  final output = <String, Map<String, String>>{};
  for (final entry in value.entries) {
    output[entry.key.toString()] = _stringMap(entry.value);
  }
  return output;
}

Map<String, dynamic> _asMap(dynamic value, String field) {
  if (value is! Map) throw FormatException('The $field data is invalid.');
  return Map<String, dynamic>.from(value);
}

String _requiredString(dynamic value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) throw FormatException('The $field field is missing.');
  return text;
}

int _positiveInt(dynamic value) {
  final result = value is int ? value : int.tryParse(value?.toString() ?? '');
  if (result == null || result < 1) throw const FormatException('A positive integer value is required.');
  return result;
}

int _nonNegativeInt(dynamic value) {
  final result = value is int ? value : int.tryParse(value?.toString() ?? '');
  if (result == null || result < 0) throw const FormatException('A non-negative integer value is required.');
  return result;
}

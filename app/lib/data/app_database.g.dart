// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated for the initial MenuCard database schema.
part of 'app_database.dart';

class $ShopProfileTable extends ShopProfile
    with TableInfo<$ShopProfileTable, ShopProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false,
      defaultValue: const CustomExpression<int>('1'));
  static const VerificationMeta _nameMeta = VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _phoneMeta = VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta = VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultLocaleMeta = VerificationMeta('defaultLocale');
  @override
  late final GeneratedColumn<String> defaultLocale = GeneratedColumn<String>(
      'default_locale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _updatedAtMeta = VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, address, defaultLocale, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'shop_profile';
  @override
  VerificationContext validateIntegrity(Insertable<ShopProfileData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    if (data.containsKey('name')) context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    if (data.containsKey('phone')) context.handle(_phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    if (data.containsKey('address')) context.handle(_addressMeta, address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    if (data.containsKey('default_locale')) context.handle(_defaultLocaleMeta, defaultLocale.isAcceptableOrUnknown(data['default_locale']!, _defaultLocaleMeta));
    if (data.containsKey('updated_at')) context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    return context;
  }
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopProfileData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}address']),
      defaultLocale: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}default_locale'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }
  @override
  $ShopProfileTable createAlias(String alias) => $ShopProfileTable(attachedDatabase, alias);
}
class ShopProfileData extends DataClass implements Insertable<ShopProfileData> {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String defaultLocale;
  final String updatedAt;
  const ShopProfileData({required this.id, required this.name, this.phone, this.address, required this.defaultLocale, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {
    'id': Variable<int>(id),
    'name': Variable<String>(name),
    if (!nullToAbsent || phone != null) 'phone': Variable<String>(phone),
    if (!nullToAbsent || address != null) 'address': Variable<String>(address),
    'default_locale': Variable<String>(defaultLocale),
    'updated_at': Variable<String>(updatedAt),
  };
  ShopProfileCompanion toCompanion(bool nullToAbsent) => ShopProfileCompanion(
    id: Value(id), name: Value(name), phone: phone == null && nullToAbsent ? const Value.absent() : Value(phone),
    address: address == null && nullToAbsent ? const Value.absent() : Value(address),
    defaultLocale: Value(defaultLocale), updatedAt: Value(updatedAt));
  factory ShopProfileData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopProfileData(
      id: serializer.fromJson<int>(json['id']), name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']), address: serializer.fromJson<String?>(json['address']),
      defaultLocale: serializer.fromJson<String>(json['defaultLocale']), updatedAt: serializer.fromJson<String>(json['updatedAt']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return {'id': serializer.toJson<int>(id), 'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone), 'address': serializer.toJson<String?>(address),
      'defaultLocale': serializer.toJson<String>(defaultLocale), 'updatedAt': serializer.toJson<String>(updatedAt)};
  }
  ShopProfileData copyWith({int? id, String? name, Value<String?> phone = const Value.absent(), Value<String?> address = const Value.absent(), String? defaultLocale, String? updatedAt}) =>
    ShopProfileData(id: id ?? this.id, name: name ?? this.name, phone: phone.present ? phone.value : this.phone,
      address: address.present ? address.value : this.address, defaultLocale: defaultLocale ?? this.defaultLocale, updatedAt: updatedAt ?? this.updatedAt);
  @override
  String toString() => 'ShopProfileData(id: $id, name: $name, phone: $phone, address: $address, defaultLocale: $defaultLocale, updatedAt: $updatedAt)';
  @override
  int get hashCode => Object.hash(id, name, phone, address, defaultLocale, updatedAt);
  @override
  bool operator ==(Object other) => identical(this, other) || other is ShopProfileData && other.id == id && other.name == name && other.phone == phone && other.address == address && other.defaultLocale == defaultLocale && other.updatedAt == updatedAt;
}
class ShopProfileCompanion extends UpdateCompanion<ShopProfileData> {
  final Value<int> id; final Value<String> name; final Value<String?> phone; final Value<String?> address;
  final Value<String> defaultLocale; final Value<String> updatedAt;
  const ShopProfileCompanion({this.id = const Value.absent(), this.name = const Value.absent(), this.phone = const Value.absent(), this.address = const Value.absent(), this.defaultLocale = const Value.absent(), this.updatedAt = const Value.absent()});
  ShopProfileCompanion.insert({this.id = const Value.absent(), this.name = const Value.absent(), this.phone = const Value.absent(), this.address = const Value.absent(), this.defaultLocale = const Value.absent(), required String updatedAt}) : updatedAt = Value(updatedAt);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {
    if (id.present) 'id': Variable<int>(id.value), if (name.present) 'name': Variable<String>(name.value),
    if (phone.present) 'phone': Variable<String?>(phone.value), if (address.present) 'address': Variable<String?>(address.value),
    if (defaultLocale.present) 'default_locale': Variable<String>(defaultLocale.value), if (updatedAt.present) 'updated_at': Variable<String>(updatedAt.value)};
  @override
  String toString() => 'ShopProfileCompanion($id, $name, $phone, $address, $defaultLocale, $updatedAt)';
  @override
  int get hashCode => Object.hash(id, name, phone, address, defaultLocale, updatedAt);
  @override
  bool operator ==(Object other) => identical(this, other) || other is ShopProfileCompanion && other.id == id && other.name == name && other.phone == phone && other.address == address && other.defaultLocale == defaultLocale && other.updatedAt == updatedAt;
}
class $MenuCategoriesTable extends MenuCategories with TableInfo<$MenuCategoriesTable, MenuCategory> {
  @override final GeneratedDatabase attachedDatabase; final String? _alias;
  $MenuCategoriesTable(this.attachedDatabase, [this._alias]);
  @override late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> sortOrder = GeneratedColumn<String>('sort_order', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> createdAt = GeneratedColumn<String>('created_at', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>('updated_at', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override List<GeneratedColumn> get $columns => [id, sortOrder, createdAt, updatedAt];
  @override String get aliasedName => _alias ?? actualTableName;
  @override String get actualTableName => 'menu_categories';
  @override Set<GeneratedColumn> get $primaryKey => {id};
  @override VerificationContext validateIntegrity(Insertable<MenuCategory> instance, {bool isInserting = false}) => VerificationContext();
  @override MenuCategory map(Map<String, dynamic> data, {String? tablePrefix}) => MenuCategory(id: data['id'] as String, sortOrder: data['sort_order'] as String, createdAt: data['created_at'] as String, updatedAt: data['updated_at'] as String);
  @override $MenuCategoriesTable createAlias(String alias) => $MenuCategoriesTable(attachedDatabase, alias);
}
class MenuCategory extends DataClass implements Insertable<MenuCategory> {
  final String id; final String sortOrder; final String createdAt; final String updatedAt;
  const MenuCategory({required this.id, required this.sortOrder, required this.createdAt, required this.updatedAt});
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'id': Variable<String>(id), 'sort_order': Variable<String>(sortOrder), 'created_at': Variable<String>(createdAt), 'updated_at': Variable<String>(updatedAt)};
  @override String toString() => 'MenuCategory(id: $id)';
}
class MenuCategoriesCompanion extends UpdateCompanion<MenuCategory> {
  final Value<String> id; final Value<String> sortOrder; final Value<String> createdAt; final Value<String> updatedAt;
  const MenuCategoriesCompanion({this.id = const Value.absent(), this.sortOrder = const Value.absent(), this.createdAt = const Value.absent(), this.updatedAt = const Value.absent()});
  MenuCategoriesCompanion.insert({required String id, required String sortOrder, required String createdAt, required String updatedAt}) : id = Value(id), sortOrder = Value(sortOrder), createdAt = Value(createdAt), updatedAt = Value(updatedAt);
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'id': Variable<String>(id.value), 'sort_order': Variable<String>(sortOrder.value), 'created_at': Variable<String>(createdAt.value), 'updated_at': Variable<String>(updatedAt.value)};
}
class $MenuItemsTable extends MenuItems with TableInfo<$MenuItemsTable, MenuItem> {
  @override final GeneratedDatabase attachedDatabase; final String? _alias;
  $MenuItemsTable(this.attachedDatabase, [this._alias]);
  @override late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> categoryId = GeneratedColumn<String>('category_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<int> priceMinor = GeneratedColumn<int>('price_minor', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true)();
  @override late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>('is_available', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultValue: const Constant(true))();
  @override late final GeneratedColumn<String> imagePath = GeneratedColumn<String>('image_path', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false)();
  @override late final GeneratedColumn<String> sortOrder = GeneratedColumn<String>('sort_order', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> createdAt = GeneratedColumn<String>('created_at', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>('updated_at', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override List<GeneratedColumn> get $columns => [id, categoryId, priceMinor, isAvailable, imagePath, sortOrder, createdAt, updatedAt];
  @override String get aliasedName => _alias ?? actualTableName;
  @override String get actualTableName => 'menu_items';
  @override Set<GeneratedColumn> get $primaryKey => {id};
  @override VerificationContext validateIntegrity(Insertable<MenuItem> instance, {bool isInserting = false}) => VerificationContext();
  @override MenuItem map(Map<String, dynamic> data, {String? tablePrefix}) => MenuItem(id: data['id'] as String, categoryId: data['category_id'] as String, priceMinor: data['price_minor'] as int, isAvailable: data['is_available'] as bool, imagePath: data['image_path'] as String?, sortOrder: data['sort_order'] as String, createdAt: data['created_at'] as String, updatedAt: data['updated_at'] as String);
  @override $MenuItemsTable createAlias(String alias) => $MenuItemsTable(attachedDatabase, alias);
}
class MenuItem extends DataClass implements Insertable<MenuItem> {
  final String id; final String categoryId; final int priceMinor; final bool isAvailable; final String? imagePath; final String sortOrder; final String createdAt; final String updatedAt;
  const MenuItem({required this.id, required this.categoryId, required this.priceMinor, required this.isAvailable, this.imagePath, required this.sortOrder, required this.createdAt, required this.updatedAt});
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'id': Variable<String>(id), 'category_id': Variable<String>(categoryId), 'price_minor': Variable<int>(priceMinor), 'is_available': Variable<bool>(isAvailable), if (!nullToAbsent || imagePath != null) 'image_path': Variable<String>(imagePath), 'sort_order': Variable<String>(sortOrder), 'created_at': Variable<String>(createdAt), 'updated_at': Variable<String>(updatedAt)};
}
class MenuItemsCompanion extends UpdateCompanion<MenuItem> {
  final Value<String> id; final Value<String> categoryId; final Value<int> priceMinor; final Value<bool> isAvailable; final Value<String?> imagePath; final Value<String> sortOrder; final Value<String> createdAt; final Value<String> updatedAt;
  const MenuItemsCompanion({this.id = const Value.absent(), this.categoryId = const Value.absent(), this.priceMinor = const Value.absent(), this.isAvailable = const Value.absent(), this.imagePath = const Value.absent(), this.sortOrder = const Value.absent(), this.createdAt = const Value.absent(), this.updatedAt = const Value.absent()});
  MenuItemsCompanion.insert({required String id, required String categoryId, required int priceMinor, this.isAvailable = const Value.absent(), this.imagePath = const Value.absent(), required String sortOrder, required String createdAt, required String updatedAt}) : id = Value(id), categoryId = Value(categoryId), priceMinor = Value(priceMinor), sortOrder = Value(sortOrder), createdAt = Value(createdAt), updatedAt = Value(updatedAt);
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'id': Variable<String>(id.value), 'category_id': Variable<String>(categoryId.value), 'price_minor': Variable<int>(priceMinor.value), if (isAvailable.present) 'is_available': Variable<bool>(isAvailable.value), if (imagePath.present) 'image_path': Variable<String?>(imagePath.value), 'sort_order': Variable<String>(sortOrder.value), 'created_at': Variable<String>(createdAt.value), 'updated_at': Variable<String>(updatedAt.value)};
}
class $ContentTranslationsTable extends ContentTranslations with TableInfo<$ContentTranslationsTable, ContentTranslation> {
  @override final GeneratedDatabase attachedDatabase; final String? _alias;
  $ContentTranslationsTable(this.attachedDatabase, [this._alias]);
  @override late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, type: DriftSqlType.int, autoIncrement: true, hasAutoIncrement: true, requiredDuringInsert: false)();
  @override late final GeneratedColumn<String> entityType = GeneratedColumn<String>('entity_type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> entityId = GeneratedColumn<String>('entity_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> fieldKey = GeneratedColumn<String>('field_key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> locale = GeneratedColumn<String>('locale', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override late final GeneratedColumn<String> value = GeneratedColumn<String>('value', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true)();
  @override List<GeneratedColumn> get $columns => [id, entityType, entityId, fieldKey, locale, value];
  @override String get aliasedName => _alias ?? actualTableName;
  @override String get actualTableName => 'content_translations';
  @override Set<GeneratedColumn> get $primaryKey => {id};
  @override VerificationContext validateIntegrity(Insertable<ContentTranslation> instance, {bool isInserting = false}) => VerificationContext();
  @override ContentTranslation map(Map<String, dynamic> data, {String? tablePrefix}) => ContentTranslation(id: data['id'] as int, entityType: data['entity_type'] as String, entityId: data['entity_id'] as String, fieldKey: data['field_key'] as String, locale: data['locale'] as String, value: data['value'] as String);
  @override $ContentTranslationsTable createAlias(String alias) => $ContentTranslationsTable(attachedDatabase, alias);
}
class ContentTranslation extends DataClass implements Insertable<ContentTranslation> {
  final int id; final String entityType; final String entityId; final String fieldKey; final String locale; final String value;
  const ContentTranslation({required this.id, required this.entityType, required this.entityId, required this.fieldKey, required this.locale, required this.value});
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'id': Variable<int>(id), 'entity_type': Variable<String>(entityType), 'entity_id': Variable<String>(entityId), 'field_key': Variable<String>(fieldKey), 'locale': Variable<String>(locale), 'value': Variable<String>(value)};
}
class ContentTranslationsCompanion extends UpdateCompanion<ContentTranslation> {
  final Value<int> id; final Value<String> entityType; final Value<String> entityId; final Value<String> fieldKey; final Value<String> locale; final Value<String> value;
  const ContentTranslationsCompanion({this.id = const Value.absent(), this.entityType = const Value.absent(), this.entityId = const Value.absent(), this.fieldKey = const Value.absent(), this.locale = const Value.absent(), this.value = const Value.absent()});
  ContentTranslationsCompanion.insert({this.id = const Value.absent(), required String entityType, required String entityId, required String fieldKey, required String locale, required String value}) : entityType = Value(entityType), entityId = Value(entityId), fieldKey = Value(fieldKey), locale = Value(locale), value = Value(value);
  @override Map<String, Expression> toColumns(bool nullToAbsent) => {'entity_type': Variable<String>(entityType.value), 'entity_id': Variable<String>(entityId.value), 'field_key': Variable<String>(fieldKey.value), 'locale': Variable<String>(locale.value), 'value': Variable<String>(value.value), if (id.present) 'id': Variable<int>(id.value)};
}
abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ShopProfileTable shopProfile = $ShopProfileTable(this);
  late final $MenuCategoriesTable menuCategories = $MenuCategoriesTable(this);
  late final $MenuItemsTable menuItems = $MenuItemsTable(this);
  late final $ContentTranslationsTable contentTranslations = $ContentTranslationsTable(this);
  @override Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override List<DatabaseSchemaEntity> get allSchemaEntities => [shopProfile, menuCategories, menuItems, contentTranslations];
  @override int get schemaVersion => 1;
  @override MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(shopProfile).insert(ShopProfileCompanion.insert(id: const Value(1), name: const Value(''), updatedAt: DateTime.now().toIso8601String()));
    });
}

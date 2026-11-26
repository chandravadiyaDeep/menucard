import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ShopProfile extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get defaultLocale => text().withDefault(const Constant('en'))();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class MenuCategories extends Table {
  TextColumn get id => text()();
  TextColumn get sortOrder => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class MenuItems extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(MenuCategories, #id)();
  IntColumn get priceMinor => integer()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get sortOrder => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class ContentTranslations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get fieldKey => text()();
  TextColumn get locale => text()();
  TextColumn get value => text()();
  @override
  List<Set<Column>> get uniqueKeys => [
        {entityType, entityId, fieldKey, locale},
      ];
}

@DriftDatabase(tables: [
  ShopProfile,
  MenuCategories,
  MenuItems,
  ContentTranslations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // In-memory database used by automated tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          // Create an empty shop profile so first-run setup stays local.
          await into(shopProfile).insert(
            ShopProfileCompanion.insert(
              id: const Value(1),
              name: const Value(''),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );
        },
        onUpgrade: (migrator, from, to) async {
          // Add explicit migrations here before changing the schema version.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Store the SQLite database in the app's private documents directory.
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'menucard.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

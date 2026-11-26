import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import '../../data/app_database.dart';
import '../../data/menu_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.database});
  final AppDatabase database;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MenuRepository repository;
  final shopNameController = TextEditingController();
  final categoryController = TextEditingController();
  final itemNameController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final itemPriceController = TextEditingController();
  String locale = 'en';
  String? selectedCategory;
  bool isSavingShop = false;

  @override
  void initState() {
    super.initState();
    repository = MenuRepository(widget.database);
    _loadShop();
  }

  Future<void> _loadShop() async {
    final shop = await (widget.database.select(widget.database.shopProfile)
          ..where((row) => row.id.equals(1)))
        .getSingle();
    if (!mounted) return;
    setState(() {
      shopNameController.text = shop.name;
      locale = shop.defaultLocale;
    });
  }

  @override
  void dispose() {
    shopNameController.dispose();
    categoryController.dispose();
    itemNameController.dispose();
    itemDescriptionController.dispose();
    itemPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    setState(() => isSavingShop = true);
    try {
      await repository.saveShop(name: shopNameController.text, locale: locale);
      _message('Shop details saved on this device.');
    } catch (error) {
      _message(error.toString().replaceFirst('Invalid argument(s): ', ''));
    } finally {
      if (mounted) setState(() => isSavingShop = false);
    }
  }

  Future<void> _addCategory() async {
    try {
      await repository.addCategory(categoryController.text, locale);
      categoryController.clear();
      _message('Category saved offline.');
    } catch (error) {
      _message(error.toString().replaceFirst('Invalid argument(s): ', ''));
    }
  }

  Future<void> _addItem() async {
    final price = double.tryParse(itemPriceController.text);
    if (selectedCategory == null) {
      _message('Create or select a category first.');
      return;
    }
    if (price == null) {
      _message('Enter a valid price in rupees.');
      return;
    }
    try {
      await repository.addItem(
        categoryId: selectedCategory!,
        name: itemNameController.text,
        description: itemDescriptionController.text,
        locale: locale,
        price: price,
      );
      itemNameController.clear();
      itemDescriptionController.clear();
      itemPriceController.clear();
      _message('Menu item saved offline.');
    } catch (error) {
      _message(error.toString().replaceFirst('Invalid argument(s): ', ''));
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MenuCard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.offline_bolt, size: 16),
                label: const Text('Works offline'),
                backgroundColor: const Color(0xFFE9EDDF),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
          children: [
            Text('Your shop, your menu.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('The essentials to build a digital menu. Your changes are saved locally on this device.', style: TextStyle(color: colors.onSurfaceVariant, height: 1.45)),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SHOP PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 14),
                  TextField(controller: shopNameController, decoration: const InputDecoration(labelText: 'Shop name', hintText: 'e.g. Nukkad Café')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: locale,
                    decoration: const InputDecoration(labelText: 'Default menu language'),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                    ],
                    onChanged: (value) => setState(() => locale = value ?? 'en'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: isSavingShop ? null : _saveShop,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(isSavingShop ? 'Saving…' : 'Save shop details'),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MENU CATEGORIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 14),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'New category', hintText: 'e.g. Tea & coffee')),
                const SizedBox(height: 10),
                OutlinedButton.icon(onPressed: _addCategory, icon: const Icon(Icons.add), label: const Text('Add category')),
                const SizedBox(height: 12),
                StreamBuilder<List<CategoryWithItems>>(
                  stream: repository.watchMenu(locale, locale),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) return const Text('Your categories will appear here.');
                    selectedCategory ??= categories.first.id;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final category in categories)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(category.title.isEmpty ? 'Untitled category' : category.title),
                          subtitle: Text('${category.items.length} items'),
                          trailing: Radio<String>(
                            value: category.id,
                            groupValue: selectedCategory,
                            onChanged: (value) => setState(() => selectedCategory = value),
                          ),
                        ),
                    ]);
                  },
                ),
              ]),
            )),
            const SizedBox(height: 14),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ADD A MENU ITEM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 14),
                TextField(controller: itemNameController, decoration: const InputDecoration(labelText: 'Item name')),
                const SizedBox(height: 10),
                TextField(controller: itemDescriptionController, decoration: const InputDecoration(labelText: 'Description (optional)')),
                const SizedBox(height: 10),
                TextField(controller: itemPriceController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price in ₹')),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _addItem, icon: const Icon(Icons.add_circle_outline), label: const Text('Save menu item')),
              ]),
            )),
            const SizedBox(height: 14),
            Card(child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('LOCAL MENU PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                StreamBuilder<List<CategoryWithItems>>(
                  stream: repository.watchMenu(locale, locale),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    if (categories.isEmpty) return const Text('Add a category and items to preview your menu.');
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final category in categories) ...[
                        Text(category.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                        for (final item in category.items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.name),
                            subtitle: item.description.isEmpty ? null : Text(item.description),
                            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('₹${(item.priceMinor / 100).toStringAsFixed(0)}'),
                              if (!item.available) const Text('Unavailable', style: TextStyle(fontSize: 10)),
                            ]),
                          ),
                      ],
                    ]);
                  },
                ),
              ]),
            )),
            const SizedBox(height: 12),
            const Text('Local-first preview. QR publishing is not enabled until a real public menu link exists.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

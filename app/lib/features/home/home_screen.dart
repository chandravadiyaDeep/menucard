import 'dart:io';
import 'package:flutter/services.dart';

import 'customer_menu_preview_screen.dart';
import 'qr_menu_screen.dart';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/menu_document.dart';
import '../../data/menu_repository.dart';
import '../../data/offline_account_repository.dart';
import '../../design/menu_template_catalog.dart';
import '../../services/static_package_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository, this.accountRepository});

  final MenuRepository repository;
  final OfflineAccountRepository? accountRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _locale = 'en';
  String _templateLayoutFilter = 'All';
  String _menuSearch = '';
  String _availabilityFilter = 'all';
  String _categoryFilter = 'all';
  late final TextEditingController _searchController;

  MenuDocument get _document => widget.repository.document;

  @override
  void initState() {
    super.initState();
    _locale = _document.defaultLocale;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) {
          final document = _document;
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 18,
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF173F33),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 19),
                  ),
                  const SizedBox(width: 10),
                  const Text('MenuCard', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Shop profile',
                  onPressed: _showShopDialog,
                  icon: const Icon(Icons.storefront_outlined),
                ),
                if (widget.accountRepository != null)
                  IconButton(
                    tooltip: 'Export account recovery backup',
                    onPressed: _exportAccountBackup,
                    icon: const Icon(Icons.shield_outlined),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Backup options',
                  onSelected: (value) {
                    if (value == 'backup') _exportBackup();
                    if (value == 'restore') _restoreBackup();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'backup',
                      child: Row(children: [
                        Icon(Icons.backup_outlined, size: 19),
                        SizedBox(width: 10),
                        Text('Export private backup'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'restore',
                      child: Row(children: [
                        Icon(Icons.restore_rounded, size: 19),
                        SizedBox(width: 10),
                        Text('Restore from backup'),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: SafeArea(
              top: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  _overviewPage(document),
                  _menuPage(document),
                  _templatePage(document),
                  _publishPage(),
                ],
              ),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (value) => setState(() => _tab = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'My menu'),
                NavigationDestination(icon: Icon(Icons.palette_outlined), label: 'Designs'),
                NavigationDestination(icon: Icon(Icons.qr_code_2_rounded), label: 'Publish'),
              ],
            ),
          );
        },
      );

  Widget _overviewPage(MenuDocument document) {
    final itemCount = document.categories.fold<int>(0, (sum, category) => sum + category.items.length);
    final shopName = _shopName(document);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const Text('YOUR BUSINESS, BEAUTIFULLY PRESENTED', style: TextStyle(fontSize: 10, letterSpacing: 1.35, fontWeight: FontWeight.w900, color: Color(0xFF6B786F))),
        const SizedBox(height: 8),
        Text('Your menu,\none simple place.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -1.1)),
        _setupProgressCard(document, itemCount),
        if (document.shop.name.values.every((value) => value.trim().isEmpty)) ...[
          const SizedBox(height: 14),
          _firstRunCard(),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF173F33), Color(0xFF285C47)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(30)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.offline_bolt_rounded, color: Color(0xFFB8E0C5), size: 14),
                      SizedBox(width: 5),
                      Text('SAVED ON THIS DEVICE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7)),
                    ]),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_horiz, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 22),
              Text(shopName, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: -.5)),
              const SizedBox(height: 5),
              Text(document.shop.address.isEmpty ? 'Your digital menu starts here.' : document.shop.address,
                  style: const TextStyle(color: Color(0xFFD5E4DB), fontSize: 12)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showShopDialog,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit shop'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => setState(() => _tab = 1),
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Build menu'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDDECE1), foregroundColor: const Color(0xFF173F33)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statCard('CATEGORIES', document.categories.length.toString(), Icons.folder_copy_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('MENU ITEMS', itemCount.toString(), Icons.restaurant_outlined)),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(child: Text('Quick actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            Text('V1.1.2', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _quickAction(Icons.add_circle_outline, 'Add item', () {
              setState(() => _tab = 1);
              if (document.categories.isEmpty) {
                _message('Create a category first, then add your first item.');
              } else {
                _showItemDialog();
              }
            })),
            const SizedBox(width: 10),
            Expanded(child: _quickAction(Icons.palette_outlined, 'Choose design', () => setState(() => _tab = 2))),
            const SizedBox(width: 10),
            Expanded(child: _quickAction(Icons.qr_code_2, 'QR menu', () => setState(() => _tab = 3))),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('home-customer-preview'),
          onPressed: _openCustomerPreview,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Preview customer menu'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: const Color(0xFF285C47),
            side: const BorderSide(color: Color(0xFFD5DED5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Text('Menu snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
            TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('Manage')),
          ],
        ),
        if (document.categories.isEmpty)
          _emptyCard(Icons.menu_book_outlined, 'Your menu is waiting', 'Add a category, then start listing the things you sell.')
        else
          ...document.categories.take(3).map((category) => _categoryPreview(category, document)),
        const SizedBox(height: 18),
        _publishStatus(document),
      ],
    );
  }

  // A short setup interview chooses the owner's language and shop starter categories.
  Widget _firstRunCard() => Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEE7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF285C47), size: 25),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New to MenuCard?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            SizedBox(height: 3),
            Text('Answer 3 quick questions and get a menu starter made for your shop.', style: TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF617166))),
          ])),
          TextButton(onPressed: _startGuidedSetup, child: const Text('Start')),
        ]),
      );

  Future<void> _startGuidedSetup() async {
    final types = <String, Map<String, List<String>>>{
      'cafe': {
        'en': ['Coffee & Tea', 'Snacks', 'Desserts'],
        'gu': ['ચા અને કોફી', 'નાસ્તો', 'મીઠાઈ'],
        'hi': ['चाय और कॉफी', 'नाश्ता', 'मिठाई'],
      },
      'restaurant': {
        'en': ['Starters', 'Main Course', 'Breads', 'Drinks'],
        'gu': ['સ્ટાર્ટર', 'મુખ્ય ભોજન', 'રોટલી', 'પીણાં'],
        'hi': ['स्टार्टर', 'मुख्य भोजन', 'रोटी', 'पेय'],
      },
      'bakery': {
        'en': ['Cakes', 'Pastries', 'Breads', 'Cookies'],
        'gu': ['કેક', 'પેસ્ટ્રી', 'બ્રેડ', 'કૂકીઝ'],
        'hi': ['केक', 'पेस्ट्री', 'ब्रेड', 'कुकीज़'],
      },
      'tea': {
        'en': ['Tea & Coffee', 'Quick Bites', 'Cold Drinks'],
        'gu': ['ચા અને કોફી', 'ઝટપટ નાસ્તો', 'ઠંડાં પીણાં'],
        'hi': ['चाय और कॉफी', 'झटपट नाश्ता', 'ठंडे पेय'],
      },
      'other': {
        'en': ['Popular', 'Food', 'Drinks'],
        'gu': ['લોકપ્રિય', 'ખાવાનું', 'પીણાં'],
        'hi': ['लोकप्रिय', 'खाना', 'पेय'],
      },
    };

    final setup = await showDialog<_GuidedSetupDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GuidedSetupDialog(initialLanguage: _document.defaultLocale),
    );

    if (setup == null) {
      return;
    }
    try {
      await widget.repository.saveShop(
        name: setup.shopName,
        description: '',
        translationLocale: setup.language,
        defaultLocale: setup.language,
        phone: setup.phone,
      );
      for (final category in types[setup.shopType]![setup.language]!) {
        await widget.repository.saveCategory(title: category, locale: setup.language);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _locale = setup.language;
        _tab = 1;
      });
      _message('Your shop is ready. Add your first dishes and prices!');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  // Guide first-time owners through profile, menu entry and design selection.
  Widget _setupProgressCard(MenuDocument document, int itemCount) {
    final profileReady = document.shop.name.values.any((value) => value.trim().isNotEmpty);
    final menuReady = itemCount > 0;
    final designReady = document.templateSelected;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7E5DC)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Set up your digital menu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Add your details and dishes. We will place them into the design you choose.', style: TextStyle(fontSize: 11, color: Color(0xFF78827B), height: 1.4)),
        const SizedBox(height: 12),
        _setupStepRow(
          number: '01',
          title: 'Shop profile',
          detail: profileReady ? 'Shop details saved' : 'Add your shop name and details',
          complete: profileReady,
          actionLabel: profileReady ? 'Edit' : 'Add',
          onTap: _showShopDialog,
        ),
        const Divider(height: 17),
        _setupStepRow(
          number: '02',
          title: 'Your dishes and prices',
          detail: menuReady ? '$itemCount menu items added' : 'Add categories, dishes and prices',
          complete: menuReady,
          actionLabel: menuReady ? 'Manage' : 'Add menu',
          onTap: () {
            if (!profileReady) {
              _message('Add your shop profile first.');
              return;
            }
            setState(() => _tab = 1);
          },
        ),
        const Divider(height: 17),
        _setupStepRow(
          number: '03',
          title: 'Choose a ready-made design',
          detail: designReady ? 'Your design is selected' : 'Choose from 120 menu designs',
          complete: designReady,
          actionLabel: designReady ? 'Change' : 'Choose',
          onTap: () {
            if (!profileReady || !menuReady) {
              _message('Add your shop profile and at least one dish before choosing a design.');
              return;
            }
            setState(() => _tab = 2);
          },
        ),
      ]),
    );
  }

  Widget _setupStepRow({
    required String number,
    required String title,
    required String detail,
    required bool complete,
    required String actionLabel,
    required VoidCallback onTap,
  }) => Row(children: [
        Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: complete ? const Color(0xFFE1EFE5) : const Color(0xFFF1F0EA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: complete
              ? const Icon(Icons.check_rounded, size: 17, color: Color(0xFF28724A))
              : Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B786F))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          Text(detail, style: const TextStyle(fontSize: 10, color: Color(0xFF78827B))),
        ])),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ]);

  Widget _statCard(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7E5DC))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: const Color(0xFF5C7968), size: 19),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 9, letterSpacing: .9, fontWeight: FontWeight.w800, color: Color(0xFF758078))),
        ]),
      );

  Widget _quickAction(IconData icon, String label, VoidCallback action) => InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
          decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E5DC))),
          child: Column(children: [
            Icon(icon, color: const Color(0xFF285C47), size: 23),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ),
      );

  Widget _menuPage(MenuDocument document) {
    final categories = [...document.categories]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const Text('MENU STUDIO', style: TextStyle(fontSize: 10, letterSpacing: 1.35, fontWeight: FontWeight.w900, color: Color(0xFF6B786F))),
        const SizedBox(height: 6),
        const Text('Build your menu.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 7),
        const Text('Add products, set prices and keep availability up to date. Your edits are saved locally.', style: TextStyle(color: Color(0xFF78827B), height: 1.45, fontSize: 12)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('menu-customer-preview'),
          onPressed: _openCustomerPreview,
          icon: const Icon(Icons.phone_iphone_rounded),
          label: const Text('Preview customer menu'),
        ),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Editing language', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          const Spacer(),
          DropdownButton<String>(
            value: _locale,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
            onChanged: (value) => setState(() => _locale = value ?? 'en'),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _menuSearch = value.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search dishes, descriptions or categories',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _menuSearch.isEmpty ? null : IconButton(
              tooltip: 'Clear search',
              onPressed: () { _searchController.clear(); setState(() => _menuSearch = ''); },
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _menuFilterChip('All', 'all', _categoryFilter == 'all', () => setState(() => _categoryFilter = 'all')),
            for (final category in categories)
              _menuFilterChip(category.titleFor(_locale, document.defaultLocale), category.id, _categoryFilter == category.id, () => setState(() => _categoryFilter = category.id)),
          ]),
        ),
        const SizedBox(height: 5),
        Row(children: [
          _menuFilterChip('All items', 'all', _availabilityFilter == 'all', () => setState(() => _availabilityFilter = 'all')),
          const SizedBox(width: 6),
          _menuFilterChip('Available', 'available', _availabilityFilter == 'available', () => setState(() => _availabilityFilter = 'available')),
          const SizedBox(width: 6),
          _menuFilterChip('Paused', 'unavailable', _availabilityFilter == 'unavailable', () => setState(() => _availabilityFilter = 'unavailable')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _showCategoryDialog, icon: const Icon(Icons.create_new_folder_outlined), label: const Text('Category'))),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(onPressed: categories.isEmpty ? null : _showItemDialog, icon: const Icon(Icons.add), label: const Text('Add item'))),
        ]),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          _emptyCard(Icons.add_business_outlined, 'Start with a category', 'Create groups such as Tea & Coffee, Snacks or Desserts.')
        else ...[
          for (final category in categories.where((entry) => _categoryFilter == 'all' || entry.id == _categoryFilter))
            if (_filteredItems(category, document).isNotEmpty || (_menuSearch.isEmpty && _availabilityFilter == 'all'))
              _categoryEditorCard(category, document, visibleItems: _filteredItems(category, document)),
          if (!categories.any((entry) => (_categoryFilter == 'all' || entry.id == _categoryFilter) && _filteredItems(entry, document).isNotEmpty))
            Column(children: [
              _emptyCard(Icons.search_off_rounded, 'No matching menu items', 'Try another search or change the filters.'),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _menuSearch = '';
                    _categoryFilter = 'all';
                    _availabilityFilter = 'all';
                  });
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 17),
                label: const Text('Clear all filters'),
              ),
            ]),
        ],
      ],
    );
  }

  // Match all saved translations so owners can find an item even while editing another language.
  List<MenuItem> _filteredItems(MenuCategory category, MenuDocument document) {
    return category.items.where((item) {
      final matchesAvailability = _availabilityFilter == 'all' ||
          (_availabilityFilter == 'available' && item.available) ||
          (_availabilityFilter == 'unavailable' && !item.available);
      final searchable = [
        ...item.translations.values.expand((values) => values.values),
        ...category.translations.values.expand((values) => values.values),
      ].join(' ').toLowerCase();
      return matchesAvailability && (_menuSearch.isEmpty || searchable.contains(_menuSearch));
    }).toList();
  }

  Widget _menuFilterChip(String label, String value, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 5),
        child: ChoiceChip(
          key: ValueKey(value),
          label: Text(label, overflow: TextOverflow.ellipsis),
          selected: selected,
          onSelected: (_) => onTap(),
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget _categoryEditorCard(MenuCategory category, MenuDocument document, {List<MenuItem>? visibleItems}) {
    final title = category.titleFor(_locale, document.defaultLocale);
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.fromLTRB(15, 13, 12, 10),
      decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFE7E5DC))),
      child: Column(
        children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEAF0E9), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.folder_open_rounded, color: Color(0xFF285C47), size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title.isEmpty ? 'Untitled category' : title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              Text('${visibleItems?.length ?? category.items.length} items', style: const TextStyle(fontSize: 10, color: Color(0xFF7B857E))),
            ])),
            IconButton(tooltip: 'Edit category', onPressed: () => _showCategoryDialog(category: category), icon: const Icon(Icons.edit_outlined, size: 18)),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCategory(category);
                }
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Delete category'))],
            ),
          ]),
          if (category.items.isNotEmpty) const Divider(height: 18),
          ...(visibleItems ?? category.items).map((item) => _itemRow(item, document)),
        ],
      ),
    );
  }

  Widget _itemRow(MenuItem item, MenuDocument document) {
    final name = item.nameFor(_locale, document.defaultLocale);
    final description = item.descriptionFor(_locale, document.defaultLocale);
    return InkWell(
      onTap: () => _showItemDialog(item: item),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            if (item.imagePath != null && File(item.imagePath!).existsSync())
              ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.file(File(item.imagePath!), width: 43, height: 43, fit: BoxFit.cover))
            else
              Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFF1F0EA), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.ramen_dining_outlined, color: Color(0xFF758078), size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: item.available ? const Color(0xFF202B25) : const Color(0xFF929890))),
              if (description.isNotEmpty) Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF929890))),
            ])),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_price(item.priceMinor), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              Text(item.available ? 'Available' : 'Paused', style: TextStyle(fontSize: 9, color: item.available ? const Color(0xFF3A7955) : const Color(0xFF9B4A36))),
            ]),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: (value) async {
                if (value == 'edit') {
                  _showItemDialog(item: item);
                }
                if (value == 'delete') {
                  await _deleteItem(item);
                }
                if (value == 'toggle') {
                  await widget.repository.setItemAvailability(item.id, !item.available);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit item')),
                PopupMenuItem(value: 'toggle', child: Text(item.available ? 'Mark unavailable' : 'Mark available')),
                const PopupMenuItem(value: 'delete', child: Text('Delete item')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Browse a generated library of ready-made layouts and color systems.
  // Shop text and menu items are bound into the selected design automatically.
  Widget _templatePage(MenuDocument document) {
    final selected = MenuTemplateCatalog.byId(document.templateId);
    final templates = _templateLayoutFilter == 'All'
        ? MenuTemplateCatalog.all
        : MenuTemplateCatalog.all.where((entry) => entry.layoutId == _templateLayoutFilter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const Text('READY-MADE MENU LIBRARY', style: TextStyle(fontSize: 10, letterSpacing: 1.35, fontWeight: FontWeight.w900, color: Color(0xFF6B786F))),
        const SizedBox(height: 7),
        const Text('Your menu. A design you love.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 7),
        OutlinedButton.icon(
          onPressed: _openCustomerPreview,
          icon: const Icon(Icons.phone_iphone_rounded),
          label: const Text('Preview full customer menu'),
        ),
        const SizedBox(height: 7),
        Text('${MenuTemplateCatalog.all.length} ready-made designs. Your shop name, dishes and prices flow into every template automatically.',
            style: const TextStyle(color: Color(0xFF78827B), height: 1.5, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFE8EEE7), borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF285C47)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Currently selected', style: TextStyle(fontSize: 10, color: Color(0xFF5E7064), fontWeight: FontWeight.w700)),
              Text(selected.name, style: const TextStyle(fontSize: 14, color: Color(0xFF173F33), fontWeight: FontWeight.w900)),
            ])),
            TextButton(onPressed: () => setState(() => _templateLayoutFilter = 'All'), child: const Text('All')),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Browse by layout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _templateFilterChip('All', 'All'),
            for (final layout in MenuTemplateCatalog.layouts)
              _templateFilterChip(layout.name, layout.id),
          ]),
        ),
        const SizedBox(height: 15),
        Text('${templates.length} designs', style: const TextStyle(fontSize: 11, color: Color(0xFF78827B), fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: templates.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 12,
            childAspectRatio: .76,
          ),
          itemBuilder: (context, index) => _templateCard(templates[index], document),
        ),
      ],
    );
  }

  Widget _templateFilterChip(String label, String value) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          label: Text(label),
          selected: _templateLayoutFilter == value,
          onSelected: (_) => setState(() => _templateLayoutFilter = value),
          visualDensity: VisualDensity.compact,
        ),
      );

  Widget _templateCard(MenuTemplate template, MenuDocument document) {
    final isSelected = template.id == document.templateId;
    final primary = Color(template.primaryColor);
    final background = Color(template.backgroundColor);
    final accent = Color(template.accentColor);
    final textColor = Color(template.textColor);
    final shopName = _shopName(document);
    final menuItems = document.categories.expand((category) => category.items).toList();
    final sampleItem = menuItems.isEmpty ? null : menuItems.first;
    final sampleName = sampleItem?.nameFor(_locale, document.defaultLocale) ?? 'Your best-selling dish';
    final samplePrice = sampleItem == null ? '₹120' : _price(sampleItem.priceMinor);

    return InkWell(
      onTap: () => _selectTemplate(template),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? primary : const Color(0xFFE7E5DC), width: isSelected ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: .75)),
              ),
              child: Column(
                crossAxisAlignment: template.layoutId == 'luxury' || template.layoutId == 'editorial'
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (template.layoutId == 'streetfood')
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4)), child: Text('SPECIAL MENU', style: TextStyle(color: primary, fontSize: 6, fontWeight: FontWeight.w900, letterSpacing: .6))),
                  const SizedBox(height: 5),
                  Text(shopName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: template.layoutId == 'luxury' || template.layoutId == 'editorial' ? TextAlign.center : TextAlign.start,
                      style: TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: template.layoutId == 'luxury' ? 13 : 11, letterSpacing: template.layoutId == 'editorial' ? -.4 : .1)),
                  Container(height: template.layoutId == 'compact' ? 1 : 2, width: template.layoutId == 'editorial' ? 40 : double.infinity, margin: const EdgeInsets.symmetric(vertical: 7), color: accent),
                  if (template.layoutId == 'photo')
                    Row(children: [
                      Expanded(child: _templatePhotoPlaceholder(accent)),
                      const SizedBox(width: 5),
                      Expanded(child: _templatePhotoPlaceholder(accent)),
                    ])
                  else if (template.layoutId == 'chalkboard')
                    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: accent), borderRadius: BorderRadius.circular(5)), child: Text(sampleName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.w800)))
                  else
                    Text(sampleName, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Row(children: [
                    Expanded(child: Container(height: 3, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(5)))),
                    const SizedBox(width: 5),
                    Text(samplePrice, style: TextStyle(color: primary, fontSize: 8, fontWeight: FontWeight.w900)),
                  ]),
                  if (template.layoutId == 'bistro' || template.layoutId == 'rustic')
                    Padding(padding: const EdgeInsets.only(top: 5), child: Text('FRESH · LOCAL · MADE WITH CARE', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: primary, fontSize: 5, fontWeight: FontWeight.w800, letterSpacing: .5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(template.layoutName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          Text(template.themeName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Color(0xFF78827B))),
          const SizedBox(height: 5),
          Row(children: [
            Expanded(child: Text(isSelected ? 'Selected' : 'Use this design', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isSelected ? primary : const Color(0xFF78827B)))),
            if (isSelected) Icon(Icons.check_circle, color: primary, size: 16) else Icon(Icons.arrow_forward_rounded, color: primary, size: 15),
          ]),
        ]),
      ),
    );
  }

  Widget _templatePhotoPlaceholder(Color accent) => Container(
        height: 35,
        decoration: BoxDecoration(color: accent.withValues(alpha: .55), borderRadius: BorderRadius.circular(6)),
        child: Icon(Icons.restaurant_rounded, color: accent.computeLuminance() > .5 ? const Color(0xFF4B514C) : Colors.white, size: 16),
      );

  Future<void> _openCustomerPreview() async {
    if (_document.shop.name.values.every((value) => value.trim().isEmpty)) {
      _message('Add your shop name before previewing the customer menu.');
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CustomerMenuPreviewScreen(document: _document.copy()),
    ));
  }

  Future<void> _selectTemplate(MenuTemplate template) async {
    if (template.id == _document.templateId && _document.templateSelected) { return; }
    final hasShopName = _document.shop.name.values.any((value) => value.trim().isNotEmpty);
    final hasMenuItems = _document.categories.any((category) => category.items.isNotEmpty);
    if (!hasShopName || !hasMenuItems) {
      _message('Complete your shop profile and add at least one dish before applying a design.');
      return;
    }
    try {
      await widget.repository.setTemplate(template.id);
      if (!mounted) { return; }
      _message('${template.name} applied. Your shop details, dishes and prices were kept unchanged.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Widget _publishPage() => QrMenuScreen(
        repository: widget.repository,
        locale: _locale,
      );

  Widget _publishStatus(MenuDocument document) {
    final qrReady = (document.qrMenuUrl ?? document.publishedUrl)?.isNotEmpty == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E5DC))),
      child: Row(children: [
        Icon(qrReady ? Icons.qr_code_2_rounded : Icons.qr_code_2_outlined,
            color: qrReady ? const Color(0xFF3A7955) : const Color(0xFF9B7542)),
        const SizedBox(width: 10),
        Expanded(child: Text(
          qrReady ? 'Your menu QR link is saved on this device.' : 'Add your public menu link to create a QR code.',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        )),
      ]),
    );
  }

  Widget _categoryPreview(MenuCategory category, MenuDocument document) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE7E5DC))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category.titleFor(_locale, document.defaultLocale), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 7),
          ...category.items.take(2).map((item) => Row(children: [
            Expanded(child: Text(item.nameFor(_locale, document.defaultLocale), style: const TextStyle(fontSize: 11))),
            Text(_price(item.priceMinor), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          ])),
          if (category.items.isEmpty) const Text('No items yet', style: TextStyle(color: Color(0xFF929890), fontSize: 10)),
        ]),
      );

  Widget _emptyCard(IconData icon, String title, String detail) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE7E5DC))),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF6C8B78), size: 32),
          const SizedBox(height: 11),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 5),
          Text(detail, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF818A83), fontSize: 11, height: 1.4)),
        ]),
      );

  Future<void> _showShopDialog() async {
    final document = _document;
    final name = TextEditingController(text: document.shop.name[_locale] ?? '');
    final description = TextEditingController(text: document.shop.description[_locale] ?? '');
    final address = TextEditingController(text: document.shop.address);
    final phone = TextEditingController(text: document.shop.phone);
    var defaultLocale = document.defaultLocale;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: const Text('Shop profile'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: InputDecoration(labelText: 'Shop name (${_locale.toUpperCase()})')),
          const SizedBox(height: 10),
          TextField(controller: description, maxLines: 2, decoration: InputDecoration(labelText: 'Short description (${_locale.toUpperCase()})')),
          const SizedBox(height: 10),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Address (optional)')),
          const SizedBox(height: 10),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: defaultLocale,
            decoration: const InputDecoration(labelText: 'Default menu language'),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
            onChanged: (value) => setDialogState(() => defaultLocale = value ?? 'en'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, 'save'), child: const Text('Save profile')),
        ],
      )),
    );
    if (result == 'save') {
      try {
        await widget.repository.saveShop(
          name: name.text,
          description: description.text,
          translationLocale: _locale,
          defaultLocale: defaultLocale,
          address: address.text,
          phone: phone.text,
        );
        _message('Shop profile saved on this device.');
      } catch (error) {
        _message(_cleanError(error));
      }
    }
    name.dispose();
    description.dispose();
    address.dispose();
    phone.dispose();
  }

  Future<void> _showCategoryDialog({MenuCategory? category}) async {
    final controller = TextEditingController(text: category?.titleFor(_locale, _document.defaultLocale) ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'New category' : 'Edit category'),
        content: TextField(controller: controller, autofocus: true, textCapitalization: TextCapitalization.sentences, decoration: InputDecoration(labelText: 'Category name (${_locale.toUpperCase()})')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true) {
      try {
        await widget.repository.saveCategory(id: category?.id, title: controller.text, locale: _locale);
        _message('Category saved.');
      } catch (error) {
        _message(_cleanError(error));
      }
    }
    controller.dispose();
  }

  Future<void> _deleteCategory(MenuCategory category) async {
    final itemCount = category.items.length;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this category?'),
        content: Text(itemCount == 0
            ? 'This category will be removed from your local menu.'
            : 'This will also permanently remove its $itemCount menu item(s) from this device and the next published menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep category')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9B4A36)), child: const Text('Delete')),
        ],
      ),
    );
    if (approved == true) {
      try {
        await widget.repository.deleteCategory(category.id, deleteItems: true);
        if (_categoryFilter == category.id) {
          setState(() => _categoryFilter = 'all');
        }
        _message('Category deleted.');
      } catch (error) {
        _message(_cleanError(error));
      }
    }
  }

  Future<void> _deleteItem(MenuItem item) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this menu item?'),
        content: Text('“${item.nameFor(_locale, _document.defaultLocale)}” will be removed from your saved menu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9B4A36)),
            child: const Text('Delete item'),
          ),
        ],
      ),
    );
    if (approved == true) {
      try {
        await widget.repository.deleteItem(item.id);
        if (mounted) {
          _message('Menu item deleted.');
        }
      } catch (error) {
        _message(_cleanError(error));
      }
    }
  }

  Future<void> _showItemDialog({MenuItem? item}) async {
    final document = _document;
    if (document.categories.isEmpty) {
      _message('Create a category before adding an item.');
      return;
    }
    final originalCategory = item == null
        ? document.categories.first
        : document.categories.firstWhere((category) => category.items.any((entry) => entry.id == item.id));
    final name = TextEditingController(text: item?.nameFor(_locale, document.defaultLocale) ?? '');
    final description = TextEditingController(text: item?.descriptionFor(_locale, document.defaultLocale) ?? '');
    final price = TextEditingController(text: item == null ? '' : (item.priceMinor / 100).toStringAsFixed(2));
    var categoryId = originalCategory.id;
    var available = item?.available ?? true;
    var imagePath = item?.imagePath;

    final draft = await showDialog<_ItemDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text(item == null ? 'Add menu item' : 'Edit menu item'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, autofocus: true, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: 'Item name (${_locale.toUpperCase()})')),
          const SizedBox(height: 10),
          TextField(controller: description, maxLines: 2, decoration: InputDecoration(labelText: 'Description (${_locale.toUpperCase()})')),
          const SizedBox(height: 10),
          TextField(
            controller: price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Reject a third decimal digit without unexpectedly deleting the whole field.
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                final valid = RegExp(r'^\d*\.?\d{0,2}$').hasMatch(newValue.text);
                return valid ? newValue : oldValue;
              }),
            ],
            decoration: const InputDecoration(labelText: 'Price in ₹', prefixText: '₹ ', helperText: 'Use up to 2 decimal places'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: categoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: document.categories.map((entry) => DropdownMenuItem(value: entry.id, child: Text(entry.titleFor(_locale, document.defaultLocale).isEmpty ? 'Untitled' : entry.titleFor(_locale, document.defaultLocale)))).toList(),
            onChanged: (value) => setDialogState(() => categoryId = value ?? categoryId),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: available,
            title: const Text('Available to customers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            onChanged: (value) => setDialogState(() => available = value),
          ),
          if (imagePath != null && File(imagePath!).existsSync())
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(imagePath!), height: 110, width: double.infinity, fit: BoxFit.cover)),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
                  if (picked != null) {
                    final source = File(picked.path);
                    final stored = await widget.repository.importImage(source);
                    setDialogState(() => imagePath = stored);
                  }
                } catch (error) {
                  _message(_cleanError(error));
                }
              },
              icon: const Icon(Icons.photo_library_outlined, size: 17),
              label: const Text('Photo'),
            )),
            if (imagePath != null) ...[
              const SizedBox(width: 8),
              IconButton(tooltip: 'Remove photo', onPressed: () => setDialogState(() => imagePath = null), icon: const Icon(Icons.delete_outline)),
            ],
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            final parsed = double.tryParse(price.text.trim().replaceAll(',', '.'));
            if (name.text.trim().isEmpty || parsed == null || !parsed.isFinite || parsed < 0 || price.text.trim().isEmpty) {
              _message('Enter an item name and a valid non-negative price.');
              return;
            }
            Navigator.pop(dialogContext, _ItemDraft(
              categoryId: categoryId,
              name: name.text,
              description: description.text,
              priceMinor: (parsed * 100).round(),
              available: available,
              imagePath: imagePath,
            ));
          }, child: const Text('Save item')),
        ],
      )),
    );

    if (draft != null) {
      try {
        await widget.repository.saveItem(
          id: item?.id,
          categoryId: draft.categoryId,
          name: draft.name,
          description: draft.description,
          locale: _locale,
          priceMinor: draft.priceMinor,
          available: draft.available,
          imagePath: draft.imagePath,
        );
        _message('Menu item saved offline.');
      } catch (error) {
        _message(_cleanError(error));
      }
    }
    name.dispose();
    description.dispose();
    price.dispose();
  }

  Future<void> _exportAccountBackup() async {
    final accounts = widget.accountRepository;
    if (accounts == null) {
      return;
    }
    try {
      // Keep account backup separate from the public menu ZIP and customer export.
      final file = File('${Directory.systemTemp.path}/menucard-account-recovery.json');
      await file.writeAsString(accounts.exportRecoveryJson(), flush: true);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'MenuCard account recovery backup',
        text: 'Private account recovery file. Keep it secure and do not share it publicly.',
      ));
      _message('Private account recovery backup prepared.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Future<void> _exportBackup() async {
    try {
      final file = await StaticPackageBuilder().buildPrivateBackup(_document);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        subject: 'MenuCard private menu backup',
        text: 'Keep this ZIP somewhere safe. It contains your local shop/menu JSON and the selected item photos.',
      ));
      if (!mounted) { return; }
      _message('Private backup file prepared.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['zip']);
      if (!mounted || picked == null) { return; }
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Restore this backup?'),
          content: const Text('Your current menu will be replaced by the selected backup. A recovery copy of the current menu will be kept on this device.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Restore menu')),
          ],
        ),
      );
      if (!mounted || approved != true) { return; }
      final bytes = await picked.readAsBytes();
      await StaticPackageBuilder().restorePrivateBackup(bytes, widget.repository);
      _locale = _document.defaultLocale;
      _message('Backup restored. Review the menu before exporting it again.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  String _shopName(MenuDocument document) {
    for (final locale in <String>{_locale, document.defaultLocale, 'en'}) {
      final value = document.shop.name[locale];
      if (value != null && value.trim().isNotEmpty) { return value; }
    }
    return 'Your shop';
  }

  String _price(int minor) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(minor / 100);

  String _cleanError(Object error) => error.toString().replaceFirst('Invalid argument(s): ', '');

  void _message(String text) {
    if (!mounted) { return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
}

class _GuidedSetupDraft {
  const _GuidedSetupDraft({
    required this.shopName,
    required this.phone,
    required this.language,
    required this.shopType,
  });

  final String shopName;
  final String phone;
  final String language;
  final String shopType;
}

/// Owns its text controllers so they live exactly as long as the dialog route.
class _GuidedSetupDialog extends StatefulWidget {
  const _GuidedSetupDialog({required this.initialLanguage});

  final String initialLanguage;

  @override
  State<_GuidedSetupDialog> createState() => _GuidedSetupDialogState();
}

class _GuidedSetupDialogState extends State<_GuidedSetupDialog> {
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  late String _language;
  String _shopType = 'cafe';

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Let’s set up your shop'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. What should your customers call your shop?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _shopNameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Nukkad Cafe'),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Which language should your menu use?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                ],
                onChanged: (value) => setState(() => _language = value ?? 'en'),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. What kind of shop do you run?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _shopType,
                items: const [
                  DropdownMenuItem(value: 'cafe', child: Text('Cafe / Snacks')),
                  DropdownMenuItem(value: 'restaurant', child: Text('Restaurant')),
                  DropdownMenuItem(value: 'bakery', child: Text('Bakery')),
                  DropdownMenuItem(value: 'tea', child: Text('Tea stall')),
                  DropdownMenuItem(value: 'other', child: Text('Other shop')),
                ],
                onChanged: (value) => setState(() => _shopType = value ?? 'other'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 8),
              const Text(
                'We’ll create starter categories. You can rename or delete them anytime.',
                style: TextStyle(fontSize: 10, color: Color(0xFF78827B)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              final shopName = _shopNameController.text.trim();
              if (shopName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter your shop name to continue.')),
                );
                return;
              }
              Navigator.pop(
                context,
                _GuidedSetupDraft(
                  shopName: shopName,
                  phone: _phoneController.text.trim(),
                  language: _language,
                  shopType: _shopType,
                ),
              );
            },
            child: const Text('Create my menu'),
          ),
        ],
      );

}

class _ItemDraft {
  const _ItemDraft({
    required this.categoryId,
    required this.name,
    required this.description,
    required this.priceMinor,
    required this.available,
    required this.imagePath,
  });

  final String categoryId;
  final String name;
  final String description;
  final int priceMinor;
  final bool available;
  final String? imagePath;
}

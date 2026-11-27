import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/menu_document.dart';
import '../../data/menu_repository.dart';
import '../../design/menu_template_catalog.dart';
import '../../services/static_package_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final MenuRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _locale = 'en';
  late final TextEditingController _urlController;
  bool _isExporting = false;
  String _templateLayoutFilter = 'All';

  MenuDocument get _document => widget.repository.document;

  @override
  void initState() {
    super.initState();
    _locale = _document.defaultLocale;
    _urlController = TextEditingController(text: _document.publishedUrl ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
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
                  _publishPage(document),
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
            Text('V1.0', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900)),
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
        const SizedBox(height: 16),
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
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _showCategoryDialog, icon: const Icon(Icons.create_new_folder_outlined), label: const Text('Category'))),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(onPressed: categories.isEmpty ? null : _showItemDialog, icon: const Icon(Icons.add), label: const Text('Add item'))),
        ]),
        const SizedBox(height: 16),
        if (categories.isEmpty)
          _emptyCard(Icons.add_business_outlined, 'Start with a category', 'Create groups such as Tea & Coffee, Snacks or Desserts.')
        else
          ...categories.map((category) => _categoryEditorCard(category, document)),
      ],
    );
  }

  Widget _categoryEditorCard(MenuCategory category, MenuDocument document) {
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
              Text('${category.items.length} items', style: const TextStyle(fontSize: 10, color: Color(0xFF7B857E))),
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
          ...category.items.map((item) => _itemRow(item, document)),
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
                  await widget.repository.deleteItem(item.id);
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
    final sampleItem = document.categories
        .expand((category) => category.items)
        .firstOrNull;
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

  Future<void> _selectTemplate(MenuTemplate template) async {
    if (template.id == _document.templateId) return;
    try {
      await widget.repository.setTemplate(template.id);
      if (!mounted) return;
      _message('${template.name} applied. Your shop details, dishes and prices were kept unchanged.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Widget _publishPage(MenuDocument document) {
    final hasLiveUrl = document.publishedUrl != null;
    final currentIsPublished = hasLiveUrl && document.publishedRevision == document.revision;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const Text('GO LIVE, YOUR WAY', style: TextStyle(fontSize: 10, letterSpacing: 1.35, fontWeight: FontWeight.w900, color: Color(0xFF6B786F))),
        const SizedBox(height: 6),
        const Text('Your QR menu.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.9)),
        const SizedBox(height: 7),
        const Text('Publish a static website package. You stay in control: export it, upload it yourself and keep the same QR link for updates.', style: TextStyle(color: Color(0xFF78827B), height: 1.5, fontSize: 12)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFE8EEE7), borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            const Icon(Icons.cloud_done_outlined, color: Color(0xFF285C47), size: 25),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(currentIsPublished ? 'Your latest menu is marked live' : hasLiveUrl ? 'You have unpublished changes' : 'Ready when you are',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF173F33))),
              const SizedBox(height: 3),
              Text('Local revision ${document.revision} · Published revision ${document.publishedRevision}', style: const TextStyle(fontSize: 10, color: Color(0xFF5E7064))),
            ])),
          ]),
        ),
        const SizedBox(height: 17),
        _stepCard('01', 'Export the website', 'MenuCard builds a ZIP with your menu.json, website and item photos. Nothing is uploaded automatically.'),
        const SizedBox(height: 10),
        _stepCard('02', 'Upload it yourself', 'Use your static hosting provider dashboard. Replace the previous files in the same folder to keep your QR link unchanged.'),
        const SizedBox(height: 10),
        _stepCard('03', 'Confirm your public link', 'Open the hosted page, check the menu and paste its HTTPS URL below.'),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _isExporting ? null : _exportWebsite,
          icon: _isExporting ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.file_download_outlined),
          label: Text(_isExporting ? 'Preparing package…' : 'Export website package'),
        ),
        const SizedBox(height: 20),
        const Text('PUBLIC MENU URL', style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w900, color: Color(0xFF68756D))),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.link), hintText: 'https://your-shop.example.com'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _confirmPublished,
          icon: const Icon(Icons.verified_outlined),
          label: const Text('I uploaded and checked this menu'),
        ),
        if (hasLiveUrl) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE7E5DC))),
            child: Column(children: [
              const Text('YOUR CUSTOMER QR CODE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10)),
              const SizedBox(height: 12),
              QrImageView(data: document.publishedUrl!, version: QrVersions.auto, size: 210, backgroundColor: Colors.white),
              const SizedBox(height: 9),
              SelectableText(document.publishedUrl!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF647168))),
              const SizedBox(height: 5),
              Text('Confirmed revision ${document.publishedRevision}', style: const TextStyle(fontSize: 10, color: Color(0xFF3A7955), fontWeight: FontWeight.w800)),
              TextButton.icon(onPressed: _shareMenuLink, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share menu link')),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: _exportBackup, icon: const Icon(Icons.backup_outlined), label: const Text('Export private backup')),
        const SizedBox(height: 8),
        TextButton.icon(onPressed: _restoreBackup, icon: const Icon(Icons.restore), label: const Text('Restore from backup')),
        const SizedBox(height: 12),
        const Text('Publishing is manual. MenuCard never stores a hosting password, uploads for you or runs a server. Only information in the website package becomes public.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFF818A83), height: 1.5)),
      ],
    );
  }

  Widget _stepCard(String number, String title, String detail) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE7E5DC))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFE8EEE7), borderRadius: BorderRadius.circular(10)), child: Text(number, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF285C47), fontSize: 11))),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 3),
            Text(detail, style: const TextStyle(color: Color(0xFF78827B), fontSize: 11, height: 1.45)),
          ])),
        ]),
      );

  Widget _publishStatus(MenuDocument document) {
    final pending = document.publishedUrl == null || document.publishedRevision != document.revision;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E5DC))),
      child: Row(children: [
        Icon(pending ? Icons.pending_actions_rounded : Icons.check_circle_outline, color: pending ? const Color(0xFF9B7542) : const Color(0xFF3A7955)),
        const SizedBox(width: 10),
        Expanded(child: Text(pending ? 'Your latest edits have not been published yet.' : 'Your latest published revision is up to date.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
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
        _message('Category deleted.');
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
          TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price in ₹')),
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
            if (name.text.trim().isEmpty || parsed == null || !parsed.isFinite || parsed < 0) {
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

  Future<void> _exportWebsite() async {
    setState(() => _isExporting = true);
    try {
      final revision = _document.revision;
      final zip = await StaticPackageBuilder().buildWebsitePackage(_document);
      await widget.repository.recordExported(revision);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(zip.path)],
        subject: 'MenuCard website package',
        text: 'Upload this ZIP to your static hosting provider. Extract or upload its files at the same public folder to publish your menu.',
      ));
      if (!mounted) return;
      _message('Website package created. Remember: the menu is not live until you upload it.');
    } catch (error) {
      _message(_cleanError(error));
    } finally {
      if (mounted) setState(() => _isExporting = false);
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
      if (!mounted) return;
      _message('Private backup file prepared.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Future<void> _restoreBackup() async {
    try {
      final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['zip']);
      if (!mounted || picked == null) return;
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
      if (!mounted || approved != true) return;
      final bytes = await picked.readAsBytes();
      await StaticPackageBuilder().restorePrivateBackup(bytes, widget.repository);
      _locale = _document.defaultLocale;
      _urlController.text = _document.publishedUrl ?? '';
      _message('Backup restored. Review the menu before exporting it again.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Future<void> _confirmPublished() async {
    try {
      await widget.repository.confirmPublished(_urlController.text);
      if (!mounted) return;
      _urlController.text = _document.publishedUrl ?? _urlController.text.trim();
      _message('Publishing confirmation saved on this device.');
    } catch (error) {
      _message(_cleanError(error));
    }
  }

  Future<void> _shareMenuLink() async {
    final url = _document.publishedUrl;
    if (url == null) return;
    await SharePlus.instance.share(ShareParams(text: 'View our menu: $url'));
  }

  String _shopName(MenuDocument document) {
    for (final locale in <String>{_locale, document.defaultLocale, 'en'}) {
      final value = document.shop.name[locale];
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return 'Your shop';
  }

  String _price(int minor) => NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(minor / 100);

  String _cleanError(Object error) => error.toString().replaceFirst('Invalid argument(s): ', '');

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
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

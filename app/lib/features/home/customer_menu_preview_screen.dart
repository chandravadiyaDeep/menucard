import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/menu_document.dart';
import '../../design/menu_template_catalog.dart';

/// Renders the exact static customer website inside a local WebView.
class CustomerMenuPreviewScreen extends StatefulWidget {
  const CustomerMenuPreviewScreen({super.key, required this.document});

  final MenuDocument document;

  @override
  State<CustomerMenuPreviewScreen> createState() => _CustomerMenuPreviewScreenState();
}

class _CustomerMenuPreviewScreenState extends State<CustomerMenuPreviewScreen> {
  WebViewController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _preparePreview();
  }

  Future<void> _preparePreview() async {
    try {
      // Use the same customer HTML, CSS and JavaScript bundled for website export.
      final html = await rootBundle.loadString('assets/publish/index.html');
      final css = await rootBundle.loadString('assets/publish/assets/menu.css');
      final js = await rootBundle.loadString('assets/publish/assets/menu.js');
      final publicMenu = widget.document.toPublicJson();
      final categories = publicMenu['categories'] as List<dynamic>;

      // Index photo paths once so large menus do not perform a full scan per dish.
      final imagePathsById = <String, String>{
        for (final item in widget.document.categories.expand((category) => category.items))
          if (item.imagePath != null) item.id: item.imagePath!,
      };

      // Embed local photos as data URLs so the exact preview works without internet access.
      for (var categoryIndex = 0; categoryIndex < categories.length; categoryIndex++) {
        final category = Map<String, dynamic>.from(categories[categoryIndex] as Map);
        final items = category['items'] as List<dynamic>? ?? [];
        for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
          final item = Map<String, dynamic>.from(items[itemIndex] as Map);
          final imagePath = imagePathsById[item['id']?.toString()];
          if (imagePath != null) {
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              final extension = imagePath.split('.').last.toLowerCase();
              final mime = extension == 'png'
                  ? 'image/png'
                  : extension == 'webp'
                      ? 'image/webp'
                      : 'image/jpeg';
              item['image'] = 'data:$mime;base64,${base64Encode(await imageFile.readAsBytes())}';
            } else {
              item['image'] = null;
            }
          }
          items[itemIndex] = item;
        }
        category['items'] = items;
        categories[categoryIndex] = category;
      }

      // Escape HTML-sensitive characters before embedding owner content in a script.
      final menuJson = jsonEncode(publicMenu)
          .replaceAll('&', r'\u0026')
          .replaceAll('<', r'\u003C')
          .replaceAll('>', r'\u003E');
      final customerHtml = html
          .replaceAll(
            '<link rel="stylesheet" href="assets/menu.css">',
            '<style>\n$css\n</style>',
          )
          .replaceAll(
            '<script src="assets/menu.js" defer></script>',
            '<script>window.__MENUCARD_PREVIEW__ = $menuJson;</script>\n<script>\n$js\n</script>',
          );

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Color(MenuTemplateCatalog.byId(widget.document.templateId).backgroundColor))
        ..setNavigationDelegate(NavigationDelegate(
          // Allow only embedded images and the synthetic local preview origin.
          // External links/navigation stay blocked so preview never leaves the app.
          onNavigationRequest: (request) =>
              request.url.startsWith('data:') ||
              request.url.startsWith('about:') ||
              request.url.startsWith('https://menucard.local/')
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent,
        ));
      await controller.loadHtmlString(customerHtml, baseUrl: 'https://menucard.local/');
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Customer menu preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            Text('This is how your customers will see it', style: TextStyle(fontSize: 10, color: Color(0xFF78827B))),
          ]),
          actions: [
            IconButton(
              tooltip: 'Reload preview',
              onPressed: _controller == null ? null : () => _controller!.reload(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline_rounded, size: 40),
                    const SizedBox(height: 12),
                    const Text('Preview could not be prepared', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(_error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () { setState(() { _error = null; _controller = null; }); _preparePreview(); }, child: const Text('Try again')),
                  ]),
                ),
              )
            : _controller == null
                ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Preparing your menu preview…'),
                  ]))
                : WebViewWidget(controller: _controller!),
      );
}

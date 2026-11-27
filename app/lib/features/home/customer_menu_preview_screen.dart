import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/menu_document.dart';

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

      // Preview images are embedded as data URLs so the preview works fully offline.
      for (final rawCategory in categories) {
        final category = Map<String, dynamic>.from(rawCategory as Map);
        final items = category['items'] as List<dynamic>? ?? [];
        for (final rawItem in items) {
          final item = Map<String, dynamic>.from(rawItem as Map);
          final source = widget.document.categories
              .expand((entry) => entry.items)
              .where((entry) => entry.id == item['id'])
              .firstOrNull;
          final imagePath = source?.imagePath;
          if (imagePath != null) {
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              final extension = imagePath.split('.').last.toLowerCase();
              final mime = extension == 'png' ? 'image/png' : extension == 'webp' ? 'image/webp' : 'image/jpeg';
              item['image'] = 'data:$mime;base64,${base64Encode(await imageFile.readAsBytes())}';
            } else {
              item['image'] = null;
            }
          }
          items[items.indexOf(rawItem)] = item;
        }
        rawCategory
          ..clear()
          ..addAll(category);
      }

      // Escape HTML-sensitive characters before embedding owner content in a script.
      final menuJson = jsonEncode(publicMenu)
          .replaceAll('&', r'\u0026')
          .replaceAll('<', r'\u003C')
          .replaceAll('>', r'\u003E');
      final customerHtml = html
          .replace(
            '<link rel="stylesheet" href="assets/menu.css">',
            '<style>\n$css\n</style>',
          )
          .replace(
            '<script src="assets/menu.js" defer></script>',
            '<script>window.__MENUCARD_PREVIEW__ = $menuJson;</script>\n<script>\n$js\n</script>',
          );

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Color(widget.document.templateId == 'classic-midnight' ? 0xFF111827 : 0xFFF4F5ED))
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (request) => request.url.startsWith('data:') || request.url.startsWith('about:')
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

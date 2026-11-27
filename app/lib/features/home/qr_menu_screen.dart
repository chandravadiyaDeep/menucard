import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/menu_repository.dart';

/// A focused QR maker. It only needs the public URL customers should open.
class QrMenuScreen extends StatefulWidget {
  const QrMenuScreen({
    super.key,
    required this.repository,
    required this.locale,
  });

  final MenuRepository repository;
  final String locale;

  @override
  State<QrMenuScreen> createState() => _QrMenuScreenState();
}

class _QrMenuScreenState extends State<QrMenuScreen> {
  late final TextEditingController _urlController;
  String _activeQrUrl = '';
  String? _error;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Reuse a previously generated QR link, or the old confirmed public URL.
    final savedUrl = widget.repository.document.qrMenuUrl ??
        widget.repository.document.publishedUrl ??
        '';
    _urlController = TextEditingController(text: savedUrl);
    _activeQrUrl = savedUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _generateQr() async {
    final url = _urlController.text.trim();
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme.toLowerCase() != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      setState(() => _error = 'Enter a valid public HTTPS menu link.');
      return;
    }

    try {
      await widget.repository.saveQrMenuUrl(url);
      if (!mounted) return;
      setState(() {
        _activeQrUrl = uri.toString();
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Invalid argument(s): ', ''));
    }
  }

  Future<List<int>> _qrPngBytes(String url) async {
    // Render a high-resolution PNG so printed QR codes remain sharp.
    final data = await QrPainter(
      data: url,
      version: QrVersions.auto,
      gapless: true,
    ).toImageData(1024, format: ui.ImageByteFormat.png);
    if (data == null) {
      throw StateError('The QR image could not be created. Please try again.');
    }
    return data.buffer.asUint8List();
  }

  Future<void> _exportQr({required bool asPdf}) async {
    final url = _activeQrUrl;
    if (url.isEmpty || _isExporting) return;

    setState(() => _isExporting = true);
    try {
      final pngBytes = await _qrPngBytes(url);
      final temporaryDirectory = await getTemporaryDirectory();
      final exportDirectory = Directory('${temporaryDirectory.path}/menucard-qr');
      await exportDirectory.create(recursive: true);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final shopName = _shopName();
      late final File output;

      if (asPdf) {
        final document = pw.Document();
        final qrImage = pw.MemoryImage(pngBytes);
        document.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Use a universal PDF label so Gujarati/Hindi shop names do not
                  // depend on a font that may be unavailable on the device.
                  pw.Text(
                    'SCAN TO VIEW OUR MENU',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Image(qrImage, width: 280, height: 280),
                  pw.SizedBox(height: 20),
                  pw.Text(url, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        );
        output = File('${exportDirectory.path}/menucard-qr-$stamp.pdf');
        await output.writeAsBytes(await document.save(), flush: true);
      } else {
        output = File('${exportDirectory.path}/menucard-qr-$stamp.png');
        await output.writeAsBytes(pngBytes, flush: true);
      }

      if (!mounted) return;
      // The native share sheet also offers compatible save-to-files destinations.
      await SharePlus.instance.share(ShareParams(
        files: [XFile(output.path)],
        subject: '$shopName menu QR code',
        text: 'Scan this QR code to open the $shopName menu.',
      ));
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString().replaceFirst('Invalid argument(s): ', ''));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _shopName() {
    final shop = widget.repository.document.shop;
    for (final locale in <String>{widget.locale, widget.repository.document.defaultLocale, 'en'}) {
      final name = shop.name[locale];
      if (name != null && name.trim().isNotEmpty) return name.trim();
    }
    return 'Our shop';
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          children: [
            const Text(
              'YOUR MENU, ONE SCAN AWAY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6B786F),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Create your menu QR',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, letterSpacing: -.8),
            ),
            const SizedBox(height: 7),
            const Text(
              'Add your public menu link. We’ll turn it into a QR code you can save or share.',
              style: TextStyle(color: Color(0xFF78827B), height: 1.5, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7E5DC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PUBLIC MENU LINK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .9)),
                  const SizedBox(height: 9),
                  TextField(
                    key: const ValueKey('qr-menu-url'),
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {
                      _activeQrUrl = '';
                      _error = null;
                    }),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link_rounded),
                      hintText: 'https://your-shop.com/menu',
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Your menu link must already be public and open on customers’ phones. MenuCard does not upload it.',
                    style: TextStyle(fontSize: 10, color: Color(0xFF78827B), height: 1.4),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, key: const ValueKey('qr-error'), style: const TextStyle(color: Color(0xFF9B4A36), fontSize: 11)),
                  ],
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('generate-menu-qr'),
                      onPressed: _generateQr,
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('Generate QR code'),
                    ),
                  ),
                ],
              ),
            ),
            if (_activeQrUrl.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFEFA),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE7E5DC)),
                ),
                child: Column(
                  children: [
                    Text(_shopName(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('SCAN TO VIEW OUR MENU', style: TextStyle(fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: Color(0xFF78827B))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE7E5DC)),
                      ),
                      child: QrImageView(
                        key: const ValueKey('generated-menu-qr'),
                        data: _activeQrUrl,
                        version: QrVersions.auto,
                        size: 224,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _activeQrUrl,
                      key: const ValueKey('generated-menu-qr-url'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF647168)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('share-qr-png'),
                            onPressed: _isExporting ? null : () => _exportQr(asPdf: false),
                            icon: const Icon(Icons.image_outlined, size: 17),
                            label: const Text('Export / share PNG'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('share-qr-pdf'),
                            onPressed: _isExporting ? null : () => _exportQr(asPdf: true),
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
                            label: const Text('Export / share PDF'),
                          ),
                        ),
                      ],
                    ),
                    if (_isExporting) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 5),
                      const Text('Preparing your QR file…', style: TextStyle(fontSize: 10, color: Color(0xFF78827B))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Choose Image or PDF to open your phone’s share sheet. You can send it or save it to your device.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Color(0xFF78827B), height: 1.4),
              ),
            ],
          ],
        ),
      );
}

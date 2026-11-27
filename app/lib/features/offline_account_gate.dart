import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../data/offline_account_repository.dart';

/// First-run owner activation using a code imported and issued offline.
class OfflineAccountGate extends StatefulWidget {
  const OfflineAccountGate({super.key, required this.repository, required this.child});
  final OfflineAccountRepository repository;
  final Widget child;
  @override
  State<OfflineAccountGate> createState() => _OfflineAccountGateState();
}

class _OfflineAccountGateState extends State<OfflineAccountGate> {
  final _mobile = TextEditingController();
  final _code = TextEditingController();
  final _shop = TextEditingController();
  bool _busy = false;
  late bool _unlocked;
  String? _message;

  @override
  void initState() { super.initState(); _unlocked = widget.repository.hasAccount; }
  @override
  void dispose() { _mobile.dispose(); _code.dispose(); _shop.dispose(); super.dispose(); }

  Future<void> _importBatch() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json'], withData: true);
      if (result == null || result.files.single.bytes == null) return;
      final data = jsonDecode(utf8.decode(result.files.single.bytes!));
      if (data is! Map || data['schema_version'] != 1) {
        throw const FormatException('Choose a valid personal MenuCard access-code file.');
      }
      // Each shop receives one personal code file, not the issuer's full code batch.
      final code = data['code'];
      if (code is! String || code.trim().isEmpty) {
        throw const FormatException('This file does not contain one personal access code.');
      }
      final count = await widget.repository.importCodes([code]);
      if (mounted) { setState(() => _message = count == 1 ? 'Your personal code is ready. Activate your account.' : 'This code was already imported on this device.'); }
    } catch (error) { if (mounted) { setState(() => _message = error.toString()); } }
  }

  Future<void> _claim() async {
    setState(() { _busy = true; _message = null; });
    try {
      await widget.repository.register(mobile: _mobile.text, code: _code.text, shopName: _shop.text);
      if (mounted) { setState(() => _unlocked = true); }
    } catch (error) { if (mounted) { setState(() => _message = error.toString()); } }
    finally { if (mounted) { setState(() => _busy = false); } }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.restaurant_menu_rounded, size: 48, color: Color(0xFF173F33)),
          const SizedBox(height: 18),
          const Text('Welcome to MenuCard', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Enter the access code provided by your MenuCard issuer. Registration works offline.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.4)),
          const SizedBox(height: 26),
          TextField(controller: _mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number')),
          const SizedBox(height: 12),
          TextField(controller: _shop, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Shop / business name')),
          const SizedBox(height: 12),
          TextField(controller: _code, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Owner-issued access code')),
          const SizedBox(height: 18),
          FilledButton(onPressed: _busy ? null : _claim, child: Text(_busy ? 'Checking code…' : 'Activate MenuCard')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _busy ? null : _importBatch, icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Owner: import issued code batch')),
          if (_message != null) ...[
            const SizedBox(height: 14),
            Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9B4A36))),
          ],
          const SizedBox(height: 18),
          const Text('Codes are tracked on this device. The issuer must keep the private master ledger to prevent issuing the same code to multiple phones.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4)),
        ],
      )),
    ))));
  }
}

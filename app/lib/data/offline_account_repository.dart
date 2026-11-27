import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Offline account registry. A code is single-use only within this installation.
class OfflineAccountRepository {
  OfflineAccountRepository._(this._file, this._state);

  final File _file;
  Map<String, dynamic> _state;

  static Future<OfflineAccountRepository> open() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'accounts.json'));
    if (!await file.exists()) {
      final initial = <String, dynamic>{
        'schema_version': 1,
        'issued_codes': <Map<String, dynamic>>[],
        'accounts': <Map<String, dynamic>>[],
      };
      await file.create(recursive: true);
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(initial), flush: true);
      return OfflineAccountRepository._(file, initial);
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic> || decoded['schema_version'] != 1 ||
        decoded['issued_codes'] is! List || decoded['accounts'] is! List) {
      throw const FormatException('The local account file is invalid or unsupported. No data was reset.');
    }
    return OfflineAccountRepository._(file, decoded);
  }

  bool get hasAccount => (_state['accounts'] as List).isNotEmpty;
  List<Map<String, dynamic>> get accounts =>
      (_state['accounts'] as List).cast<Map<String, dynamic>>().map(Map<String, dynamic>.from).toList();

  // Owner imports codes generated with the local tool; raw codes are never persisted.
  Future<int> importCodes(Iterable<String> codes) async {
    final records = (_state['issued_codes'] as List).cast<Map<String, dynamic>>();
    final existing = records.map((r) => r['hash']).toSet();
    var added = 0;
    for (final raw in codes) {
      final code = _normalizeCode(raw);
      if (code.length < 10) continue;
      final salt = _randomHex(16);
      final hash = _hash(code, salt);
      if (existing.add(hash)) {
        records.add({'salt': salt, 'hash': hash, 'status': 'available', 'claimed_by': null});
        added++;
      }
    }
    await _save();
    return added;
  }

  Future<void> register({required String mobile, required String code, required String shopName}) async {
    final phone = _normalizePhone(mobile);
    if (phone.length < 10) throw ArgumentError('Enter a valid mobile number.');
    if (shopName.trim().isEmpty) throw ArgumentError('Enter your shop name.');
    final accounts = (_state['accounts'] as List).cast<Map<String, dynamic>>();
    if (accounts.any((a) => a['mobile'] == phone)) {
      throw StateError('An account already exists for this mobile on this device. Use Sign in.');
    }
    final normalized = _normalizeCode(code);
    final codes = (_state['issued_codes'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic>? match;
    for (final item in codes) {
      if (item['status'] == 'available' && _hash(normalized, item['salt'] as String) == item['hash']) {
        match = item;
        break;
      }
    }
    if (match == null) throw StateError('This code is invalid, already used, or not issued on this device.');
    final accountId = _randomHex(16);
    match['status'] = 'claimed';
    match['claimed_by'] = accountId;
    accounts.add({
      'id': accountId,
      'mobile': phone,
      'shop_name': shopName.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _save();
  }

  Map<String, dynamic>? findAccount(String mobile) {
    final phone = _normalizePhone(mobile);
    for (final account in (_state['accounts'] as List).cast<Map<String, dynamic>>()) {
      if (account['mobile'] == phone) return Map<String, dynamic>.from(account);
    }
    return null;
  }

  // Export this file through the app's private backup flow before changing phones.
  String exportRecoveryJson() => const JsonEncoder.withIndent('  ').convert(_state);

  Future<void> restoreRecoveryJson(String contents) async {
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic> || decoded['schema_version'] != 1 ||
        decoded['issued_codes'] is! List || decoded['accounts'] is! List) {
      throw const FormatException('This is not a valid MenuCard account recovery file.');
    }
    _state = decoded;
    await _save();
  }

  Future<void> _save() async {
    final temp = File('${_file.path}.tmp');
    await temp.writeAsString(const JsonEncoder.withIndent('  ').convert(_state), flush: true);
    await temp.rename(_file.path);
  }

  static String _normalizePhone(String value) => value.replaceAll(RegExp(r'[^0-9+]'), '');
  static String _normalizeCode(String value) => value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  static String _hash(String code, String salt) => sha256.convert(utf8.encode('$salt:$code')).toString();
  static String _randomHex(int bytes) {
    final random = Random.secure();
    return List<int>.generate(bytes, (_) => random.nextInt(256))
        .map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  }
}

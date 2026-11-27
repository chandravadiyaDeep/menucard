import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:menucard/data/offline_account_repository.dart';

void main() {
  late Directory sandbox;
  late File accountFile;
  late OfflineAccountRepository repository;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('menucard-account-tests-');
    accountFile = File('${sandbox.path}/accounts.json');
    repository = await OfflineAccountRepository.openAt(accountFile);
  });

  tearDown(() async {
    if (await sandbox.exists()) {
      await sandbox.delete(recursive: true);
    }
  });


  test('grandfathers existing installations without requiring a new access code', () async {
    final legacyFile = File('${sandbox.path}/legacy-accounts.json');
    final legacy = await OfflineAccountRepository.openAt(
      legacyFile,
      grandfatherExistingInstall: true,
    );

    expect(legacy.hasAccount, isTrue);
    expect(legacy.accounts.single['activation_type'], 'legacy_existing_install');
  });

  test('creates a private versioned JSON account registry', () async {
    expect(await accountFile.exists(), isTrue);
    expect(repository.hasAccount, isFalse);
  });

  test('imports personal access code only once and stores no raw code', () async {
    const code = 'ABCDE-FGHIJ-KLMNP';
    expect(await repository.importCodes([code]), 1);
    expect(await repository.importCodes([code]), 0);

    final saved = await accountFile.readAsString();
    expect(saved, isNot(contains(code)));
    expect(saved, contains('available'));
  });

  test('claims a code once and rejects reuse on the same installation', () async {
    const code = 'ABCDE-FGHIJ-KLMNP';
    await repository.importCodes([code]);
    await repository.register(mobile: '+91 98765 43210', code: code, shopName: 'Nukkad Cafe');

    expect(repository.hasAccount, isTrue);
    expect(repository.findAccount('+919876543210')?['shop_name'], 'Nukkad Cafe');

    await expectLater(
      repository.register(mobile: '+91 98765 43211', code: code, shopName: 'Another Shop'),
      throwsStateError,
    );
  });

  test('rejects duplicate mobile registration on the same installation', () async {
    await repository.importCodes(['ABCDE-FGHIJ-KLMNP', 'QRSTU-VWXYZ-23456']);
    await repository.register(
      mobile: '9876543210',
      code: 'ABCDE-FGHIJ-KLMNP',
      shopName: 'First Shop',
    );

    await expectLater(
      repository.register(
        mobile: '9876543210',
        code: 'QRSTU-VWXYZ-23456',
        shopName: 'Second Shop',
      ),
      throwsStateError,
    );
  });

  test('exports and restores account recovery JSON to another installation', () async {
    await repository.importCodes(['ABCDE-FGHIJ-KLMNP']);
    await repository.register(
      mobile: '9876543210',
      code: 'ABCDE-FGHIJ-KLMNP',
      shopName: 'Recovery Cafe',
    );

    final recovery = repository.exportRecoveryJson();
    final restoredFile = File('${sandbox.path}/restored-accounts.json');
    final restored = await OfflineAccountRepository.openAt(restoredFile);
    await restored.restoreRecoveryJson(recovery);

    expect(restored.hasAccount, isTrue);
    expect(restored.findAccount('9876543210')?['shop_name'], 'Recovery Cafe');
    expect(await restoredFile.readAsString(), contains('claimed'));
  });

  test('invalid recovery data does not overwrite the existing registry', () async {
    await repository.importCodes(['ABCDE-FGHIJ-KLMNP']);
    final before = await accountFile.readAsString();

    await expectLater(
      repository.restoreRecoveryJson('{"schema_version":1,"issued_codes":"bad","accounts":[]}'),
      throwsFormatException,
    );

    expect(await accountFile.readAsString(), before);
  });
}

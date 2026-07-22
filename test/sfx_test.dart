import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/services/sfx.dart';

void main() {
  test('every UiSound maps to a wav that exists in the bank', () {
    for (final sound in UiSound.values) {
      final file = File('assets/${Sfx.bankPath}/${sound.file}');
      expect(file.existsSync(), isTrue,
          reason: '${sound.name} points at missing ${file.path}');
    }
  });

  test('the sound bank is registered as a flutter asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/${Sfx.bankPath}/'),
        reason: 'pubspec.yaml must bundle the UI sound bank');
  });
}

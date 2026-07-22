import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/services/disk_space.dart';

void main() {
  test('reports plausible space for the temp directory volume', () async {
    final space = await diskSpaceFor(Directory.systemTemp.path);
    expect(space, isNotNull);
    expect(space!.totalBytes, greaterThan(0));
    expect(space.freeBytes, inInclusiveRange(0, space.totalBytes));
    expect(space.usedBytes, space.totalBytes - space.freeBytes);
  });

  test('returns null for UNC paths on Windows', () async {
    if (!Platform.isWindows) return;
    expect(await diskSpaceFor(r'\\nowhere\share\mods'), isNull);
  });
}

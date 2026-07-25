import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/install_path.dart';

void main() {
  group('sanitizeComponent (Windows rules)', () {
    String clean(String name) => sanitizeComponent(name, windows: true);

    test('leaves an ordinary name alone', () {
      expect(clean('LizCrea_Hourglass nipple fix.package'),
          'LizCrea_Hourglass nipple fix.package');
    });

    test('replaces characters Windows forbids', () {
      expect(clean('hair <v2>: "best"?.package'), 'hair _v2__ _best__.package');
    });

    test('drops trailing dots and spaces', () {
      // Written through `\\?\` these survive; every other Windows API
      // normalises them away and then can't find the file.
      expect(clean('MESH folder '), 'MESH folder');
      expect(clean('version 2...'), 'version 2');
    });

    test('escapes reserved device names, extension or not', () {
      expect(clean('CON'), '_CON');
      expect(clean('con.package'), '_con.package');
      expect(clean('lpt1.package'), '_lpt1.package');
      expect(clean('console.package'), 'console.package');
    });

    test('trims a long name to 255 bytes, keeping the extension', () {
      final long = '${'x' * 400}.package';
      final trimmed = clean(long);
      expect(utf8.encode(trimmed).length, lessThanOrEqualTo(maxComponentBytes));
      expect(trimmed, endsWith('.package'));
    });

    test('counts bytes, not characters, for non-latin names', () {
      final cyrillic = '${'ы' * 200}.package';
      final trimmed = clean(cyrillic);
      expect(utf8.encode(trimmed).length, lessThanOrEqualTo(maxComponentBytes));
      expect(trimmed, endsWith('.package'));
      expect(trimmed.length, lessThan(cyrillic.length));
    });
  });

  group('installTargetPath (Windows rules)', () {
    String target(String relative, {String destination = r'C:\Mods'}) =>
        installTargetPath(destination, relative, windows: true);

    test('keeps a path that already fits', () {
      expect(target(r'MyMod v2\extras\lamp.package'),
          r'C:\Mods\MyMod v2\extras\lamp.package');
    });

    test('drops the deepest folders first when over the limit', () {
      final deep = [
        "LizCrea's Hourglass Bodyshape",
        'LizCrea_Hourglass nipple fix showerproof on Anva',
        'NEEDED IN DOWNLOADS FOLDER',
        'LizCrea_HourglassnudetopSF_nipplefix_MESH',
        'LizCrea_HourglassnudetopSF_nipplefix.package',
      ].join(r'\');
      final fitted = target(deep,
          destination: r'C:\Users\Виктория\Documents\EA Games'
              r'\The Sims 2 Ultimate Collection\Downloads');

      expect(fitted.length, lessThanOrEqualTo(windowsPathLimit));
      expect(
          fitted, endsWith(r'\LizCrea_HourglassnudetopSF_nipplefix.package'));
      // Only the deepest folder had to go, and the top one - the filter
      // chip the library shows - is the last that ever would.
      expect(fitted,
          isNot(contains(r'\LizCrea_HourglassnudetopSF_nipplefix_MESH\')));
      expect(fitted, contains(r'\NEEDED IN DOWNLOADS FOLDER\'));
      expect(fitted, contains(r"\LizCrea's Hourglass Bodyshape\"));
    });

    test('flattens completely when even one folder is too much', () {
      final fitted = target('${'a' * 300}\\deep.package');
      expect(fitted, r'C:\Mods\deep.package');
    });

    test('trims the file name only as a last resort', () {
      final fitted = target('${'n' * 300}.package');
      expect(fitted.length, lessThanOrEqualTo(windowsPathLimit));
      expect(fitted, startsWith(r'C:\Mods\nnn'));
      expect(fitted, endsWith('.package'));
    });

    test('sanitizes every component on the way', () {
      expect(target(r'MESH folder \sub|dir\hair?.package'),
          r'C:\Mods\MESH folder\sub_dir\hair_.package');
    });

    test('accepts forward slashes, as zip entries use them', () {
      expect(target('MyMod/hair.package'), r'C:\Mods\MyMod\hair.package');
    });

    test('never leaves the destination', () {
      expect(target(r'..\..\escape.package'), r'C:\Mods\escape.package');
      expect(target(r'.\hair.package'), r'C:\Mods\hair.package');
    });

    test('substitutes a name made only of illegal characters', () {
      expect(target(r'???.package'), r'C:\Mods\___.package');
      expect(target('   .package'), r'C:\Mods\mod.package');
    });
  });

  group('installTargetPath (POSIX rules)', () {
    String target(String relative, {String destination = '/mods'}) =>
        installTargetPath(destination, relative, windows: false);

    test('keeps names Windows would reject', () {
      expect(target('CON/hair: "v2".package'),
          '/mods/CON/hair: "v2".package');
    });

    test('still enforces the path limit', () {
      final deep = [for (var i = 0; i < 40; i++) 'folder ${'x' * 40} $i']
          .join('/');
      final fitted = target('$deep/hair.package');
      expect(fitted.length, lessThanOrEqualTo(posixPathLimit));
      expect(fitted, endsWith('/hair.package'));
    });

    test('keeps a normal path byte-identical', () {
      expect(target('MyMod v2/extras/lamp.package'),
          '/mods/MyMod v2/extras/lamp.package');
    });
  });

  group('claimInstallTarget', () {
    test('lets an unchanged path overwrite, as reinstalling should', () {
      final taken = <String>{};
      final first = claimInstallTarget('/mods', 'a/hair.package', taken,
          windows: false);
      final again = claimInstallTarget('/mods', 'a/hair.package', taken,
          windows: false);
      expect(first, '/mods/a/hair.package');
      expect(again, first);
    });

    test('separates two files the limit collapsed onto one name', () {
      final taken = <String>{};
      final deep = 'x' * 240;
      final first = claimInstallTarget(
          r'C:\Mods', '$deep\\one\\hair.package', taken,
          windows: true);
      final second = claimInstallTarget(
          r'C:\Mods', '$deep\\two\\hair.package', taken,
          windows: true);
      expect(first, r'C:\Mods\hair.package');
      expect(second, r'C:\Mods\hair-2.package');
      expect(second.length, lessThanOrEqualTo(windowsPathLimit));
    });

    test('variants stay inside the path limit', () {
      final taken = <String>{};
      final destination = 'C:\\Mods\\${'d' * 200}';
      final paths = [
        for (var i = 0; i < 5; i++)
          claimInstallTarget(destination, 'deep$i/${'n' * 60}.package', taken,
              windows: true),
      ];
      expect(paths.toSet(), hasLength(5));
      for (final path in paths) {
        expect(path.length, lessThanOrEqualTo(windowsPathLimit));
        expect(path, endsWith('.package'));
      }
    });
  });

  group('windowsExtendedPath', () {
    test('prefixes a drive path', () {
      expect(windowsExtendedPath(r'C:\Users\x\AppData\Local\Temp\unpack'),
          r'\\?\C:\Users\x\AppData\Local\Temp\unpack');
    });

    test('uses the UNC form for a share', () {
      expect(windowsExtendedPath(r'\\nas\sims\Mods'), r'\\?\UNC\nas\sims\Mods');
    });

    test('is idempotent and leaves other paths alone', () {
      expect(windowsExtendedPath(r'\\?\C:\Mods'), r'\\?\C:\Mods');
      expect(windowsExtendedPath('relative/path'), 'relative/path');
      expect(windowsExtendedPath('/mods/sims'), '/mods/sims');
    });

    test('a prefixed path is what package:path splits it into', () {
      // Guards the assumption the tar walk relies on: the prefix is a
      // pure string operation, not something that reshapes the path.
      const path = r'C:\Temp\unpack\mod.package';
      expect(windowsExtendedPath(path).endsWith(path), isTrue);
      expect(p.windows.basename(windowsExtendedPath(path)), 'mod.package');
    });
  });
}

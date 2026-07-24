import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod_name.dart';

void main() {
  group('humanizeModName', () {
    test('strips the extension', () {
      expect(humanizeModName('Cozy Living Overhaul.package'),
          'Cozy Living Overhaul');
    });

    test('turns underscores and hyphens into spaces', () {
      expect(humanizeModName('cozy_living-overhaul.package'),
          'cozy living overhaul');
    });

    test('splits CamelCase into words', () {
      expect(humanizeModName('CozyLivingOverhaul.package'),
          'Cozy Living Overhaul');
    });

    test('keeps acronyms together and splits the following word', () {
      expect(humanizeModName('MCCommandCenter.package'), 'MC Command Center');
      expect(humanizeModName('UICheatsExtension.ts4script'),
          'UI Cheats Extension');
    });

    test('preserves version markers', () {
      expect(humanizeModName('UICheatsExtension_v1.36.ts4script'),
          'UI Cheats Extension v1.36');
    });

    test('decodes url-encoded spaces and collapses runs of separators', () {
      expect(humanizeModName('better%20build__buy.package'),
          'better build buy');
    });

    test('falls back to the raw name when cleanup leaves nothing', () {
      expect(humanizeModName('___.package'), '___.package');
    });

    test('leaves already-clean names alone', () {
      expect(humanizeModName('faster homework.iff'), 'faster homework');
    });
  });

  group('parseModName', () {
    test('reads a v-prefixed version and strips it from the name', () {
      final info = parseModName('UICheatsExtension_v1.36.ts4script');
      expect(info.version, '1.36');
      expect(info.versionLabel, 'v1.36');
      expect(info.strippedName, 'UICheatsExtension.ts4script');
      expect(info.identity, 'uicheatsextension.ts4script');
    });

    test('accepts a bare v-number and letter suffixes', () {
      expect(parseModName('SlicedBread_V2.package').versionLabel, 'v2');
      expect(parseModName('wickedwhims_v170f.package').version, '170f');
    });

    test('reads a dotted number without a v prefix', () {
      expect(parseModName('better-builds-1.2.3.package').version, '1.2.3');
      expect(parseModName('better-builds-1.2.3.package').versionLabel,
          'v1.2.3');
    });

    test('reads date stamps and normalizes their separators', () {
      expect(parseModName('BetterNPCs 2024-05-01.package').version,
          '2024-05-01');
      expect(parseModName('fix_2024.5.1.package').version, '2024-05-01');
      expect(parseModName('fix_2024.5.1.package').versionLabel, '2024-05-01');
    });

    test('finds no version in plain names', () {
      final info = parseModName('Cozy Living Overhaul.package');
      expect(info.version, isNull);
      expect(info.versionLabel, isNull);
      expect(info.strippedName, 'Cozy Living Overhaul.package');
    });

    test('does not mistake counts or embedded digits for versions', () {
      expect(parseModName('Top5Furniture.package').version, isNull);
      expect(parseModName('RoomDivider 3.package').version, isNull);
      expect(parseModName('TV2Remote.package').version, isNull);
      expect(parseModName('Luv2Build.package').version, isNull);
    });

    test('identity ignores case, separators and the version token', () {
      expect(parseModName('Cool_Hair_v1.package').identity,
          parseModName('cool hair v2.package').identity);
      expect(parseModName('Cool_Hair_v1.package').identity,
          parseModName('COOL-HAIR.package').identity);
    });

    test('identity keeps different extensions apart', () {
      expect(parseModName('mccc_v7.package').identity,
          isNot(parseModName('mccc_v7.ts4script').identity));
    });

    test('keeps the title for version-only names', () {
      final info = parseModName('v1.2.package');
      expect(info.version, '1.2');
      expect(info.strippedName, 'v1.2.package');
    });
  });
}

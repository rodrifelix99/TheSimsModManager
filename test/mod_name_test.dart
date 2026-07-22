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
}

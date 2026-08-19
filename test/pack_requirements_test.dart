// What a listing on The Exchange says it needs, answered against what a
// machine actually has. The rule the whole file exists to protect is that
// not knowing is its own answer: two of the five games can only be asked
// on Windows, and a Mac user must never be told their shelf is unusable.
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/game_pack.dart';
import 'package:sims_mod_manager/src/core/pack_requirements.dart';

GamePack _pack(String code, {bool enabled = true, String? name}) => GamePack(
      code: code,
      name: name ?? code,
      kind: GamePackKind.expansion,
      isEnabled: enabled,
    );

void main() {
  group('normalizing codes off the wire', () {
    test('keeps the shapes the games actually use', () {
      expect(normalizePackCode('EP01'), 'EP01');
      expect(normalizePackCode(' gp06 '), 'GP06');
      expect(normalizePackCode('SP24'), 'SP24');
    });

    test('refuses anything that is not one', () {
      // Every one of these could be sitting in a document, because the
      // document is written by a web page.
      expect(normalizePackCode('E'), isNull);
      expect(normalizePackCode('EP-01'), isNull);
      expect(normalizePackCode('../../etc'), isNull);
      expect(normalizePackCode('<script>'), isNull);
      expect(normalizePackCode('EP01 EP02'), isNull);
      expect(normalizePackCode('THISISWAYTOOLONG'), isNull);
      expect(normalizePackCode(42), isNull);
      expect(normalizePackCode(null), isNull);
    });

    test('drops duplicates and caps the list', () {
      expect(normalizePackCodes(['EP01', 'ep01', 'EP02']), ['EP01', 'EP02']);
      final many = List.generate(40, (at) => 'EP${at.toString().padLeft(2, '0')}');
      expect(normalizePackCodes(many), hasLength(maxPackRequirements));
    });
  });

  group('resolving against a machine', () {
    test('an installed, enabled pack is met', () {
      final needs = resolvePackRequirements(
        codes: const ['EP01'],
        installed: [_pack('EP01', name: 'Get to Work')],
      );
      expect(needs.single.state, PackRequirementState.met);
      expect(needs.single.name, 'Get to Work');
      expect(needs.single.isBlocking, isFalse);
    });

    test('an installed pack the user switched off is its own answer', () {
      // Worth telling apart from missing: this one the app can undo
      // itself, on the screen next door.
      final needs = resolvePackRequirements(
        codes: const ['EP01'],
        installed: [_pack('EP01', enabled: false)],
      );
      expect(needs.single.state, PackRequirementState.disabled);
      expect(needs.single.isBlocking, isTrue);
    });

    test('a pack the game never mentioned is missing, and named anyway', () {
      final needs = resolvePackRequirements(
        codes: const ['EP05'],
        installed: [_pack('EP01')],
        catalog: const {'EP05': 'Cats & Dogs'},
      );
      expect(needs.single.state, PackRequirementState.missing);
      expect(needs.single.name, 'Cats & Dogs');
    });

    test('a game that owns nothing still answers missing', () {
      // An empty list is a real answer - this player has the base game and
      // nothing else - which is exactly what null is kept apart from.
      final needs = resolvePackRequirements(
        codes: const ['EP01'],
        installed: const [],
      );
      expect(needs.single.state, PackRequirementState.missing);
    });

    test('a game that could not be asked answers unknown, never missing', () {
      // The Sims 2 and 3 keep their pack lists in the Windows registry, so
      // this is every Mac and Linux machine. Telling those users a pack is
      // absent would be a warning we have no evidence for.
      final needs = resolvePackRequirements(
        codes: const ['EP01', 'EP02'],
        installed: null,
        catalog: const {'EP01': 'University'},
      );
      expect(needs.map((one) => one.state),
          everyElement(PackRequirementState.unknown));
      expect(needs.first.name, 'University');
      expect(needs.any((one) => one.isBlocking), isFalse);
    });

    test('a pack released after this build draws under its own code', () {
      final needs = resolvePackRequirements(
        codes: const ['EP99'],
        installed: const [],
      );
      expect(needs.single.name, 'EP99');
    });

    test('the installed name wins over the shipped one', () {
      // The install can spell a pack in the player's own language; the
      // table only ever has English.
      final needs = resolvePackRequirements(
        codes: const ['EP01'],
        installed: [_pack('EP01', name: 'An die Arbeit')],
        catalog: const {'EP01': 'Get to Work'},
      );
      expect(needs.single.name, 'An die Arbeit');
    });

    test('codes are matched however the document spelled them', () {
      final needs = resolvePackRequirements(
        codes: const ['EP01'],
        installed: [_pack('ep01')],
      );
      expect(needs.single.state, PackRequirementState.met);
    });
  });

  group('the sharpest thing to say about a list', () {
    test('is nothing at all for a mod that needs nothing', () {
      expect(worstPackRequirement(const []), isNull);
    });

    test('puts missing ahead of switched off, and both ahead of unknown', () {
      List<PackRequirement> of(List<PackRequirementState> states) => [
            for (final state in states)
              PackRequirement(code: 'EP01', name: 'x', state: state),
          ];
      expect(
          worstPackRequirement(of([
            PackRequirementState.met,
            PackRequirementState.unknown,
            PackRequirementState.disabled,
            PackRequirementState.missing,
          ])),
          PackRequirementState.missing);
      expect(
          worstPackRequirement(of([
            PackRequirementState.unknown,
            PackRequirementState.disabled,
          ])),
          PackRequirementState.disabled);
      expect(worstPackRequirement(of([PackRequirementState.met])),
          PackRequirementState.met);
    });
  });
}

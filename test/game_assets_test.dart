import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/ui/game_theme.dart';

void main() {
  Game game(String id) => Game(id: id, name: id, series: 'The Sims');

  test('every registered icon/logo asset exists on disk', () {
    for (final id in ['sims1', 'sims2', 'sims3', 'sims4']) {
      final icon = GameTheme.iconAsset(game(id));
      final logo = GameTheme.logoAsset(game(id));
      expect(icon, isNotNull, reason: '$id has no icon');
      expect(logo, isNotNull, reason: '$id has no logo');
      expect(File(icon!).existsSync(), isTrue, reason: 'missing $icon');
      expect(File(logo!).existsSync(), isTrue, reason: 'missing $logo');
    }
  });

  test('unknown games have no assets and fall back gracefully', () {
    expect(GameTheme.iconAsset(game('simcity4')), isNull);
    expect(GameTheme.logoAsset(game('simcity4')), isNull);
  });
}

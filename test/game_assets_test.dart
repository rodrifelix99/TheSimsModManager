import 'dart:io';

import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/ui/game_theme.dart';

void main() {
  Game game(String id) => Game(id: id, name: id, series: 'The Sims');

  test('every registered icon/logo asset exists on disk', () {
    for (final id in ['sims1', 'sims2', 'sims3', 'sims4', 'simsmedieval']) {
      final icon = GameTheme.iconAsset(game(id));
      expect(icon, isNotNull, reason: '$id has no icon');
      expect(File(icon!).existsSync(), isTrue, reason: 'missing $icon');
      for (final brightness in Brightness.values) {
        final logo = GameTheme.logoAsset(game(id), brightness);
        expect(logo, isNotNull, reason: '$id has no $brightness logo');
        expect(File(logo!).existsSync(), isTrue, reason: 'missing $logo');
      }
    }
  });

  test('the Sims 4 wordmark swaps for the dark theme', () {
    expect(GameTheme.logoAsset(game('sims4'), Brightness.dark),
        isNot(GameTheme.logoAsset(game('sims4'), Brightness.light)));
    // Everything else is one artwork that reads on either background.
    for (final id in ['sims1', 'sims2', 'sims3', 'simsmedieval']) {
      expect(GameTheme.logoAsset(game(id), Brightness.dark),
          GameTheme.logoAsset(game(id), Brightness.light));
    }
  });

  test('unknown games have no assets and fall back gracefully', () {
    expect(GameTheme.iconAsset(game('simcity4')), isNull);
    for (final brightness in Brightness.values) {
      expect(GameTheme.logoAsset(game('simcity4'), brightness), isNull);
    }
  });
}

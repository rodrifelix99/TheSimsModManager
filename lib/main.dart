import 'package:flutter/material.dart';

import 'src/core/game_registry.dart';
import 'src/games/the_sims/sims_adapters.dart';
import 'src/ui/app.dart';

void main() {
  // To support a new game, implement a GameAdapter and add it here.
  final registry = GameRegistry(const [
    Sims1Adapter(),
    Sims2Adapter(),
    Sims3Adapter(),
    Sims4Adapter(),
  ]);
  runApp(ModManagerApp(registry: registry));
}

import 'package:flutter/material.dart';

import '../core/game_registry.dart';
import 'home_screen.dart';

class ModManagerApp extends StatelessWidget {
  const ModManagerApp({super.key, required this.registry});

  final GameRegistry registry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sims Mod Manager',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: HomeScreen(registry: registry),
    );
  }
}

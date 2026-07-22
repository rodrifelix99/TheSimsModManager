import 'dart:io';

import 'package:flutter/material.dart';

import '../core/game_adapter.dart';
import '../core/game_registry.dart';
import '../core/mod.dart';

/// Game picker on the left, mod list for the selected game on the right.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.registry});

  final GameRegistry registry;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameAdapter _selected;
  Directory? _modsDir;
  List<Mod> _mods = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selected = widget.registry.adapters.first;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final dir = await _selected.resolveModsDirectory();
    final mods = dir == null ? const <Mod>[] : await _selected.listMods(dir);
    if (!mounted) return;
    setState(() {
      _modsDir = dir;
      _mods = mods;
      _loading = false;
    });
  }

  Future<void> _selectGame(GameAdapter adapter) async {
    setState(() => _selected = adapter);
    await _refresh();
  }

  Future<void> _toggleMod(Mod mod) async {
    await _selected.setEnabled(mod, enabled: !mod.isEnabled);
    await _refresh();
  }

  Future<void> _removeMod(Mod mod) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${mod.name}?'),
        content: const Text('The mod file will be deleted from disk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _selected.removeMod(mod);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_selected.game.name} — Mods')),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.registry.adapters.indexOf(_selected),
            onDestinationSelected: (i) =>
                _selectGame(widget.registry.adapters[i]),
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final adapter in widget.registry.adapters)
                NavigationRailDestination(
                  icon: const Icon(Icons.videogame_asset_outlined),
                  selectedIcon: const Icon(Icons.videogame_asset),
                  label: Text(adapter.game.name),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildModList()),
        ],
      ),
    );
  }

  Widget _buildModList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_modsDir == null) {
      return Center(
        child: Text(
          '${_selected.game.name} was not found on this computer.\n'
          'Custom folder selection is coming soon.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_mods.isEmpty) {
      return Center(child: Text('No mods found in ${_modsDir!.path}'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        itemCount: _mods.length,
        itemBuilder: (context, i) {
          final mod = _mods[i];
          return ListTile(
            leading: Icon(
              mod.isEnabled ? Icons.extension : Icons.extension_off,
              color: mod.isEnabled ? null : Theme.of(context).disabledColor,
            ),
            title: Text(mod.name),
            subtitle: Text(mod.path),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: mod.isEnabled,
                  onChanged: (_) => _toggleMod(mod),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove mod',
                  onPressed: () => _removeMod(mod),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

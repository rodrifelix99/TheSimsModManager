import 'game_adapter.dart';

/// Central list of every game the manager knows how to handle.
///
/// The UI and services only ever talk to adapters obtained from here,
/// so adding a game is: write the adapter, add it to the list passed
/// to the registry in `main.dart`.
class GameRegistry {
  GameRegistry(List<GameAdapter> adapters)
      : _adapters = List.unmodifiable(adapters);

  final List<GameAdapter> _adapters;

  List<GameAdapter> get adapters => _adapters;

  GameAdapter? byGameId(String id) {
    for (final adapter in _adapters) {
      if (adapter.game.id == id) return adapter;
    }
    return null;
  }
}

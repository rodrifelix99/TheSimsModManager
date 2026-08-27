import 'package:audioplayers/audioplayers.dart';

/// Semantic UI sound events, mapped onto the Sims 1 UI sound bank
/// (assets/sounds/s1/ui). Callers name the intent; which wav that
/// means is decided here, so reskinning the app's audio is one file.
enum UiSound {
  click('UI_CLICK.wav'),

  /// Committing to something bigger than a button: switching game,
  /// picking a mods folder (the neighborhood-screen click).
  select('UI_NHOOD_CLICK.wav'),

  open('UI_PIEMENU_APPEAR.wav'),

  back('UI_WHOOSH.wav'),

  /// Cycling through choices: category chips, grid/list toggle
  /// (Create-a-Sim part cycling).
  cycle('UI_CAC_CYCLEPARTS.wav'),

  /// Enabling a mod / turning a preference on.
  toggleOn('UI_OBJECT_PLACE.wav'),

  /// Disabling a mod / turning a preference off (action-queue cancel).
  toggleOff('UI_QUEUE_DELETE.wav'),

  /// Installing a mod or creating the mods folder (build-tool place).
  install('UI_BLD_DRAGTOOL_PLACE.wav'),

  /// Deleting a mod from disk (the bulldozer).
  uninstall('UI_NHOOD_BDOZE_DEMOLISH.wav'),

  alert('UI_NHOOD_ERROR.wav'),

  error('UI_ERROR.wav'),

  help('Ui_Help.wav');

  const UiSound(this.file);

  /// File name inside [Sfx.bankPath].
  final String file;
}

/// Fire-and-forget playback of the app's UI sound bank. Sounds are
/// garnish: every failure (missing plugin in tests, no audio device,
/// codec trouble) is swallowed, never surfaced.
class Sfx {
  /// Asset directory holding the bank, relative to `assets/`.
  static const bankPath = 'sounds/s1/ui';

  /// How many clips can sound at once. Enough that a click during an
  /// install still lands - the bank is short UI blips, and nothing here
  /// runs longer than a second or two.
  static const _voices = 4;

  /// Players are made once and kept, never disposed.
  ///
  /// A player per playback was the obvious shape and the wrong one: the
  /// clip finishing and a failing `play()` both want to clean up, and
  /// audioplayers throws out of a second `dispose()` - into whatever zone
  /// the completion event arrived on, so no `try` at the call site can
  /// catch it. Worse, its position timer can fire *after* the close and
  /// add to a shut stream. Both were the loudest thing in error tracking
  /// for a feature that is decoration. Nothing is disposed here, so
  /// neither can happen; the native side is released by audioplayers'
  /// default [ReleaseMode.release] once a clip ends, and four idle
  /// players cost nothing until the app closes.
  final List<AudioPlayer> _pool = [];
  int _next = 0;

  Future<void> play(UiSound sound) async {
    final AudioPlayer player;
    try {
      if (_pool.length < _voices) {
        player = AudioPlayer();
        _pool.add(player);
      } else {
        // Round-robin, so the clip that gets cut short is always the
        // oldest one still sounding.
        player = _pool[_next];
      }
      _next = (_next + 1) % _voices;
      await player.play(AssetSource('$bankPath/${sound.file}'));
    } catch (_) {
      // A machine with no audio device, a bank file that will not
      // decode, a plugin that is not there under test: all of them mean
      // the same thing, which is silence.
    }
  }
}

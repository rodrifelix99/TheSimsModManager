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

  /// A player per playback so rapid sounds overlap instead of cutting
  /// each other off; disposed as soon as the clip finishes.
  Future<void> play(UiSound sound) async {
    final player = AudioPlayer();
    // audioplayers throws out of dispose() when the player is already
    // disposed, and the throw lands in whatever zone the completion
    // event arrived on - unhandled, and loud in error tracking. The
    // completion event and a failing play() both want to clean up, so
    // the second one has to be a no-op rather than a second dispose.
    var disposing = false;
    Future<void> disposeOnce() async {
      if (disposing) return;
      disposing = true;
      try {
        await player.dispose();
      } catch (_) {
        // Nothing left to do about a player that won't close.
      }
    }

    try {
      player.onPlayerComplete
          .listen((_) => disposeOnce(), onError: (_) => disposeOnce());
      await player.play(AssetSource('$bankPath/${sound.file}'));
    } catch (_) {
      await disposeOnce();
    }
  }
}

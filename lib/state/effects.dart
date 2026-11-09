import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage.dart';

enum Effect {
  correct('sounds/correct.wav'),
  wrong('sounds/wrong.wav'),
  celebrate('sounds/fanfare.wav');

  const Effect(this.sound);

  final String sound;
}

/// Plays feedback for quiz events: a sound (when enabled) and a vibration.
abstract interface class Effects {
  void play(Effect effect);
}

/// Sounds through audioplayers and vibration through the platform's haptics
/// (a no-op on web).
class DeviceEffects implements Effects {
  DeviceEffects(this._soundEnabled);

  final bool Function() _soundEnabled;
  final _players = <Effect, AudioPlayer>{};

  @override
  void play(Effect effect) {
    switch (effect) {
      case Effect.correct:
        HapticFeedback.lightImpact();
      case Effect.wrong:
        HapticFeedback.heavyImpact();
      case Effect.celebrate:
        HapticFeedback.mediumImpact();
    }
    if (_soundEnabled()) _playSound(effect);
  }

  Future<void> _playSound(Effect effect) async {
    try {
      final player = _players[effect] ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await player.play(AssetSource(effect.sound));
    } catch (_) {
      // Sound is a nice-to-have: never let a playback error reach the UI
      // (for example, browsers block audio until the first user gesture).
    }
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
  }
}

/// Plays nothing. Used in tests.
class SilentEffects implements Effects {
  final played = <Effect>[];

  @override
  void play(Effect effect) => played.add(effect);
}

final effectsProvider = Provider<Effects>((ref) {
  final effects = DeviceEffects(() => ref.read(soundProvider));
  ref.onDispose(effects.dispose);
  return effects;
});

final soundProvider = NotifierProvider<SoundNotifier, bool>(SoundNotifier.new);

/// Whether sound effects are on. Remembered between launches.
class SoundNotifier extends Notifier<bool> {
  static const storageKey = 'quiz_it.sound.v1';

  @override
  bool build() => ref.read(storageProvider).read(storageKey) != 'off';

  void toggle() {
    state = !state;
    ref.read(storageProvider).write(storageKey, state ? 'on' : 'off');
  }
}

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_it/data/daily_bank.dart';
import 'package:quiz_it/state/effects.dart';

// Loads through the app's real asset bundle, so a file that exists on disk
// but isn't declared in pubspec.yaml fails here instead of at runtime.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every sound effect is bundled', () async {
    for (final effect in Effect.values) {
      final data = await rootBundle.load('assets/${effect.sound}');
      expect(data.lengthInBytes, greaterThan(44), reason: effect.sound);
    }
  });

  test('the logo and daily question bank are bundled', () async {
    await rootBundle.load('assets/launcher.png');
    await rootBundle.load(DailyBank.asset);
  });
}

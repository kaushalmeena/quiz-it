import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'state/settings.dart';
import 'state/stats.dart';
import 'state/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await PrefsStorage.open({
    SettingsNotifier.storageKey,
    StatsNotifier.storageKey,
  });

  runApp(
    ProviderScope(
      overrides: [storageProvider.overrideWithValue(storage)],
      child: const QuizItApp(),
    ),
  );
}

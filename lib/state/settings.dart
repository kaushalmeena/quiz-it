import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/difficulty.dart';
import '../models/question_type.dart';
import '../models/settings.dart';
import 'storage.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, QuizSettings>(
  SettingsNotifier.new,
);

/// The options for the next quiz, remembered between launches.
class SettingsNotifier extends Notifier<QuizSettings> {
  static const storageKey = 'quiz_it.settings.v1';

  @override
  QuizSettings build() {
    final raw = ref.read(storageProvider).read(storageKey);
    if (raw == null) return const QuizSettings();
    try {
      return QuizSettings.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on FormatException {
      return const QuizSettings();
    }
  }

  void selectCategory(int? categoryId) => _save(state.withCategory(categoryId));

  void selectDifficulty(Difficulty difficulty) =>
      _save(state.withDifficulty(difficulty));

  void selectType(QuestionType type) => _save(state.withType(type));

  void selectAmount(int amount) => _save(state.withAmount(amount));

  void _save(QuizSettings settings) {
    state = settings;
    ref.read(storageProvider).write(storageKey, json.encode(settings.toJson()));
  }
}

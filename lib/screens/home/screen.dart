import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/effects.dart';
import '../../state/settings.dart';
import '../../widgets/layout.dart';
import '../../widgets/start.dart';
import '../quiz/screen.dart';
import 'topics.dart';
import 'daily.dart';
import 'options.dart';
import 'summary.dart';

/// Quiz setup: lifetime stats, quiz options and a category picker.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openQuiz(BuildContext context) {
    Navigator.of(context).push(QuizScreen.route());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(settingsProvider.select((s) => s.amount));
    final theme = Theme.of(context);
    final insets = contentInsets(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            title: _Brand(),
            actions: [_SoundToggle(), SizedBox(width: 8)],
          ),
          SliverPadding(
            padding: insets.copyWith(top: 8),
            sliver: SliverList.list(
              children: [
                Text(
                  'Ready for a round?',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const StatsSummary(),
                const SizedBox(height: 24),
                const DailyCard(),
                const SectionTitle('Options'),
                const QuizOptions(),
                const SectionTitle('Category'),
              ],
            ),
          ),
          SliverPadding(
            padding: insets.copyWith(bottom: 24),
            sliver: const CategoryGrid(),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: StartQuizButton(
          label: 'Start quiz · $amount questions',
          onStarted: _openQuiz,
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/launcher.png', width: 32, height: 32),
        const SizedBox(width: 12),
        const Text('Quiz-It'),
      ],
    );
  }
}

class _SoundToggle extends ConsumerWidget {
  const _SoundToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(soundProvider);

    void handlePressed() => ref.read(soundProvider.notifier).toggle();

    return IconButton(
      onPressed: handlePressed,
      tooltip: on ? 'Mute sound effects' : 'Turn on sound effects',
      icon: Icon(on ? Icons.volume_up_rounded : Icons.volume_off_rounded),
    );
  }
}

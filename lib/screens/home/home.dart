import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/settings.dart';
import '../../widgets/layout.dart';
import '../../widgets/start_button.dart';
import '../quiz/quiz.dart';
import 'category_grid.dart';
import 'options.dart';
import 'stats_summary.dart';

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
          const SliverAppBar(pinned: true, title: _Brand()),
          SliverPadding(
            padding: insets.copyWith(top: 8),
            sliver: SliverList.list(
              children: [
                Text(
                  'Ready for a round?',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Set your options, pick a topic and test yourself.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const StatsSummary(),
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

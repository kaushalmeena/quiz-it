import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/quiz.dart';
import '../../theme/palette.dart';
import '../../widgets/layout.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/start_button.dart';
import '../quiz/quiz.dart';
import 'review.dart';
import 'score_ring.dart';

/// Score, round stats and an answer review for the finished session.
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const ResultsScreen());
  }

  void _playAgain(BuildContext context) {
    Navigator.of(context).pushReplacement(QuizScreen.route());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(quizProvider);
    if (session == null) return const Scaffold();

    final theme = Theme.of(context);
    final verdict = _Verdict.of(session.score);

    void goHome() => Navigator.of(context).pop();

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Results'),
      ),
      body: ListView(
        padding: contentInsets(context).copyWith(top: 16, bottom: 24),
        children: [
          Center(
            child: ScoreRing(
              score: session.score,
              correct: session.correctCount,
              total: session.total,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            verdict.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            verdict.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          StatRow(
            children: [
              StatTile(
                icon: Icons.check_circle_outline_rounded,
                color: Palette.of(context).success,
                value: '${session.correctCount}/${session.total}',
                label: 'Correct',
              ),
              StatTile(
                icon: Icons.local_fire_department_outlined,
                color: Colors.deepOrange,
                value: '${session.bestStreak}',
                label: 'Best streak',
              ),
              StatTile(
                icon: Icons.timer_outlined,
                value: _formatDuration(session.elapsed),
                label: 'Time',
              ),
            ],
          ),
          const SectionTitle('Review answers'),
          AnswerReview(session: session),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: goHome,
                child: const Text('Home'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: StartQuizButton(
                label: 'Play again',
                icon: Icons.replay_rounded,
                onStarted: _playAgain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return minutes == 0 ? '${seconds}s' : '${minutes}m ${seconds}s';
}

class _Verdict {
  const _Verdict(this.title, this.subtitle);

  factory _Verdict.of(double score) {
    if (score >= 0.9) {
      return const _Verdict('Outstanding!', 'You really know your stuff.');
    }
    if (score >= 0.7) {
      return const _Verdict('Great job!', 'A strong round. Keep it going.');
    }
    if (score >= 0.4) {
      return const _Verdict(
        'Not bad!',
        "A little more practice and you'll ace it.",
      );
    }
    return const _Verdict('Keep going!', 'Every round makes you sharper.');
  }

  final String title;
  final String subtitle;
}

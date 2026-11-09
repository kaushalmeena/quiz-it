import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/clock.dart';
import '../../state/daily.dart';
import '../../state/effects.dart';
import '../../state/quiz.dart';
import '../../widgets/confetti.dart';
import '../../widgets/layout.dart';
import '../../widgets/start_button.dart';
import '../../utils/format.dart';
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
    final dailyStreak = session.isDaily
        ? ref.watch(dailyProvider).streakOn(ref.watch(clockProvider)())
        : 0;

    void goHome() => Navigator.of(context).pop();

    return _Celebration(
      active: session.score >= celebrateScore,
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: Text(session.isDaily ? 'Daily challenge' : 'Results'),
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
            const SizedBox(height: 16),
            _RoundFigures(
              points: session.points,
              bestStreak: session.bestStreak,
              elapsed: session.elapsed,
            ),
            if (session.isDaily) ...[
              const SizedBox(height: 4),
              Text(
                dailyStreak == 1
                    ? 'Daily streak started. See you tomorrow.'
                    : 'Daily streak: $dailyStreak days. See you tomorrow.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SectionTitle('Review answers'),
            AnswerReview(session: session),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: session.isDaily
              ? FilledButton(
                  onPressed: goHome,
                  child: const Text('Back to home'),
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: goHome,
                        child: const Text('Back to home'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StartQuizButton(
                        label: 'Play again',
                        icon: Icons.replay_rounded,
                        onStarted: _playAgain,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Scores at or above this share of correct answers get confetti.
const celebrateScore = 0.8;

/// Confetti and a fanfare, once, when the results first appear.
class _Celebration extends ConsumerStatefulWidget {
  const _Celebration({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  ConsumerState<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends ConsumerState<_Celebration> {
  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(effectsProvider).play(Effect.celebrate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Confetti(active: widget.active, child: widget.child);
  }
}

/// Points, best streak and time for the round, as one line of figures.
class _RoundFigures extends StatelessWidget {
  const _RoundFigures({
    required this.points,
    required this.bestStreak,
    required this.elapsed,
  });

  final int points;
  final int bestStreak;
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final figure = TextStyle(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Text.rich(
      TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: formatNumber(points), style: figure),
          const TextSpan(text: ' points · best streak '),
          TextSpan(text: '$bestStreak', style: figure),
          const TextSpan(text: ' · '),
          TextSpan(text: formatDuration(elapsed), style: figure),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
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

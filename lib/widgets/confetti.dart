import 'dart:math';

import 'package:flutter/material.dart';

/// A one-shot burst of confetti, painted over [child] when [active] is true.
///
/// Skipped entirely when the platform asks for reduced motion.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  static const _count = 140;
  static const _duration = Duration(milliseconds: 2600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  List<_Piece> _pieces = const [];
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !widget.active) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) return;

    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      const Color(0xFFFFC94D),
      const Color(0xFF4DD08A),
      const Color(0xFFFF6B8B),
      const Color(0xFF4DB8FF),
    ];
    final random = Random();
    _pieces = List.generate(_count, (_) => _Piece.random(random, colors));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_pieces.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ConfettiPainter(_pieces, _controller),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Piece {
  _Piece.random(Random random, List<Color> colors)
    : angle = -pi * (0.15 + 0.7 * random.nextDouble()),
      speed = 0.55 + 0.75 * random.nextDouble(),
      spin = (random.nextDouble() - 0.5) * 18,
      sway = random.nextDouble() * pi * 2,
      width = 6 + random.nextDouble() * 6,
      height = 3 + random.nextDouble() * 4,
      color = colors[random.nextInt(colors.length)];

  /// Launch direction in radians (upwards, spread left to right).
  final double angle;

  /// Launch speed as a fraction of the screen height per second.
  final double speed;

  final double spin;
  final double sway;
  final double width;
  final double height;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.progress) : super(repaint: progress);

  final List<_Piece> pieces;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value * 2.6; // seconds
    final origin = Offset(size.width / 2, size.height * 0.28);
    final gravity = size.height * 1.1;
    final opacity = (1 - progress.value) / 0.3;
    final paint = Paint();

    for (final piece in pieces) {
      final velocity = piece.speed * size.height;
      final dx = cos(piece.angle) * velocity * t + sin(piece.sway + t * 4) * 12;
      // Air drag slows the climb, then gravity takes over.
      final dy =
          sin(piece.angle) * velocity * t * (1 - t / 4) +
          0.5 * gravity * t * t * 0.6;

      paint.color = piece.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas
        ..save()
        ..translate(origin.dx + dx, origin.dy + dy)
        ..rotate(piece.spin * t)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.width,
            height: piece.height,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => false;
}

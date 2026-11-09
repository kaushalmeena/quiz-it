import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Horizontal padding that keeps content in a centred column on wide screens.
EdgeInsets contentInsets(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return EdgeInsets.symmetric(
    horizontal: max(20, (width - contentMaxWidth) / 2),
  );
}

/// A sticky action area pinned to the bottom of a screen.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: contentInsets(context).copyWith(top: 12, bottom: 12),
          child: child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

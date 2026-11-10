import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/topics.dart';
import '../../models/category.dart';
import '../../state/settings.dart';
import '../../state/stats.dart';
import '../../theme/radii.dart';

/// A responsive grid of selectable category tiles.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 112,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _CategoryTile(categories[index]),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile(this.category);

  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      settingsProvider.select((s) => s.categoryId == category.id),
    );
    final record = ref.watch(
      statsProvider.select((s) => s.forCategory(category.id)),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const radius = Radii.large;
    // Selection is a light tint of the brand colour plus a border and check,
    // not a saturated fill.
    final background = selected
        ? Color.alphaBlend(
            scheme.primary.withValues(alpha: 0.08),
            scheme.surfaceContainerLow,
          )
        : scheme.surfaceContainerLow;

    void handleTap() {
      ref.read(settingsProvider.notifier).selectCategory(category.id);
    }

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          // Same width in both states so the tile never changes size.
          border: Border.all(
            width: 2,
            color: selected ? scheme.primary : Colors.transparent,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: handleTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 26,
                        color: selected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 22,
                          color: scheme.primary,
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Reserved even before the first quiz, so every tile
                      // keeps the same layout.
                      SizedBox(
                        height: 16,
                        child: record == null
                            ? null
                            : Text(
                                'Best ${(record.bestScore * 100).round()}% · '
                                '${(record.accuracy * 100).round()}% accuracy',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

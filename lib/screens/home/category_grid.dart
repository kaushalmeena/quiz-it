import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog.dart';
import '../../models/category.dart';
import '../../state/settings.dart';

/// A responsive grid of selectable category tiles.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 108,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(20);

    void handleTap() {
      ref.read(settingsProvider.notifier).selectCategory(category.id);
    }

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? scheme.primary
                              : scheme.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 22,
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSecondaryContainer,
                        ),
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(Icons.check_circle, color: scheme.primary),
                    ],
                  ),
                  Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
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

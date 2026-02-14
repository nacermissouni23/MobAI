import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/section_label.dart';

/// Reusable path visualization grid used in Pick and Store screens.
///
/// When [route] is provided (list of [x, y, floor] coordinate triples),
/// the widget renders a dynamic mini-map of the path. Otherwise falls back
/// to the static 5×5 placeholder grid with [startIndex] / [endIndex].
class PathGrid extends StatelessWidget {
  /// AI-suggested route: list of coordinate triples `[x, y, floor]`.
  final List<List<int>>? route;

  /// Legacy fallback: start cell index in a 5×5 grid.
  final int startIndex;

  /// Legacy fallback: end cell index in a 5×5 grid.
  final int endIndex;

  final String? title;
  final String? hint;

  const PathGrid({
    super.key,
    this.route,
    this.startIndex = 20,
    this.endIndex = 4,
    this.title,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            SectionLabel(title!),
            const SizedBox(height: 16),
          ],
          route != null && route!.length >= 2
              ? _buildDynamicRoute()
              : _buildStaticGrid(),
          if (hint != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    hint!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Dynamic route renderer ──────────────────────────────────
  Widget _buildDynamicRoute() {
    final pts = route!;

    // Compute bounding box
    int minX = pts[0][0], maxX = pts[0][0];
    int minY = pts[0][1], maxY = pts[0][1];
    for (final p in pts) {
      if (p[0] < minX) minX = p[0];
      if (p[0] > maxX) maxX = p[0];
      if (p[1] < minY) minY = p[1];
      if (p[1] > maxY) maxY = p[1];
    }
    // Add 1-cell padding
    minX -= 1;
    minY -= 1;
    maxX += 1;
    maxY += 1;

    final cols = (maxX - minX + 1).clamp(3, 20);
    final rows = (maxY - minY + 1).clamp(3, 20);

    // Build set of path cells (keyed by "x,y")
    final pathSet = <String>{};
    for (final p in pts) {
      pathSet.add('${p[0]},${p[1]}');
    }
    final startKey = '${pts.first[0]},${pts.first[1]}';
    final endKey = '${pts.last[0]},${pts.last[1]}';

    return Column(
      children: [
        // Floor badge
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Floor ${pts.first.length > 2 ? pts.first[2] : "?"}  →  Floor ${pts.last.length > 2 ? pts.last[2] : "?"}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        // Grid
        AspectRatio(
          aspectRatio: cols / rows,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              final cellX = minX + (index % cols);
              final cellY = minY + (index ~/ cols);
              final key = '$cellX,$cellY';

              final isStart = key == startKey;
              final isEnd = key == endKey;
              final isOnPath = pathSet.contains(key);

              Color bgColor;
              if (isEnd) {
                bgColor = AppColors.primary;
              } else if (isStart) {
                bgColor = AppColors.primary.withValues(alpha: 0.25);
              } else if (isOnPath) {
                bgColor = AppColors.primary.withValues(alpha: 0.45);
              } else {
                bgColor = AppColors.primary.withValues(alpha: 0.04);
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(2),
                  border: isStart
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                ),
                child: isEnd
                    ? const Icon(Icons.inventory_2, color: Colors.white, size: 12)
                    : isStart
                        ? const Icon(Icons.person_pin_circle,
                            color: AppColors.primary, size: 12)
                        : null,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${pts.length} steps',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMain.withValues(alpha: 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Static 5×5 fallback ─────────────────────────────────────
  Widget _buildStaticGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 25,
        itemBuilder: (context, index) {
          final isTarget = index == endIndex;
          final isStart = index == startIndex;

          return Container(
            decoration: BoxDecoration(
              color: isTarget
                  ? AppColors.primary
                  : isStart
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(4),
              border: isStart
                  ? Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    )
                  : Border.all(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
            ),
            child: isTarget
                ? const Icon(Icons.inventory_2, color: Colors.white, size: 18)
                : isStart
                    ? const Icon(Icons.person_pin_circle,
                        color: AppColors.primary, size: 18)
                    : null,
          );
        },
      ),
    );
  }
}

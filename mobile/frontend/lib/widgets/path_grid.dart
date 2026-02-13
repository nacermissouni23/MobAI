import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/section_label.dart';

/// Reusable 5x5 path visualization grid used in Pick and Store screens.
class PathGrid extends StatelessWidget {
  final int startIndex;
  final int endIndex;
  final String? title;
  final String? hint;

  const PathGrid({
    super.key,
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
          AspectRatio(
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
                      ? const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 18,
                        )
                      : isStart
                      ? const Icon(
                          Icons.person_pin_circle,
                          color: AppColors.primary,
                          size: 18,
                        )
                      : null,
                );
              },
            ),
          ),
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
}

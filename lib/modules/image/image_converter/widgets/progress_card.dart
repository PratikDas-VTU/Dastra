// Progress indicator card during batch conversions.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controller/image_converter_controller.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ImageConverterController>();
    if (!ctrl.isConverting && !ctrl.isAllCompleted) {
      return const SizedBox.shrink();
    }

    final total = ctrl.jobs.length;
    final completed = ctrl.completedCount;
    final failed = ctrl.failedCount;
    final progress = ctrl.overallProgress;

    final isDone = ctrl.isAllCompleted;
    final bgColor = isDone ? context.colors.success.withValues(alpha: 0.05) : context.colors.surface;
    final borderColor = isDone ? context.colors.success.withValues(alpha: 0.2) : context.colors.border;
    final activeColor = isDone ? context.colors.success : context.colors.accentBlue;

    return DastraCard(
      backgroundColor: bgColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                  size: 20,
                  color: activeColor,
                ),
                const SizedBox(width: 8),
                Text(
                  isDone ? 'Conversion Completed' : 'Converting Images...',
                  style: context.textStyles.h4.copyWith(
                    color: isDone ? context.colors.success : context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: context.textStyles.h4.copyWith(
                    color: activeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: context.colors.background,
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
            const SizedBox(height: 12),

            // Completion status details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Processed $completed of $total files',
                  style: context.textStyles.bodyMedium.copyWith(color: context.colors.textSecondary),
                ),
                if (failed > 0)
                  Text(
                    '$failed failed',
                    style: context.textStyles.bodyMedium.copyWith(color: context.colors.error, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ],
        ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

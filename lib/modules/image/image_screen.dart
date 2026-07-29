import '../../core/widgets/widgets.dart';
// Image Tools category screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tool_registry.dart';
import '../../core/utils/responsive.dart';

class ImageScreen extends StatelessWidget {
  const ImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Image Tools',
      subtitle: 'Compress and convert images between formats',
      icon: Icons.image_rounded,
      gradientColors: AppGradients.image.colors,
      body: const AdaptiveLayout(
        mobile: _MobileImageLayout(),
        desktop: _DesktopImageLayout(),
      ),
    );
  }
}

class _MobileImageLayout extends StatelessWidget {
  const _MobileImageLayout();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ToolRegistry.imageTools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.imageTools[index];
                    return AdaptiveToolCard(
                      tool: tool,
                      onTap: () => context.push(tool.route ?? '/tool/${tool.id}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

class _DesktopImageLayout extends StatelessWidget {
  const _DesktopImageLayout();

  @override
  Widget build(BuildContext context) {
    final cols = toolGridColumns(context);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.7,
                  ),
                  itemCount: ToolRegistry.imageTools.length,
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.imageTools[index];
                    return AdaptiveToolCard(
                      tool: tool,
                      onTap: () => context.push(tool.route ?? '/tool/${tool.id}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

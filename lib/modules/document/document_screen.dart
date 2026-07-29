import '../../core/widgets/widgets.dart';
// Document Tools category screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tool_registry.dart';
import '../../core/utils/responsive.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Document Tools',
      subtitle: 'Convert, merge, split and compress PDF files',
      icon: Icons.description_rounded,
      gradientColors: AppGradients.document.colors,
      body: const AdaptiveLayout(
        mobile: _MobileDocumentLayout(),
        desktop: _DesktopDocumentLayout(),
      ),
    );
  }
}

class _MobileDocumentLayout extends StatelessWidget {
  const _MobileDocumentLayout();

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
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ToolRegistry.documentTools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.documentTools[index];
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

class _DesktopDocumentLayout extends StatelessWidget {
  const _DesktopDocumentLayout();

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
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.7,
                  ),
                  itemCount: ToolRegistry.documentTools.length,
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.documentTools[index];
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

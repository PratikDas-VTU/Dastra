import '../../core/widgets/widgets.dart';
// Security Tools category screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tool_registry.dart';
import '../../core/utils/responsive.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Security Tools',
      subtitle: 'Generate and evaluate passwords securely',
      icon: Icons.security_rounded,
      gradientColors: AppGradients.security.colors,
      body: const AdaptiveLayout(
        mobile: _MobileSecurityLayout(),
        desktop: _DesktopSecurityLayout(),
      ),
    );
  }
}

class _MobileSecurityLayout extends StatelessWidget {
  const _MobileSecurityLayout();

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
                  itemCount: ToolRegistry.securityTools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.securityTools[index];
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

class _DesktopSecurityLayout extends StatelessWidget {
  const _DesktopSecurityLayout();

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
                  itemCount: ToolRegistry.securityTools.length,
                  itemBuilder: (context, index) {
                    final tool = ToolRegistry.securityTools[index];
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

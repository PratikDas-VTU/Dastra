import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/tool_registry.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/services/runtime_capability_service.dart';
import '../../settings/controller/user_preferences_controller.dart';

class ResponsiveDashboardLayout extends StatelessWidget {
  const ResponsiveDashboardLayout({
    super.key,
    required this.searchQuery,
    required this.onSearch,
    required this.isSearching,
    required this.filteredTools,
    required this.recentTools,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final String searchQuery;
  final ValueChanged<String> onSearch;
  final bool isSearching;
  final List<ToolItem> filteredTools;
  final List<ToolItem> recentTools;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return DastraPage(
      maxWidth: AppMetrics.maxDashboardWidth,
      padding: EdgeInsets.zero,
      scrollable: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              searchQuery: searchQuery,
              onSearch: onSearch,
              selectedFilter: selectedFilter,
              onFilterSelected: onFilterSelected,
            ),
          ),
          if (isSearching)
            SliverToBoxAdapter(
              child: _SearchResultsSection(tools: filteredTools),
            )
          else ...[
            if (recentTools.isNotEmpty)
              SliverToBoxAdapter(
                child: _RecentSection(recentTools: recentTools),
              ),
            if (selectedFilter == 'Favorites')
              SliverToBoxAdapter(
                child: _FavoritesSection(),
              )
            else
              ..._buildCategorySections(context),
          ],
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections(BuildContext context) {
    final sections = <Widget>[];

    if (selectedFilter == 'All' || selectedFilter == 'Documents') {
      sections.add(
        SliverToBoxAdapter(
        child: _CategorySection(
          title: 'Document Tools',
          subtitle: 'Convert, merge, split and compress PDF files',
          icon: Icons.description_rounded,
          gradientColors: context.colors.documentGradient,
          tools: ToolRegistry.documentTools,
          onSeeAll: () => context.push('/document'),
        ),
        ),
      );
    }
    
    if (selectedFilter == 'All' || selectedFilter == 'Images') {
      sections.add(
        SliverToBoxAdapter(
        child: _CategorySection(
          title: 'Image Tools',
          subtitle: 'Compress and convert images between formats',
          icon: Icons.image_rounded,
          gradientColors: context.colors.imageGradient,
          tools: ToolRegistry.imageTools,
          onSeeAll: () => context.push('/image'),
        ),
        ),
      );
    }

    if (selectedFilter == 'All' || selectedFilter == 'Security') {
      sections.add(
        SliverToBoxAdapter(
        child: _CategorySection(
          title: 'Security Tools',
          subtitle: 'Generate and evaluate passwords securely',
          icon: Icons.security_rounded,
          gradientColors: context.colors.securityGradient,
          tools: ToolRegistry.securityTools,
          onSeeAll: () => context.push('/security'),
        ),
        ),
      );
    }

    return sections;
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesController>();
    final favorites = ToolRegistry.allTools
        .where((t) => prefs.profile.favoriteToolIds.contains(t.id))
        .toList();

    return _CategorySection(
      title: 'Favorites',
      subtitle: 'Your frequently used and starred tools',
      icon: Icons.favorite_rounded,
      gradientColors: [context.colors.accentOrange, context.colors.accentOrange.withValues(alpha: 0.7)],
      tools: favorites,
      onSeeAll: () {},
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.searchQuery,
    required this.onSearch,
    required this.selectedFilter,
    required this.onFilterSelected,
  });
  
  final String searchQuery;
  final ValueChanged<String> onSearch;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  String _computeGreeting(String? name) {
    final hour = DateTime.now().hour;
    String timeOfDay;
    if (hour < 12) {
      timeOfDay = 'Good Morning';
    } else if (hour < 17) {
      timeOfDay = 'Good Afternoon';
    } else {
      timeOfDay = 'Good Evening';
    }
    if (name != null && name.trim().isNotEmpty) {
      return '$timeOfDay, ${name.trim()} 👋';
    }
    return 'Welcome to Dastra 👋';
  }

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    final padding = isCompact ? AppSpacing.md : AppSpacing.xl;
    final prefs = context.watch<UserPreferencesController>();
    final greeting = _computeGreeting(prefs.profile.name);

    final quickActions = [
      DastraQuickActionItem(
        icon: Icons.history_rounded,
        title: 'Resume Last',
        color: context.colors.accentBlue,
        onTap: () {},
      ),
      DastraQuickActionItem(
        icon: Icons.folder_open_rounded,
        title: 'Recent Files',
        color: context.colors.accentPurple,
        onTap: () {},
      ),
      DastraQuickActionItem(
        icon: Icons.favorite_rounded,
        title: 'Favorites',
        color: context.colors.accentOrange,
        onTap: () => onFilterSelected('Favorites'),
      ),
      DastraQuickActionItem(
        icon: Icons.add_rounded,
        title: 'New Conversion',
        color: context.colors.success,
        onTap: () {},
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DastraHeroCard(
            title: greeting,
            subtitle: 'Ready to continue working today?',
            icon: Icons.dashboard_customize_rounded,
            gradient: context.colors.splashGradient,
            actionWidget: DastraQuickActionBar(actions: quickActions),
          ),
          SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
          DastraSearchSection(
            searchQuery: searchQuery,
            onSearch: onSearch,
            filters: const ['All', 'Documents', 'Images', 'Security', 'Favorites'],
            selectedFilter: selectedFilter,
            onFilterSelected: onFilterSelected,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

int _getGridColumns(ScreenSize size) {
  switch (size) {
    case ScreenSize.compact: return 1;
    case ScreenSize.largePhone: return 2;
    case ScreenSize.tablet: return 3;
    case ScreenSize.smallDesktop: return 3;
    case ScreenSize.desktop: return 4;
    case ScreenSize.ultrawide: return 6;
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.recentTools});
  final List<ToolItem> recentTools;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    final cols = _getGridColumns(size);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        0,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        isCompact ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: DastraContentSection(
        title: 'Recently Used Tools',
        subtitle: isCompact ? null : 'Pick up right where you left off',
        padding: EdgeInsets.zero,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: size == ScreenSize.compact ? 3.5 : 1.7,
          ),
          itemCount: recentTools.length,
          itemBuilder: (context, index) {
            final tool = recentTools[index];
            final prefs = context.watch<UserPreferencesController>();
            final caps = context.watch<RuntimeCapabilityService>();
            return AdaptiveToolCard(
              tool: tool,
              onTap: () => context.push(tool.route ?? '/tool/${tool.id}'),
              isFavorite: prefs.isFavorite(tool.id),
              onToggleFavorite: () => prefs.toggleFavorite(tool.id),
              isSupported: caps.isToolSupported(tool),
              unsupportedReason: caps.getUnsupportedReason(tool),
            );
          },
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.tools,
    this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final List<ToolItem> tools;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    final cols = _getGridColumns(size);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        0,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        isCompact ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            gradientColors: gradientColors,
            onSeeAll: onSeeAll,
          ),
          SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: size == ScreenSize.compact ? 3.5 : 1.7,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              final prefs = context.watch<UserPreferencesController>();
              final caps = context.watch<RuntimeCapabilityService>();
              return AdaptiveToolCard(
                tool: tool,
                onTap: () => context.push(tool.route ?? '/tool/${tool.id}'),
                isFavorite: prefs.isFavorite(tool.id),
                onToggleFavorite: () => prefs.toggleFavorite(tool.id),
                isSupported: caps.isToolSupported(tool),
                unsupportedReason: caps.getUnsupportedReason(tool),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({required this.tools});
  final List<ToolItem> tools;

  @override
  Widget build(BuildContext context) {
    final size = Adaptive.of(context);
    final isCompact = size == ScreenSize.compact || size == ScreenSize.largePhone;
    final cols = _getGridColumns(size);

    if (tools.isEmpty) {
      if (isCompact) {
        return const AdaptiveEmptyState(
          title: 'No tools found',
          subtitle: 'Try a different search term',
          icon: Icons.search_off_rounded,
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: context.colors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No tools found', style: context.textStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text('Try a different search term', style: context.textStyles.bodySmall),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCompact ? AppSpacing.md : AppSpacing.xl,
        0,
        isCompact ? AppSpacing.md : AppSpacing.xl,
        isCompact ? AppSpacing.lg : AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isCompact ? AppSpacing.sm : AppSpacing.md),
            child: Text(
              '${tools.length} tool${tools.length == 1 ? '' : 's'} found',
              style: context.textStyles.bodyMedium,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: size == ScreenSize.compact ? 3.5 : 1.7,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              final prefs = context.watch<UserPreferencesController>();
              final caps = context.watch<RuntimeCapabilityService>();
              return AdaptiveToolCard(
                tool: tool,
                onTap: () => context.push(tool.route ?? '/tool/${tool.id}'),
                isFavorite: prefs.isFavorite(tool.id),
                onToggleFavorite: () => prefs.toggleFavorite(tool.id),
                isSupported: caps.isToolSupported(tool),
                unsupportedReason: caps.getUnsupportedReason(tool),
              );
            },
          ),
        ],
      ),
    );
  }
}

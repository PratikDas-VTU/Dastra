// Collapsible sidebar for desktop layout
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';
import '../utils/app_constants.dart';

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

const _coreNavItems = [
  _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', route: '/'),
  _NavItem(icon: Icons.folder_shared_rounded, label: 'Workspace', route: '/workspace'),
];

const _toolNavItems = [
  _NavItem(icon: Icons.description_rounded, label: 'Document', route: '/document'),
  _NavItem(icon: Icons.image_rounded, label: 'Image', route: '/image'),
  _NavItem(icon: Icons.security_rounded, label: 'Security', route: '/security'),
];

const _systemNavItems = [
  _NavItem(icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
  _NavItem(icon: Icons.info_outline_rounded, label: 'About', route: '/about'),
];

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.onToggle,
    this.isOverlayMode = false,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final bool isOverlayMode;

  @override
  Widget build(BuildContext context) {
    final width = collapsed
        ? AppConstants.sidebarCollapsed
        : AppConstants.sidebarExpanded;

    final location = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      color: context.colors.surface,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────
          _SidebarHeader(collapsed: collapsed),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // ── Nav items ───────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              children: [
                ..._coreNavItems.map((item) => _buildItem(item, location, collapsed, context)),
                
                if (!collapsed) Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md, bottom: AppSpacing.xs),
                  child: Text('TOOLS', style: TextStyle(color: context.colors.textDisabled, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ) else const SizedBox(height: AppSpacing.lg),
                ..._toolNavItems.map((item) => _buildItem(item, location, collapsed, context)),
                
                if (!collapsed) Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.md, bottom: AppSpacing.xs),
                  child: Text('SYSTEM', style: TextStyle(color: context.colors.textDisabled, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ) else const SizedBox(height: AppSpacing.lg),
                ..._systemNavItems.map((item) => _buildItem(item, location, collapsed, context)),
              ],
            ),
          ),

          // ── Toggle button ────────────────────────────────────────
          const Divider(height: 1),
          InkWell(
            onTap: onToggle,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: collapsed ? Alignment.center : Alignment.centerRight,
              child: Icon(
                isOverlayMode 
                    ? Icons.close_rounded 
                    : (collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
                color: context.colors.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(_NavItem item, String location, bool collapsed, BuildContext context) {
    final isActive = location == item.route || (item.route != '/' && location.startsWith(item.route));
    return _SidebarItem(
      item: item,
      isActive: isActive,
      collapsed: collapsed,
      onTap: () => context.go(item.route),
    );
  }
}

// Header: logo + app name
class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              AppConstants.logoPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppConstants.appName,
              style: context.textStyles.h4,
            ),
          ],
        ],
      ),
    );
  }
}

// Individual nav item
class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.item,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final collapsed = widget.collapsed;
    final item = widget.item;

    final bgColor = isActive 
        ? context.colors.accentBlue.withValues(alpha: 0.1)
        : (_isHovered ? context.colors.cardHover : Colors.transparent);
        
    final iconColor = isActive 
        ? context.colors.accentBlue 
        : (_isHovered ? context.colors.textPrimary : context.colors.textMuted);
        
    final textColor = isActive 
        ? context.colors.accentBlue 
        : (_isHovered ? context.colors.textPrimary : context.colors.textSecondary);

    return Tooltip(
      message: collapsed ? item.label : '',
      preferBelow: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              curve: AppAnimations.standard,
              height: 44,
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 0 : AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isActive ? context.colors.accentBlue.withValues(alpha: 0.3) : Colors.transparent,
                ),
              ),
              alignment: collapsed ? Alignment.center : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment:
                    collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: iconColor,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      item.label,
                      style: context.textStyles.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

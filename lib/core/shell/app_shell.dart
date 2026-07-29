// Responsive shell: Adaptive navigation system
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';
import 'sidebar.dart';
import 'bottom_nav.dart';
import '../utils/responsive.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarCollapsed = false;
  bool _isSidebarOpenInOverlay = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }
  
  void _toggleOverlaySidebar() {
    setState(() {
      _isSidebarOpenInOverlay = !_isSidebarOpenInOverlay;
    });
  }
  
  void _closeOverlaySidebar() {
    if (_isSidebarOpenInOverlay) {
      setState(() {
        _isSidebarOpenInOverlay = false;
      });
    }
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/workspace')) return 1;
    if (location.startsWith('/document')) return 2;
    if (location.startsWith('/image')) return 3;
    if (location.startsWith('/security')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0; // dashboard
  }

  void _onNavSelected(int index) {
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/workspace'); break;
      case 2: context.go('/document'); break;
      case 3: context.go('/image'); break;
      case 4: context.go('/security'); break;
      case 5: context.go('/settings'); break;
    }
    _closeOverlaySidebar();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      compact: (context, size) => _buildCompactShell(context),
      largePhone: (context, size) => _buildOverlayShell(context),
      tablet: (context, size) => _buildOverlayShell(context),
      smallDesktop: (context, size) => _buildDesktopShell(context, forceCollapsed: true),
      desktop: (context, size) => _buildDesktopShell(context, forceCollapsed: _isSidebarCollapsed),
      builder: (context, size) => _buildDesktopShell(context, forceCollapsed: _isSidebarCollapsed), // ultrawide
    );
  }

  Widget _buildCompactShell(BuildContext context) {
    // Hide overlay state on compact since we use BottomNav
    return Scaffold(
      backgroundColor: context.colors.background,
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: _onNavSelected,
      ),
    );
  }

  Widget _buildOverlayShell(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Custom top bar for overlay trigger
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border(bottom: BorderSide(color: context.colors.border)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      color: context.colors.textPrimary,
                      onPressed: _toggleOverlaySidebar,
                    ),
                  ],
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
          
          // Scrim
          if (_isSidebarOpenInOverlay)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeOverlaySidebar,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            
          // Animated Overlay Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: _isSidebarOpenInOverlay ? 0 : -260, // 260 is expanded width
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 16,
              color: context.colors.surface,
              child: AppSidebar(
                collapsed: false, // overlay is always expanded
                onToggle: _closeOverlaySidebar, // use toggle to close
                isOverlayMode: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopShell(BuildContext context, {required bool forceCollapsed}) {
    // Ensure overlay is closed when resizing back to desktop
    if (_isSidebarOpenInOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeOverlaySidebar();
      });
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Row(
        children: [
          AppSidebar(
            collapsed: forceCollapsed,
            onToggle: _toggleSidebar,
          ),
          Container(width: 1, color: context.colors.border),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

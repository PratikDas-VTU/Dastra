// Bottom navigation bar for mobile/Android layout
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // Determine if we need tighter spacing for compact screens
    final w = MediaQuery.of(context).size.width;
    final isVeryCompact = w < 360;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.border, width: 1),
        ),
        color: context.colors.surface,
      ),
      child: SafeArea(
        bottom: true,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: context.colors.accentBlue.withValues(alpha: 0.15),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: context.colors.accentBlue, size: 24);
              }
              return IconThemeData(color: context.colors.textMuted, size: 24);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final baseStyle = context.textStyles.labelSmall.copyWith(
                fontSize: isVeryCompact ? 10 : 11, // Adaptive label size
              );
              
              if (states.contains(WidgetState.selected)) {
                return baseStyle.copyWith(
                  color: context.colors.accentBlue,
                  fontWeight: FontWeight.w700,
                );
              }
              return baseStyle.copyWith(
                color: context.colors.textMuted,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 64, // Keep it compact but min touch target is 48
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_shared_outlined),
                selectedIcon: Icon(Icons.folder_shared_rounded),
                label: 'Workspace',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description_rounded),
                label: 'Documents',
              ),
              NavigationDestination(
                icon: Icon(Icons.image_outlined),
                selectedIcon: Icon(Icons.image_rounded),
                label: 'Images',
              ),
              NavigationDestination(
                icon: Icon(Icons.security_outlined),
                selectedIcon: Icon(Icons.security_rounded),
                label: 'Security',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

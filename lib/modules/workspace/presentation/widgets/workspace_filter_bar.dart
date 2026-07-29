import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/tool_registry.dart';
import '../controller/workspace_controller.dart';

class WorkspaceFilterBar extends StatelessWidget {
  const WorkspaceFilterBar({super.key, required this.controller});
  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final uniqueCategories = ToolRegistry.allTools
        .map((t) => t.category.name)
        .toSet()
        .map((name) => name[0].toUpperCase() + name.substring(1))
        .toList();
    
    final filterOptions = ['All Tools', ...uniqueCategories];

    return DastraSearchSection(
      searchQuery: controller.searchQuery,
      onSearch: controller.setSearchQuery,
      filters: filterOptions,
      selectedFilter: controller.selectedTool,
      onFilterSelected: (val) {
        controller.setToolFilter(val.isEmpty ? null : val);
      },
      trailingWidget: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: controller.sortOption,
          icon: Icon(Icons.sort_rounded, color: context.colors.textMuted, size: 20),
          dropdownColor: context.colors.surface,
          onChanged: (opt) {
            if (opt != null) controller.setSortOption(opt);
          },
          items: const [
            DropdownMenuItem(value: SortOption.dateDesc, child: Text('Newest First')),
            DropdownMenuItem(value: SortOption.dateAsc, child: Text('Oldest First')),
            DropdownMenuItem(value: SortOption.nameAsc, child: Text('Name (A-Z)')),
            DropdownMenuItem(value: SortOption.nameDesc, child: Text('Name (Z-A)')),
            DropdownMenuItem(value: SortOption.sizeDesc, child: Text('Largest First')),
            DropdownMenuItem(value: SortOption.sizeAsc, child: Text('Smallest First')),
          ],
        ),
      ),
    );
  }
}

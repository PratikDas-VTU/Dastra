import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'dastra_search_bar.dart';
import 'dastra_filter_chip.dart';

class DastraSearchSection extends StatelessWidget {
  const DastraSearchSection({
    super.key,
    required this.searchQuery,
    required this.onSearch,
    required this.filters,
    this.selectedFilter,
    this.onFilterSelected,
    this.trailingWidget,
  });

  final String searchQuery;
  final ValueChanged<String> onSearch;
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String>? onFilterSelected;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DastraSearchBar(
          onChanged: onSearch,
        ),
        if (filters.isNotEmpty && onFilterSelected != null) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...filters.map((f) {
                final isSelected = selectedFilter == f || (selectedFilter == null && (f == 'All' || f == 'All Tools'));
                return DastraFilterChip(
                  label: f,
                  isSelected: isSelected,
                  onSelected: (selected) {
                    if (selected) onFilterSelected!(f);
                  },
                );
              }),
              if (trailingWidget != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailingWidget!,
              ],
            ],
          ),
        ],
      ],
    );
  }
}

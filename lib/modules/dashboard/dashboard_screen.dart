import '../../core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/utils/tool_registry.dart';
import '../../core/di/service_locator.dart';
import '../../modules/workspace/domain/workspace_repository.dart';
import '../settings/controller/user_preferences_controller.dart';
import 'layouts/responsive_dashboard_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  List<ToolItem> _recentTools = [];

  @override
  void initState() {
    super.initState();
    _loadRecentTools();
  }

  Future<void> _loadRecentTools() async {
    try {
      final repo = sl<WorkspaceRepository>();
      final toolIds = await repo.getRecentlyUsedToolIds(4);
      
      final tools = toolIds.map((id) {
        return ToolRegistry.allTools.firstWhere(
          (t) => t.id == id,
          orElse: () => ToolRegistry.allTools.first,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _recentTools = tools.where((t) => toolIds.contains(t.id)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // just catch
        });
      }
    }
  }

  String _selectedFilter = 'All';

  List<ToolItem> _getFilteredTools(BuildContext context) {
    // 1. All Tools -> 2. Search Query
    Iterable<ToolItem> tools = ToolRegistry.search(_searchQuery);
    
    // 3. Category Filter / 4. Favorites Filter
    if (_selectedFilter == 'Favorites') {
      final prefs = context.read<UserPreferencesController>();
      final favoriteIds = prefs.profile.favoriteToolIds;
      tools = tools.where((t) => favoriteIds.contains(t.id));
    } else if (_selectedFilter != 'All') {
      // Find category mapping
      ToolCategory? targetCategory;
      switch (_selectedFilter) {
        case 'Documents': targetCategory = ToolCategory.document; break;
        case 'Images': targetCategory = ToolCategory.image; break;
        case 'Security': targetCategory = ToolCategory.security; break;
      }
      if (targetCategory != null) {
        tools = tools.where((t) => t.category == targetCategory);
      }
    }
    
    // 5. Sort (ToolRegistry already sorts by category/name, so we preserve it)
    return tools.toList();
  }

  bool get _isSearching => _searchQuery.isNotEmpty;

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      showGlobalBranding: true,
      body: ResponsiveDashboardLayout(
        searchQuery: _searchQuery,
        onSearch: _onSearch,
        isSearching: _isSearching,
        filteredTools: _getFilteredTools(context),
        recentTools: _recentTools,
        selectedFilter: _selectedFilter,
        onFilterSelected: _onFilterSelected,
      ),
    );
  }
}

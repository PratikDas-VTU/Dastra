import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart'; // For SectionHeader
import '../../../core/di/service_locator.dart';
import '../../../core/utils/responsive.dart';
import 'controller/workspace_controller.dart';
import 'widgets/workspace_stats_cards.dart';
import 'widgets/workspace_filter_bar.dart';
import 'widgets/workspace_record_card.dart';
import 'widgets/workspace_empty_state.dart';
import 'widgets/workspace_quick_actions.dart';
import '../domain/models/workspace_record.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final WorkspaceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<WorkspaceController>();
    _controller.loadRecords();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(BuildContext context, String title, [String? subtitle]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.typography.sectionTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: context.typography.bodyMedium.copyWith(color: context.colors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<WorkspaceRecord> records, WorkspaceEmptyStateType emptyType) {
    if (records.isEmpty) {
      return WorkspaceEmptyState(type: emptyType);
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return WorkspaceRecordCard(
          record: records[index],
          controller: _controller,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      title: 'Workspace',
      subtitle: 'Manage your conversions and files',
      icon: Icons.folder_shared_rounded,
      gradientColors: AppGradients.image.colors,
      showGlobalBranding: true,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.accentBlue),
            );
          }

          final hasAnyRecords = _controller.totalConversions > 0;
          if (!hasAnyRecords) {
            return const WorkspaceEmptyState(type: WorkspaceEmptyStateType.history);
          }

          final isFiltering = _controller.searchQuery.isNotEmpty || _controller.selectedTool != null;
          final allFiltered = _controller.filteredRecords;

          return SingleChildScrollView(
            padding: EdgeInsets.all(Adaptive.of(context) == ScreenSize.compact ? AppSpacing.md : AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFiltering) ...[
                  // 1. Quick Actions
                  WorkspaceQuickActions(
                    actions: [
                      WorkspaceQuickAction(
                        icon: Icons.history_rounded,
                        title: 'Resume Last',
                        color: context.colors.accentBlue,
                        onTap: () {
                          if (allFiltered.isNotEmpty) {
                            _controller.openFile(allFiltered.first);
                          }
                        },
                      ),
                      WorkspaceQuickAction(
                        icon: Icons.folder_open_rounded,
                        title: 'Open Output',
                        color: context.colors.accentPurple,
                        onTap: () {
                          if (allFiltered.isNotEmpty) {
                            _controller.openFolder(allFiltered.first);
                          }
                        },
                      ),
                      WorkspaceQuickAction(
                        icon: Icons.file_upload_outlined,
                        title: 'Import Files',
                        color: context.colors.accentOrange,
                        onTap: () {},
                      ),
                      WorkspaceQuickAction(
                        icon: Icons.add_rounded,
                        title: 'New Conversion',
                        color: context.colors.success,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // 2. Recent Conversions
                  _buildSectionHeader(context, 'Recent Conversions'),
                  _buildRecordList(context, allFiltered.take(3).toList(), WorkspaceEmptyStateType.recent),
                  const SizedBox(height: AppSpacing.xxl),
                ],

                // 3. Search & Filters
                WorkspaceFilterBar(controller: _controller),
                const SizedBox(height: AppSpacing.xl),

                if (isFiltering) ...[
                  // Search Results
                  _buildSectionHeader(context, 'Search Results', '${allFiltered.length} items found'),
                  _buildRecordList(context, allFiltered, WorkspaceEmptyStateType.search),
                ] else ...[
                  // 4. Favorites
                  _buildSectionHeader(context, 'Favorites'),
                  _buildRecordList(context, allFiltered.where((r) => r.isFavorite).toList(), WorkspaceEmptyStateType.favorites),
                  const SizedBox(height: AppSpacing.xxl),

                  // 5. History
                  _buildSectionHeader(context, 'History'),
                  _buildRecordList(context, allFiltered.skip(3).toList(), WorkspaceEmptyStateType.history),
                  const SizedBox(height: AppSpacing.xxl),

                  // 6. Statistics
                  _buildSectionHeader(context, 'Statistics'),
                  WorkspaceStatsCards(controller: _controller),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}


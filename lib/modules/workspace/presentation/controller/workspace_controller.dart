import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/file_launcher.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import '../../../../core/utils/tool_registry.dart';

import '../../domain/models/workspace_record.dart';
import '../../domain/workspace_repository.dart';

enum SortOption { dateDesc, dateAsc, nameAsc, nameDesc, sizeDesc, sizeAsc }

class WorkspaceController extends ChangeNotifier {
  final WorkspaceRepository _repository;
  
  WorkspaceController({required WorkspaceRepository repository}) : _repository = repository;

  List<WorkspaceRecord> _allRecords = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedTool;
  SortOption _sortOption = SortOption.dateDesc;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedTool => _selectedTool;
  SortOption get sortOption => _sortOption;

  // ── Stats ────────────────────────────────────────────────────────
  int get totalConversions => _allRecords.length;
  
  int get storageUsed => _allRecords.fold(0, (sum, record) => sum + record.outputSize);
  
  int get todayConversions {
    final now = DateTime.now();
    return _allRecords.where((r) => 
      r.createdAt.year == now.year &&
      r.createdAt.month == now.month &&
      r.createdAt.day == now.day
    ).length;
  }
  
  String get mostUsedTool {
    if (_allRecords.isEmpty) return 'None';
    final grouped = groupBy(_allRecords, (WorkspaceRecord r) => r.toolName);
    var maxCount = 0;
    var maxTool = 'None';
    grouped.forEach((key, list) {
      if (list.length > maxCount) {
        maxCount = list.length;
        maxTool = key;
      }
    });
    return maxTool;
  }

  // ── Filtering & Sorting ──────────────────────────────────────────
  List<WorkspaceRecord> get filteredRecords {
    var filtered = _allRecords.where((r) {
      if (_selectedTool != null && _selectedTool != 'All Tools') {
        final toolItem = ToolRegistry.allTools.firstWhereOrNull((t) => t.id == r.toolId);
        if (toolItem != null && toolItem.category.name != _selectedTool!.toLowerCase()) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchOutput = p.basename(r.outputPath).toLowerCase().contains(query);
        final matchInput = p.basename(r.inputPath).toLowerCase().contains(query);
        final matchTool = r.toolName.toLowerCase().contains(query);
        if (!matchOutput && !matchInput && !matchTool) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case SortOption.dateDesc:
          return b.createdAt.compareTo(a.createdAt);
        case SortOption.dateAsc:
          return a.createdAt.compareTo(b.createdAt);
        case SortOption.nameAsc:
          return p.basename(a.outputPath).toLowerCase().compareTo(p.basename(b.outputPath).toLowerCase());
        case SortOption.nameDesc:
          return p.basename(b.outputPath).toLowerCase().compareTo(p.basename(a.outputPath).toLowerCase());
        case SortOption.sizeDesc:
          return b.outputSize.compareTo(a.outputSize);
        case SortOption.sizeAsc:
          return a.outputSize.compareTo(b.outputSize);
      }
    });
    return filtered;
  }

  // ── Actions ──────────────────────────────────────────────────────
  Future<void> loadRecords() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allRecords = await _repository.getAllRecords();
    } catch (e) {
      debugPrint('Error loading workspace records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setToolFilter(String? toolId) {
    _selectedTool = toolId;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  Future<void> openFile(WorkspaceRecord record) async {
    await FileLauncher.openFile(record.outputPath);
  }

  Future<void> openFolder(WorkspaceRecord record) async {
    await FileLauncher.openFolder(record.outputFolder);
  }

  Future<void> deleteRecord(WorkspaceRecord record, {required bool deleteFileFromDisk}) async {
    try {
      if (deleteFileFromDisk) {
        final file = File(record.outputPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _repository.deleteRecord(record.id);
      _allRecords.removeWhere((r) => r.id == record.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting record: $e');
    }
  }

  Future<void> toggleFavorite(WorkspaceRecord record) async {
    try {
      final newStatus = !record.isFavorite;
      await _repository.toggleFavorite(record.id, newStatus);
      await loadRecords();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }
}

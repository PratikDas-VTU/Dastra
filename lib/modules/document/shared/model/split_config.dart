abstract class SplitConfig {
  const SplitConfig();

  /// Converts the configuration into a list of specific page groups to extract.
  /// Each List<int> represents one output PDF, containing the 0-indexed page numbers.
  List<List<int>> resolve(int totalPages);
}

class ExtractAllSplitConfig extends SplitConfig {
  const ExtractAllSplitConfig();

  @override
  List<List<int>> resolve(int totalPages) {
    return List.generate(totalPages, (index) => [index]);
  }
}

class IntervalSplitConfig extends SplitConfig {
  final int pagesPerSplit;

  const IntervalSplitConfig({required this.pagesPerSplit});

  @override
  List<List<int>> resolve(int totalPages) {
    if (pagesPerSplit <= 0) return [];
    
    final List<List<int>> groups = [];
    for (int i = 0; i < totalPages; i += pagesPerSplit) {
      final List<int> group = [];
      for (int j = 0; j < pagesPerSplit && i + j < totalPages; j++) {
        group.add(i + j);
      }
      groups.add(group);
    }
    return groups;
  }
}

class CustomRangeSplitConfig extends SplitConfig {
  final String rangeString;

  const CustomRangeSplitConfig({required this.rangeString});

  @override
  List<List<int>> resolve(int totalPages) {
    if (rangeString.trim().isEmpty) return [];

    final List<List<int>> groups = [];
    final List<String> parts = rangeString.split(',');

    for (final part in parts) {
      final cleaned = part.trim();
      if (cleaned.isEmpty) continue;

      final List<int> group = [];
      
      if (cleaned.contains('-')) {
        final bounds = cleaned.split('-');
        if (bounds.length == 2) {
          final start = int.tryParse(bounds[0].trim());
          final end = int.tryParse(bounds[1].trim());
          
          if (start != null && end != null && start > 0 && end > 0) {
            // 1-indexed to 0-indexed
            final min = start <= end ? start : end;
            final max = start <= end ? end : start;
            
            for (int i = min; i <= max; i++) {
              if (i <= totalPages) {
                group.add(i - 1);
              }
            }
          }
        }
      } else {
        final val = int.tryParse(cleaned);
        if (val != null && val > 0 && val <= totalPages) {
          group.add(val - 1);
        }
      }
      
      if (group.isNotEmpty) {
        groups.add(group);
      }
    }
    
    return groups;
  }
}

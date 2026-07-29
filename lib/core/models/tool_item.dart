// Data model representing a single productivity tool in Dastra
import 'package:flutter/material.dart';
import 'tool_category.dart';

/// Immutable model for a tool entry in the registry
class ToolItem {
  const ToolItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.gradientColors,
    this.route,
    this.supportedPlatforms,
    this.requiredRuntimes = const [],
    this.tags = const [],
  });

  /// Unique identifier — used for routing
  final String id;

  /// Display name shown on the card
  final String title;

  /// Short description shown below the title
  final String description;

  /// Material icon data
  final IconData icon;

  /// Top-level category grouping
  final ToolCategory category;

  /// Two gradient stop colors for the icon container
  final List<Color> gradientColors;

  /// Named go_router route (optional — uses placeholder if null)
  final String? route;

  /// Optional list of supported platforms. If null, supported on all platforms.
  final List<TargetPlatform>? supportedPlatforms;

  /// Optional list of external runtimes required (e.g., 'python', 'libreoffice', 'tesseract')
  final List<String> requiredRuntimes;

  /// Tags for improving searchability
  final List<String> tags;
}

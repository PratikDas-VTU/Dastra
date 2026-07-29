// Central registry of all tools available in Dastra.
// To add a new tool, simply add a ToolItem to the relevant list below.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/feature_metadata.dart';

class ToolIds {
  ToolIds._();
  
  static const String pdfToWord = 'pdf_to_word';
  static const String wordToPdf = 'word_to_pdf';
  static const String pptToPdf = 'ppt_to_pdf';
  static const String pdfToImages = 'pdf_to_images';
  static const String imagesToPdf = 'images_to_pdf';
  static const String mergePdf = 'merge_pdf';
  static const String splitPdf = 'split_pdf';
  static const String compressPdf = 'compress_pdf';
  static const String compressImage = 'compress_image';
  static const String jpgPngConvert = 'jpg_png_convert';
  static const String passwordGenerator = 'password_generator';
  static const String passwordStrength = 'password_strength';
}

class ToolRegistry {
  ToolRegistry._();

  // ── Document Tools ────────────────────────────────────────────────────────
  static const List<ToolItem> documentTools = [
    ToolItem(
      id: ToolIds.pdfToWord,
      title: 'PDF to Word',
      description: 'Convert PDF documents to editable Word files',
      icon: Icons.description_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
      route: '/document/pdf-to-word',
      supportedPlatforms: [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux],
      requiredRuntimes: ['python'],
      metadata: const FeatureMetadata(availability: FeatureAvailability.pro),
    ),
    ToolItem(
      id: ToolIds.wordToPdf,
      title: 'Word to PDF',
      description: 'Export Word documents as PDF files',
      icon: Icons.picture_as_pdf_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      route: '/document/word-to-pdf',
      supportedPlatforms: [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux],
      metadata: const FeatureMetadata(availability: FeatureAvailability.pro),
    ),
    ToolItem(
      id: ToolIds.pptToPdf,
      title: 'PPT to PDF',
      description: 'Convert PowerPoint presentations to PDF',
      icon: Icons.slideshow_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFFF97316), Color(0xFFEC4899)],
      route: '/document/ppt-to-pdf',
      supportedPlatforms: [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux],
      metadata: const FeatureMetadata(availability: FeatureAvailability.pro),
    ),
    ToolItem(
      id: ToolIds.pdfToImages,
      title: 'PDF to Images',
      description: 'Convert PDF pages into image files',
      icon: Icons.image_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
      route: '/document/pdf-to-images',
    ),
    ToolItem(
      id: ToolIds.imagesToPdf,
      title: 'Images to PDF',
      description: 'Combine images into a single PDF file',
      icon: Icons.collections_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF10B981), Color(0xFF06B6D4)],
      route: '/document/images-to-pdf',
    ),
    ToolItem(
      id: ToolIds.mergePdf,
      title: 'Merge PDF',
      description: 'Combine multiple PDFs into one document',
      icon: Icons.merge_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      route: '/document/pdf-merge',
    ),
    ToolItem(
      id: ToolIds.splitPdf,
      title: 'Split PDF',
      description: 'Divide a PDF into separate pages or ranges',
      icon: Icons.call_split_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      route: '/document/pdf-split',
    ),
    ToolItem(
      id: ToolIds.compressPdf,
      title: 'Compress PDF',
      description: 'Reduce PDF file size without losing quality',
      icon: Icons.compress_rounded,
      category: ToolCategory.document,
      gradientColors: [Color(0xFF10B981), Color(0xFF3B82F6)],
      route: '/document/compress-pdf',
      supportedPlatforms: [TargetPlatform.windows, TargetPlatform.macOS, TargetPlatform.linux],
      requiredRuntimes: ['python'],
    ),
  ];

  // ── Image Tools ───────────────────────────────────────────────────────────
  static const List<ToolItem> imageTools = [
    ToolItem(
      id: ToolIds.compressImage,
      title: 'Compress Image',
      description: 'Reduce image file sizes while preserving quality',
      icon: Icons.photo_size_select_large_rounded,
      category: ToolCategory.image,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
      route: '/image/compressor',

    ),
    ToolItem(
      id: ToolIds.jpgPngConvert,
      title: 'JPG ↔ PNG',
      description: 'Convert between JPG and PNG formats instantly',
      icon: Icons.swap_horiz_rounded,
      category: ToolCategory.image,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
      route: '/image/converter',

    ),
  ];

  // ── Security Tools ────────────────────────────────────────────────────────
  static const List<ToolItem> securityTools = [
    ToolItem(
      id: ToolIds.passwordGenerator,
      title: 'Password Generator',
      description: 'Generate strong, random passwords instantly',
      icon: Icons.key_rounded,
      category: ToolCategory.security,
      gradientColors: [Color(0xFFF97316), Color(0xFFEF4444)],
      // Route to the fully implemented screen.
      route: '/security/password-generator',

    ),
    ToolItem(
      id: ToolIds.passwordStrength,
      title: 'Password Strength',
      description: 'Analyse and score the strength of any password',
      icon: Icons.security_rounded,
      category: ToolCategory.security,
      gradientColors: [Color(0xFFEF4444), Color(0xFFF97316)],
      route: '/security/password-checker',

    ),
  ];

  /// All tools combined
  static List<ToolItem> get allTools => [
    ...documentTools,
    ...imageTools,
    ...securityTools,
  ];

  /// Tools filtered by category
  static List<ToolItem> byCategory(ToolCategory category) =>
      allTools.where((t) => t.category == category).toList();

  /// Search tools by query string
  static List<ToolItem> search(String query) {
    if (query.isEmpty) return allTools;
    final q = query.toLowerCase();
    return allTools.where((t) =>
      t.title.toLowerCase().contains(q) ||
      t.description.toLowerCase().contains(q) ||
      t.category.label.toLowerCase().contains(q),
    ).toList();
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FileIconResolver {
  static IconData getIcon(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.co_present_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_view_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
      case 'gif':
        return Icons.image_rounded;
      case 'txt':
      case 'csv':
        return Icons.text_snippet_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Icons.movie_rounded;
      case 'mp3':
      case 'wav':
        return Icons.audio_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
  
  static Color getColor(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'pdf':
        return AppColors.error; // Red-ish for PDF
      case 'doc':
      case 'docx':
        return AppColors.accentBlue; // Blue for Word
      case 'ppt':
      case 'pptx':
        return AppColors.accentOrange; // Orange for PPT
      case 'xls':
      case 'xlsx':
        return AppColors.success; // Green for Excel
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
      case 'gif':
        return AppColors.accentPurple; // Purple for Images
      case 'zip':
      case 'rar':
      case '7z':
        return AppColors.warning; // Yellow for Archives
      default:
        return AppColors.textSecondary; // Gray default
    }
  }
}

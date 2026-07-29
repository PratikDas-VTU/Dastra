import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

extension TextStylesContextExtension on BuildContext {
  _ContextualTextStyles get textStyles => _ContextualTextStyles(this);
}

class _ContextualTextStyles {
  final BuildContext context;
  _ContextualTextStyles(this.context);

  TextStyle get displayLarge => AppTextStyles.displayLarge.copyWith(color: context.colors.textPrimary);
  TextStyle get displayMedium => AppTextStyles.displayMedium.copyWith(color: context.colors.textPrimary);
  TextStyle get h1 => AppTextStyles.h1.copyWith(color: context.colors.textPrimary);
  TextStyle get h2 => AppTextStyles.h2.copyWith(color: context.colors.textPrimary);
  TextStyle get h3 => AppTextStyles.h3.copyWith(color: context.colors.textPrimary);
  TextStyle get h4 => AppTextStyles.h4.copyWith(color: context.colors.textPrimary);
  
  TextStyle get bodyLarge => AppTextStyles.bodyLarge.copyWith(color: context.colors.textPrimary);
  TextStyle get bodyMedium => AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary);
  TextStyle get bodySmall => AppTextStyles.bodySmall.copyWith(color: context.colors.textSecondary);
  
  TextStyle get labelLarge => AppTextStyles.labelLarge.copyWith(color: context.colors.textPrimary);
  TextStyle get labelMedium => AppTextStyles.labelMedium.copyWith(color: context.colors.textSecondary);
  TextStyle get labelSmall => AppTextStyles.labelSmall.copyWith(color: context.colors.textMuted);
  
  TextStyle get caption => AppTextStyles.caption.copyWith(color: context.colors.textMuted);
  TextStyle get button => AppTextStyles.button.copyWith(color: context.colors.textPrimary);
  TextStyle get searchHint => AppTextStyles.searchHint.copyWith(color: context.colors.textSecondary);
}

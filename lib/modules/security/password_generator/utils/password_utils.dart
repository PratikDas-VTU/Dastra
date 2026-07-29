// Pure utility functions and enums for the password generator.
// No Flutter UI imports — fully unit-testable.
import 'dart:math';
import 'package:flutter/material.dart' show Color;
import '../model/password_settings.dart';

// ── Strength Level ─────────────────────────────────────────────────────────

/// Password strength categories derived from entropy bits.
enum StrengthLevel {
  veryWeak,
  weak,
  fair,
  strong,
  veryStrong;

  /// Human-readable label.
  String get label {
    switch (this) {
      case StrengthLevel.veryWeak:
        return 'Very Weak';
      case StrengthLevel.weak:
        return 'Weak';
      case StrengthLevel.fair:
        return 'Fair';
      case StrengthLevel.strong:
        return 'Strong';
      case StrengthLevel.veryStrong:
        return 'Very Strong';
    }
  }

  /// Progress fraction 0.0–1.0 for strength bar rendering.
  double get progress => (index + 1) / 5.0;

  /// Representative colour for this strength tier.
  Color get color {
    switch (this) {
      case StrengthLevel.veryWeak:
        return const Color(0xFFEF4444); // red
      case StrengthLevel.weak:
        return const Color(0xFFF97316); // orange
      case StrengthLevel.fair:
        return const Color(0xFFEAB308); // yellow
      case StrengthLevel.strong:
        return const Color(0xFF22C55E); // green
      case StrengthLevel.veryStrong:
        return const Color(0xFF06B6D4); // cyan
    }
  }
}

// ── Character Sets ─────────────────────────────────────────────────────────

/// Pure utility functions — all methods are static.
class PasswordUtils {
  PasswordUtils._();

  static const String _upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowerChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numberChars = '0123456789';
  // Symbols chosen to avoid ambiguity and shell-escape issues.
  static const String _symbolChars = r'!@#$%^&*()-_=+[]{}|;:,.<>?/`~';
  // Characters excluded when "Exclude Similar" is enabled.
  static const String _similarChars = 'O0lI1|';

  // ── Charset Building ───────────────────────────────────────────────────

  /// Builds the effective character pool from [settings].
  ///
  /// Applies charset flags, then removes similar / custom-excluded chars.
  static String buildCharset(PasswordSettings settings) {
    final buffer = StringBuffer();
    if (settings.useUppercase) buffer.write(_upperChars);
    if (settings.useLowercase) buffer.write(_lowerChars);
    if (settings.useNumbers) buffer.write(_numberChars);
    if (settings.useSymbols) buffer.write(_symbolChars);

    var charset = buffer.toString();

    // Remove visually similar characters if requested.
    if (settings.excludeSimilar) {
      charset = charset
          .split('')
          .where((c) => !_similarChars.contains(c))
          .join();
    }

    // Remove user-specified characters.
    if (settings.excludeCustom.isNotEmpty) {
      final excluded = settings.excludeCustom.split('').toSet();
      charset = charset
          .split('')
          .where((c) => !excluded.contains(c))
          .join();
    }

    // De-duplicate in case of overlapping exclusion rules.
    final seen = <String>{};
    charset = charset.split('').where(seen.add).join();

    return charset;
  }

  /// Returns the effective charset size given [settings].
  static int charsetSize(PasswordSettings settings) =>
      buildCharset(settings).length;

  // ── Password Generation ────────────────────────────────────────────────

  /// Generates a single cryptographically secure password from [charset], embedding [customBase].
  static String generateOne(String charset, int length, String customBase) {
    if (customBase.length >= length) {
      return customBase.substring(0, length);
    }

    final randomLength = length - customBase.length;
    if (charset.isEmpty) return customBase;

    final rng = Random.secure();
    final randomPart = List.generate(
      randomLength,
      (_) => charset[rng.nextInt(charset.length)],
    ).join();

    return '$customBase$randomPart';
  }

  /// Generates [settings.count] passwords based on [settings].
  ///
  /// Returns empty strings when the charset is empty (all chars excluded) and customBase is empty.
  static List<String> generatePasswords(PasswordSettings settings) {
    final charset = buildCharset(settings);
    if (charset.isEmpty && settings.customBase.isEmpty) {
      return List.filled(settings.count, '');
    }
    return List.generate(
      settings.count,
      (_) => generateOne(charset, settings.length, settings.customBase),
    );
  }

  // ── Entropy & Strength ─────────────────────────────────────────────────

  /// Calculates Shannon entropy of a specific password string dynamically.
  static double calculatePasswordEntropy(String password) {
    if (password.isEmpty) return 0.0;
    int poolSize = 0;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#$%^&*()\-=_+\[\]{}|;:,.<>?/`~]'))) poolSize += 30;
    if (poolSize == 0) poolSize = 1;
    return password.length * log(poolSize) / log(2);
  }

  /// Calculates Shannon entropy in bits for settings.
  static double calculateEntropy(PasswordSettings settings) {
    final size = charsetSize(settings);
    if (size <= 0 || settings.length <= 0) return 0.0;
    return settings.length * log(size) / log(2);
  }

  /// Maps [entropy] bits to a [StrengthLevel].
  ///
  /// Thresholds (NIST-inspired):
  /// * < 28 bits  → Very Weak
  /// * 28–35 bits → Weak
  /// * 36–59 bits → Fair
  /// * 60–79 bits → Strong
  /// * ≥ 80 bits  → Very Strong
  static StrengthLevel strengthLevel(double entropy) {
    if (entropy < 28) return StrengthLevel.veryWeak;
    if (entropy < 36) return StrengthLevel.weak;
    if (entropy < 60) return StrengthLevel.fair;
    if (entropy < 80) return StrengthLevel.strong;
    return StrengthLevel.veryStrong;
  }

  // ── Crack Time Estimate ────────────────────────────────────────────────

  /// Estimates offline crack time assuming 10¹² guesses/second
  /// (modern GPU cluster attacking a fast hash).
  static String estimateCrackTime(double entropy) {
    if (entropy <= 0) return 'instantly';

    // Above this threshold 2^entropy exceeds double precision without overflow
    // → safely say "beyond the universe" (universe ≈ 4.3 × 10¹⁷ seconds).
    if (entropy >= 256) return 'longer than the age of the universe';

    const guessesPerSecond = 1e12; // 10^12 / sec
    final seconds = pow(2.0, entropy) / guessesPerSecond;

    if (seconds < 1) return 'less than a second';
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(0)} second${seconds < 2 ? '' : 's'}';
    }
    final minutes = seconds / 60;
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} minute${minutes < 2 ? '' : 's'}';
    }
    final hours = minutes / 60;
    if (hours < 24) {
      return '${hours.toStringAsFixed(0)} hour${hours < 2 ? '' : 's'}';
    }
    final days = hours / 24;
    if (days < 30.44) {
      return '${days.toStringAsFixed(0)} day${days < 2 ? '' : 's'}';
    }
    final months = days / 30.44;
    if (months < 12) {
      return '${months.toStringAsFixed(0)} month${months < 2 ? '' : 's'}';
    }
    final years = days / 365.25;
    if (years < 1000) return '${years.toStringAsFixed(0)} years';
    if (years < 1e6) return '${(years / 1e3).toStringAsFixed(0)}K years';
    if (years < 1e9) return '${(years / 1e6).toStringAsFixed(1)}M years';
    if (years < 1e12) return '${(years / 1e9).toStringAsFixed(1)}B years';
    return 'longer than the age of the universe';
  }
}

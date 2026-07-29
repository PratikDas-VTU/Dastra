import 'package:flutter/material.dart' show Color;

/// Password strength categories derived from score/heuristics.
enum PasswordStrengthLevel {
  veryWeak,
  weak,
  fair,
  good,
  strong,
  excellent;

  /// Human-readable label.
  String get label {
    switch (this) {
      case PasswordStrengthLevel.veryWeak: return 'Very Weak';
      case PasswordStrengthLevel.weak: return 'Weak';
      case PasswordStrengthLevel.fair: return 'Fair';
      case PasswordStrengthLevel.good: return 'Good';
      case PasswordStrengthLevel.strong: return 'Strong';
      case PasswordStrengthLevel.excellent: return 'Excellent';
    }
  }

  /// Description of the security level.
  String get description {
    switch (this) {
      case PasswordStrengthLevel.veryWeak: return 'Suitable only for throwaway accounts.';
      case PasswordStrengthLevel.weak: return 'Suitable only for low-risk accounts.';
      case PasswordStrengthLevel.fair: return 'Acceptable for standard web accounts.';
      case PasswordStrengthLevel.good: return 'Strong enough for most important accounts.';
      case PasswordStrengthLevel.strong: return 'Suitable for banking and sensitive accounts.';
      case PasswordStrengthLevel.excellent: return 'Exceptional security for high-value targets.';
    }
  }

  /// Progress fraction 0.0–1.0 for strength bar rendering.
  double get progress => (index + 1) / 6.0;

  /// Color representing this strength tier.
  Color get color {
    switch (this) {
      case PasswordStrengthLevel.veryWeak:
        return const Color(0xFFEF4444); // red
      case PasswordStrengthLevel.weak:
        return const Color(0xFFF97316); // orange
      case PasswordStrengthLevel.fair:
        return const Color(0xFFEAB308); // yellow
      case PasswordStrengthLevel.good:
        return const Color(0xFF3B82F6); // blue
      case PasswordStrengthLevel.strong:
        return const Color(0xFF10B981); // emerald green
      case PasswordStrengthLevel.excellent:
        return const Color(0xFF06B6D4); // cyan
    }
  }
}

/// Immutable model representing the detailed security assessment of a password.
class PasswordAnalysis {
  const PasswordAnalysis({
    required this.password,
    required this.length,
    required this.score,
    required this.entropy,
    required this.charsetSize,
    required this.crackTime,
    required this.bruteForceAttempts,
    required this.strength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumbers,
    required this.hasSymbols,
    required this.hasGoodLength,
    required this.hasNoDictionaryWords,
    required this.hasNoKeyboardPattern,
    required this.hasNoSequentialCharacters,
    required this.criticalWarnings,
    required this.recommendations,
    required this.goodPractices,
  });

  /// The original password string analyzed.
  final String password;

  /// Character length.
  final int length;

  /// Security score from 0 to 100.
  final int score;

  /// Bits of Shannon entropy.
  final double entropy;

  /// Size of the character set active.
  final int charsetSize;

  /// Human-readable estimated crack time.
  final String crackTime;

  /// Estimated brute-force attempts needed.
  final String bruteForceAttempts;

  /// Overall strength category level.
  final PasswordStrengthLevel strength;

  // ── Security Checklist Toggles ─────────────────────────────────────────────

  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumbers;
  final bool hasSymbols;
  final bool hasGoodLength;
  final bool hasNoDictionaryWords;
  final bool hasNoKeyboardPattern;
  final bool hasNoSequentialCharacters;

  // ── Feedback ───────────────────────────────────────────────────────────────

  /// Critical issues that must be fixed immediately.
  final List<String> criticalWarnings;

  /// High-priority actionable recommendations.
  final List<String> recommendations;

  /// Lower-priority good practices.
  final List<String> goodPractices;

  /// Creates a default empty analysis structure.
  factory PasswordAnalysis.empty() {
    return const PasswordAnalysis(
      password: '',
      length: 0,
      score: 0,
      entropy: 0.0,
      charsetSize: 0,
      crackTime: 'instantly',
      bruteForceAttempts: '0',
      strength: PasswordStrengthLevel.veryWeak,
      hasUppercase: false,
      hasLowercase: false,
      hasNumbers: false,
      hasSymbols: false,
      hasGoodLength: false,
      hasNoDictionaryWords: true,
      hasNoKeyboardPattern: true,
      hasNoSequentialCharacters: true,
      criticalWarnings: [],
      recommendations: [],
      goodPractices: [],
    );
  }
}

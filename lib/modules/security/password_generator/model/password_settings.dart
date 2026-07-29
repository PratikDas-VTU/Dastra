// Immutable model holding all password generation settings.
import 'package:flutter/foundation.dart';

/// Generation modes for the Password Generator
enum GenerationMode {
  random,
  personalized,
  improve,
}

/// All configurable parameters for password generation.
@immutable
class PasswordSettings {
  const PasswordSettings({
    this.mode = GenerationMode.random,
    this.length = 16,
    this.useUppercase = true,
    this.useLowercase = true,
    this.useNumbers = true,
    this.useSymbols = false,
    this.excludeSimilar = false,
    this.excludeCustom = '',
    this.count = 1,
    this.customBase = '',
    this.personalizedName = '',
    this.personalizedWord = '',
    this.personalizedNumber = '',
    this.personalizedCustom1 = '',
    this.personalizedCustom2 = '',
    this.existingPasswordToImprove = '',
  });

  /// The active generation mode.
  final GenerationMode mode;

  /// Password character length (4–128).
  final int length;

  /// Include uppercase letters A–Z.
  final bool useUppercase;

  /// Include lowercase letters a–z.
  final bool useLowercase;

  /// Include numeric characters 0–9.
  final bool useNumbers;

  /// Include symbol characters.
  final bool useSymbols;

  /// Exclude visually similar characters (O, 0, l, I, 1, |).
  final bool excludeSimilar;

  /// User-defined characters to exclude from the pool.
  final String excludeCustom;

  /// How many passwords to generate at once (1–20).
  final int count;

  /// Custom base word (e.g. name of a person) to incorporate.
  final String customBase;

  // ── Personalized Inputs ────────────────────────────────────────────────────

  final String personalizedName;
  final String personalizedWord;
  final String personalizedNumber;
  final String personalizedCustom1;
  final String personalizedCustom2;

  // ── Improve Inputs ─────────────────────────────────────────────────────────

  final String existingPasswordToImprove;

  /// Returns true when at least one character set is active (relevant for Random mode).
  bool get hasValidCharset =>
      useUppercase || useLowercase || useNumbers || useSymbols;

  /// Produces a copy with overridden fields.
  PasswordSettings copyWith({
    GenerationMode? mode,
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useNumbers,
    bool? useSymbols,
    bool? excludeSimilar,
    String? excludeCustom,
    int? count,
    String? customBase,
    String? personalizedName,
    String? personalizedWord,
    String? personalizedNumber,
    String? personalizedCustom1,
    String? personalizedCustom2,
    String? existingPasswordToImprove,
  }) =>
      PasswordSettings(
        mode: mode ?? this.mode,
        length: length ?? this.length,
        useUppercase: useUppercase ?? this.useUppercase,
        useLowercase: useLowercase ?? this.useLowercase,
        useNumbers: useNumbers ?? this.useNumbers,
        useSymbols: useSymbols ?? this.useSymbols,
        excludeSimilar: excludeSimilar ?? this.excludeSimilar,
        excludeCustom: excludeCustom ?? this.excludeCustom,
        count: count ?? this.count,
        customBase: customBase ?? this.customBase,
        personalizedName: personalizedName ?? this.personalizedName,
        personalizedWord: personalizedWord ?? this.personalizedWord,
        personalizedNumber: personalizedNumber ?? this.personalizedNumber,
        personalizedCustom1: personalizedCustom1 ?? this.personalizedCustom1,
        personalizedCustom2: personalizedCustom2 ?? this.personalizedCustom2,
        existingPasswordToImprove: existingPasswordToImprove ?? this.existingPasswordToImprove,
      );
}

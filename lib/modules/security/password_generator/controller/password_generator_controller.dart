// ChangeNotifier-based controller for the Password Generator screen.
// Owns all state; the UI observes via Provider and rebuilds on notifyListeners().
import 'package:flutter/foundation.dart';
import '../model/password_settings.dart';
import '../utils/password_utils.dart';
import '../utils/engines/personalized_password_engine.dart';
import '../utils/engines/password_improve_engine.dart';

class PasswordGeneratorController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  PasswordSettings _settings = const PasswordSettings();
  List<String> _passwords = [];

  /// Incremented every time passwords are (re)generated.
  /// Widgets can key their animation on this value.
  int _generationKey = 0;

  // ── Constructor ────────────────────────────────────────────────────────────

  PasswordGeneratorController() {
    // Generate the initial set of passwords immediately.
    _runGenerate();
  }

  // ── Public Getters ─────────────────────────────────────────────────────────

  PasswordSettings get settings => _settings;
  GenerationMode get mode => _settings.mode;
  List<String> get passwords => _passwords;
  int get generationKey => _generationKey;

  /// The first generated password (used when count == 1).
  String get primaryPassword => _passwords.isEmpty ? '' : _passwords.first;

  /// Current entropy in bits based on the actual primary password string.
  double get entropy => PasswordUtils.calculatePasswordEntropy(primaryPassword);

  /// Strength tier derived from [entropy].
  StrengthLevel get strength => PasswordUtils.strengthLevel(entropy);

  /// Human-readable crack time estimate.
  String get crackTime => PasswordUtils.estimateCrackTime(entropy);

  /// Number of unique characters in the active pool.
  int get charsetLength => PasswordUtils.charsetSize(_settings);

  /// True when all characters have been excluded (invalid state).
  bool get isCharsetEmpty => charsetLength == 0 && _settings.customBase.isEmpty;

  // ── Public Actions ─────────────────────────────────────────────────────────

  /// Switches the generation mode and regenerates.
  void setMode(GenerationMode newMode) {
    if (newMode == _settings.mode) return;
    _settings = _settings.copyWith(mode: newMode);
    _runGenerate();
    notifyListeners();
  }

  /// Manually updates the primary password (e.g. when the user types/alters it).
  void updatePrimaryPassword(String value) {
    if (_passwords.isEmpty) {
      _passwords = [value];
    } else {
      _passwords[0] = value;
    }
    notifyListeners();
  }

  /// Helper to make any specific index the primary password (for suggestions)
  void setPrimaryPassword(int index) {
    if (index < 0 || index >= _passwords.length) return;
    final selected = _passwords[index];
    _passwords.removeAt(index);
    _passwords.insert(0, selected);
    notifyListeners();
  }

  /// Updates the custom base word (e.g. name of a person) and regenerates.
  void setCustomBase(String value) {
    if (value == _settings.customBase) return;
    _settings = _settings.copyWith(customBase: value);
    _runGenerate();
    notifyListeners();
  }

  // ── Personalized Inputs ──
  void setPersonalizedName(String value) {
    if (value == _settings.personalizedName) return;
    _settings = _settings.copyWith(personalizedName: value);
    _runGenerate();
    notifyListeners();
  }

  void setPersonalizedWord(String value) {
    if (value == _settings.personalizedWord) return;
    _settings = _settings.copyWith(personalizedWord: value);
    _runGenerate();
    notifyListeners();
  }

  void setPersonalizedNumber(String value) {
    if (value == _settings.personalizedNumber) return;
    _settings = _settings.copyWith(personalizedNumber: value);
    _runGenerate();
    notifyListeners();
  }

  void setPersonalizedCustom1(String value) {
    if (value == _settings.personalizedCustom1) return;
    _settings = _settings.copyWith(personalizedCustom1: value);
    _runGenerate();
    notifyListeners();
  }

  void setPersonalizedCustom2(String value) {
    if (value == _settings.personalizedCustom2) return;
    _settings = _settings.copyWith(personalizedCustom2: value);
    _runGenerate();
    notifyListeners();
  }

  // ── Improve Inputs ──
  void setExistingPasswordToImprove(String value) {
    if (value == _settings.existingPasswordToImprove) return;
    _settings = _settings.copyWith(existingPasswordToImprove: value);
    _runGenerate();
    notifyListeners();
  }

  /// Regenerates all passwords using current settings.
  void generate() {
    _runGenerate();
    notifyListeners();
  }

  /// Updates password length (clamped to 4–128).
  void setLength(int value) {
    final clamped = value.clamp(4, 128);
    if (clamped == _settings.length) return;
    _settings = _settings.copyWith(length: clamped);
    _runGenerate();
    notifyListeners();
  }

  /// Updates how many passwords to generate (clamped to 1–20).
  void setCount(int value) {
    final clamped = value.clamp(1, 20);
    if (clamped == _settings.count) return;
    _settings = _settings.copyWith(count: clamped);
    _runGenerate();
    notifyListeners();
  }

  /// Toggles uppercase letters.
  /// Prevents disabling when it is the only active charset.
  void toggleUppercase() {
    if (_settings.useUppercase && _isOnlyActive()) return;
    _settings = _settings.copyWith(useUppercase: !_settings.useUppercase);
    _runGenerate();
    notifyListeners();
  }

  /// Toggles lowercase letters.
  void toggleLowercase() {
    if (_settings.useLowercase && _isOnlyActive()) return;
    _settings = _settings.copyWith(useLowercase: !_settings.useLowercase);
    _runGenerate();
    notifyListeners();
  }

  /// Toggles numeric characters.
  void toggleNumbers() {
    if (_settings.useNumbers && _isOnlyActive()) return;
    _settings = _settings.copyWith(useNumbers: !_settings.useNumbers);
    _runGenerate();
    notifyListeners();
  }

  /// Toggles symbol characters.
  void toggleSymbols() {
    if (_settings.useSymbols && _isOnlyActive()) return;
    _settings = _settings.copyWith(useSymbols: !_settings.useSymbols);
    _runGenerate();
    notifyListeners();
  }

  /// Toggles exclusion of visually similar characters (O, 0, l, I, 1, |).
  void toggleExcludeSimilar() {
    _settings = _settings.copyWith(excludeSimilar: !_settings.excludeSimilar);
    _runGenerate();
    notifyListeners();
  }

  /// Updates the set of custom characters to exclude.
  void setExcludeCustom(String value) {
    if (value == _settings.excludeCustom) return;
    _settings = _settings.copyWith(excludeCustom: value);
    _runGenerate();
    notifyListeners();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  /// Runs generation synchronously (fast — pure Dart, no I/O).
  void _runGenerate() {
    switch (_settings.mode) {
      case GenerationMode.random:
        _passwords = PasswordUtils.generatePasswords(_settings);
        break;
      case GenerationMode.personalized:
        // Always generate 5 suggestions for Personalized mode
        _passwords = PersonalizedPasswordEngine.generateSuggestions(_settings, count: 5);
        break;
      case GenerationMode.improve:
        // Always generate 5 suggestions for Improve mode
        _passwords = PasswordImproveEngine.improveExisting(_settings.existingPasswordToImprove, count: 5);
        break;
    }
    _generationKey++;
  }

  /// Returns true when exactly one charset is currently enabled.
  /// Used to prevent the user from disabling the last active charset.
  bool _isOnlyActive() {
    final s = _settings;
    final enabled = [
      s.useUppercase,
      s.useLowercase,
      s.useNumbers,
      s.useSymbols,
    ].where((v) => v).length;
    return enabled == 1;
  }
}

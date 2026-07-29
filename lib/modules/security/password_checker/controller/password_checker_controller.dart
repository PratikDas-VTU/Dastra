import 'package:flutter/foundation.dart';
import '../model/password_analysis.dart';
import '../utils/password_checker_utils.dart';

class PasswordCheckerController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  String _password = '';
  bool _obscureText = true;
  PasswordAnalysis _analysis = PasswordAnalysis.empty();

  // ── Public Getters ─────────────────────────────────────────────────────────

  String get password => _password;
  bool get obscureText => _obscureText;
  PasswordAnalysis get analysis => _analysis;

  /// Returns true when there is some text entered in the password field.
  bool get isNotEmpty => _password.isNotEmpty;

  // ── Public Actions ─────────────────────────────────────────────────────────

  /// Updates the password input string and triggers real-time assessment.
  void setPassword(String value) {
    if (_password == value) return;
    _password = value;
    _analysis = PasswordCheckerUtils.analyze(value);
    notifyListeners();
  }

  /// Clears the password input and resets analysis.
  void clearPassword() {
    if (_password.isEmpty) return;
    _password = '';
    _analysis = PasswordAnalysis.empty();
    notifyListeners();
  }

  /// Toggles visibility state of the password characters.
  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
}

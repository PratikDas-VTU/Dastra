import 'dart:math';

class PasswordImproveEngine {
  PasswordImproveEngine._();

  static const List<String> _separators = ['!', '@', '#', '\$', '%', '^', '&', '*', '-', '_', '+', '='];
  static const Map<String, List<String>> _leetspeak = {
    'a': ['@', '4'],
    'e': ['3'],
    'i': ['1', '!'],
    'o': ['0'],
    's': ['\$', '5'],
    't': ['7'],
  };

  /// Takes an existing weak password and generates multiple stronger variations.
  static List<String> improveExisting(String password, {int count = 5}) {
    if (password.trim().isEmpty) {
      return List.filled(count, '');
    }
    
    final base = password.trim();
    final rng = Random.secure();
    final results = <String>[];

    for (var i = 0; i < count; i++) {
      var improved = base;

      // 1. Apply Leetspeak to some characters (but not all, so it stays recognizable)
      final chars = improved.split('');
      for (var j = 0; j < chars.length; j++) {
        final c = chars[j].toLowerCase();
        if (_leetspeak.containsKey(c) && rng.nextDouble() < 0.4) {
          final options = _leetspeak[c]!;
          chars[j] = options[rng.nextInt(options.length)];
        }
      }
      improved = chars.join('');

      // 2. Randomly modify capitalization of a few letters
      final caseChars = improved.split('');
      for (var j = 0; j < caseChars.length; j++) {
        // Only flip alphabetic chars
        if (RegExp(r'[a-zA-Z]').hasMatch(caseChars[j]) && rng.nextDouble() < 0.3) {
          final c = caseChars[j];
          caseChars[j] = c == c.toLowerCase() ? c.toUpperCase() : c.toLowerCase();
        }
      }
      improved = caseChars.join('');

      // 3. Inject entropy or separators (prefix, suffix, or middle)
      final strategy = rng.nextInt(3);
      final separator = _separators[rng.nextInt(_separators.length)];
      final entropy = _generateEntropyBlock(rng, length: rng.nextInt(3) + 2); // 2-4 chars
      
      if (strategy == 0) {
        // Append
        improved = '$improved$separator$entropy';
      } else if (strategy == 1) {
        // Prepend
        improved = '$entropy$separator$improved';
      } else {
        // Both or wrap
        improved = '$separator$improved$separator$entropy';
      }

      results.add(improved);
    }

    return results;
  }

  static String _generateEntropyBlock(Random rng, {int length = 2}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join('');
  }
}

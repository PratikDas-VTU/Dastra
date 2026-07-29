import 'dart:math';
import '../../model/password_settings.dart';

class PersonalizedPasswordEngine {
  PersonalizedPasswordEngine._();

  static const List<String> _separators = ['!', '@', '#', '\$', '%', '^', '&', '*', '-', '_', '+', '='];
  static const Map<String, List<String>> _leetspeak = {
    'a': ['@', '4'],
    'e': ['3'],
    'i': ['1', '!'],
    'o': ['0'],
    's': ['\$', '5'],
    't': ['7'],
  };

  /// Generates multiple personalized password suggestions based on inputs.
  static List<String> generateSuggestions(PasswordSettings settings, {int count = 5}) {
    final inputs = <String>[];
    if (settings.personalizedName.trim().isNotEmpty) inputs.add(settings.personalizedName.trim());
    if (settings.personalizedWord.trim().isNotEmpty) inputs.add(settings.personalizedWord.trim());
    if (settings.personalizedNumber.trim().isNotEmpty) inputs.add(settings.personalizedNumber.trim());
    if (settings.personalizedCustom1.trim().isNotEmpty) inputs.add(settings.personalizedCustom1.trim());
    if (settings.personalizedCustom2.trim().isNotEmpty) inputs.add(settings.personalizedCustom2.trim());

    if (inputs.isEmpty) {
      // Return empty strings so the UI can show a placeholder or prompt the user
      return List.filled(count, '');
    }

    final rng = Random.secure();
    final results = <String>[];

    for (var i = 0; i < count; i++) {
      // Shuffle the order of inputs to prevent predictable structures
      final shuffledInputs = List<String>.from(inputs)..shuffle(rng);
      
      final buffer = StringBuffer();
      
      for (var j = 0; j < shuffledInputs.length; j++) {
        // Apply random transformations to each chunk
        final chunk = _transformChunk(shuffledInputs[j], rng);
        buffer.write(chunk);
        
        // Add a separator or some entropy between chunks
        if (j < shuffledInputs.length - 1) {
          if (rng.nextBool()) {
            buffer.write(_separators[rng.nextInt(_separators.length)]);
          } else {
            // Inject short random entropy
            buffer.write(_generateEntropyBlock(rng, length: rng.nextInt(2) + 1));
          }
        }
      }
      
      // Optionally cap the password with an extra symbol or number for strength
      if (rng.nextBool()) {
        buffer.write(_separators[rng.nextInt(_separators.length)]);
      }
      if (rng.nextBool()) {
        buffer.write(rng.nextInt(100).toString());
      }
      
      results.add(buffer.toString());
    }

    return results;
  }

  static String _transformChunk(String chunk, Random rng) {
    if (chunk.isEmpty) return chunk;

    // 1. Randomize capitalization (maybe capitalize first letter, or all lowercase, or all uppercase, or random)
    final capStyle = rng.nextInt(4);
    var transformed = chunk;
    if (capStyle == 0) {
      transformed = transformed.toLowerCase();
    } else if (capStyle == 1) {
      transformed = transformed.toUpperCase();
    } else if (capStyle == 2) {
      // Title case
      transformed = transformed[0].toUpperCase() + (transformed.length > 1 ? transformed.substring(1).toLowerCase() : '');
    }
    // capStyle == 3 keeps original case

    // 2. Leetspeak substitution (don't overdo it, maybe 30% chance per character)
    final chars = transformed.split('');
    for (var i = 0; i < chars.length; i++) {
      final c = chars[i].toLowerCase();
      if (_leetspeak.containsKey(c) && rng.nextDouble() < 0.3) {
        final options = _leetspeak[c]!;
        chars[i] = options[rng.nextInt(options.length)];
      }
    }
    return chars.join('');
  }

  static String _generateEntropyBlock(Random rng, {int length = 2}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join('');
  }
}

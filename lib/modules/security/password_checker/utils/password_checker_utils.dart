import 'dart:math';
import '../model/password_analysis.dart';

class PasswordCheckerUtils {
  PasswordCheckerUtils._();

  // ── Common Password List (~120 items) ──────────────────────────────────────
  static const Set<String> _commonPasswords = {
    '123456', 'password', '123456789', '12345678', '12345', 'qwerty',
    'password123', '1234567', 'letmein', 'football', 'welcome', 'admin',
    '123123', 'computer', 'monkey', 'system', 'security', 'secret',
    'login', 'oracle', 'jordan', 'shadow', 'daniel', 'hunter', 'mustang',
    'superman', 'princess', 'lovelove', 'iloveyou', 'sweetheart', 'beautiful',
    'chocolate', 'sunshine', 'cookie', 'angel', 'babygirl', 'forever',
    'adidas', 'nike', 'puma', 'champion', 'macbook', 'windows', 'android',
    'iphone', 'google', 'microsoft', 'youtube', 'facebook', 'instagram',
    'twitter', 'netflix', 'spotify', 'disney', 'marvel', 'batman',
    'spiderman', 'starwars', 'pokemon', 'naruto', 'onepiece', 'dragonball',
    'matrix', 'avatar', 'gladiator', 'inception', 'titanic', 'godfather',
    'pulpfiction', 'fightclub', 'forrestgump', 'starbucks', 'mcdonalds',
    'dominos', 'pizza', 'burger', 'coffee', 'tea', 'beer', 'wine',
    'whiskey', 'vodka', 'tequila', 'mojito', 'margarita', 'cocktail',
    'champagne', 'cognac', 'brandy', 'rum', 'gin', 'bourbon', 'scotch',
    'cider', 'soda', 'water', 'juice', 'milk', 'hello', 'goodmorning',
    'goodnight', 'thankyou', 'please', 'family', 'friends', 'summer',
    'winter', 'spring', 'autumn', 'october', 'december', 'january', 'america'
  };

  // ── Keyboard rows for pattern matching ─────────────────────────────────────
  static const List<String> _keyboardRows = [
    'qwertyuiop',
    'asdfghjkl',
    'zxcvbnm',
    '1234567890'
  ];

  // ── Main Analysis function ─────────────────────────────────────────────────
  static PasswordAnalysis analyze(String password) {
    if (password.isEmpty) {
      return PasswordAnalysis.empty();
    }

    final len = password.length;

    // Charset checks
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*()\-=_+\[\]{}|;:,.<>?/`~]'));

    // Good length threshold: >= 12 characters
    final hasGoodLen = len >= 12;

    // Checks
    final isCommon = _checkIsCommon(password);
    final hasKeyboard = _checkKeyboardPattern(password);
    final hasSequential = _checkSequential(password);
    final hasRepeated = _checkRepeated(password);
    final hasPersonal = _checkPersonalInfo(password);

    // Calculate pool size
    int poolSize = 0;
    if (hasUpper) poolSize += 26;
    if (hasLower) poolSize += 26;
    if (hasDigit) poolSize += 10;
    if (hasSpecial) poolSize += 30; // standard symbols
    if (poolSize == 0) poolSize = 1; // avoid log(0) issues

    // Shannon Entropy: H = L * log2(PoolSize)
    final double entropy = len * (log(poolSize) / log(2));

    // Crack time & brute force attempts
    final crackTime = _estimateCrackTime(entropy);
    final bruteForceAttempts = _estimateBruteForceAttempts(entropy);

    // Calculate score
    final score = _calculateScore(
      password: password,
      hasUpper: hasUpper,
      hasLower: hasLower,
      hasDigit: hasDigit,
      hasSpecial: hasSpecial,
      isCommon: isCommon,
      hasKeyboard: hasKeyboard,
      hasSequential: hasSequential,
      hasRepeated: hasRepeated,
      hasPersonal: hasPersonal,
    );

    // Strength Level
    final strength = _mapScoreToStrength(score);

    // Build categorized feedback
    final criticalWarnings = <String>[];
    final recommendations = <String>[];
    final goodPractices = <String>[];

    if (isCommon) {
      criticalWarnings.add('This is a highly common password and is extremely easy to guess.');
    }
    if (len < 8) {
      criticalWarnings.add('Password is too short. Short passwords can be brute-forced instantly.');
      recommendations.add('Make the password at least 12 characters long.');
    } else if (len < 12) {
      recommendations.add('Increase password length to 12 or more characters for better security.');
    } else {
      goodPractices.add('Good length. Length is the most important factor in password strength.');
    }

    if (!hasUpper) {
      recommendations.add('Add at least one uppercase letter (A–Z).');
    }
    if (!hasLower) {
      recommendations.add('Add at least one lowercase letter (a–z).');
    }
    if (!hasDigit) {
      recommendations.add('Add at least one numeric digit (0–9).');
    }
    if (!hasSpecial) {
      recommendations.add('Add at least one symbol character (e.g., !, @, #, \$).');
    }

    if (hasRepeated) {
      recommendations.add('Avoid repeating the same character sequences (e.g., "aaa" or "111").');
    }
    if (hasSequential) {
      recommendations.add('Use random variations instead of alphabetical/numeric sequences.');
    }
    if (hasKeyboard) {
      recommendations.add('Avoid using straight paths or patterns on your keyboard layout.');
    }
    if (hasPersonal) {
      criticalWarnings.add('Contains patterns resembling dates, emails, or phone numbers.');
    }
    
    // Default good practices
    goodPractices.add('Avoid password reuse across different accounts.');
    goodPractices.add('Use unique, strong passwords for important accounts (e.g., banking, email).');

    return PasswordAnalysis(
      password: password,
      length: len,
      score: score,
      entropy: entropy,
      charsetSize: poolSize,
      crackTime: crackTime,
      bruteForceAttempts: bruteForceAttempts,
      strength: strength,
      hasUppercase: hasUpper,
      hasLowercase: hasLower,
      hasNumbers: hasDigit,
      hasSymbols: hasSpecial,
      hasGoodLength: hasGoodLen,
      hasNoDictionaryWords: !isCommon,
      hasNoKeyboardPattern: !hasKeyboard,
      hasNoSequentialCharacters: !hasSequential,
      criticalWarnings: criticalWarnings,
      recommendations: recommendations,
      goodPractices: goodPractices,
    );
  }

  // ── Helper Checkers ────────────────────────────────────────────────────────

  static bool _checkIsCommon(String password) {
    final lower = password.toLowerCase();
    return _commonPasswords.contains(lower);
  }

  static bool _checkKeyboardPattern(String password) {
    final lower = password.toLowerCase();
    if (lower.length < 3) return false;

    for (final row in _keyboardRows) {
      for (int i = 0; i <= row.length - 3; i++) {
        final forward = row.substring(i, i + 3);
        final backward = forward.split('').reversed.join('');
        if (lower.contains(forward) || lower.contains(backward)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _checkSequential(String password) {
    if (password.length < 3) return false;

    // Check sequential ASCII values
    for (int i = 0; i <= password.length - 3; i++) {
      final code1 = password.codeUnitAt(i);
      final code2 = password.codeUnitAt(i + 1);
      final code3 = password.codeUnitAt(i + 2);

      // Ascending (e.g., abc, 123)
      if (code2 == code1 + 1 && code3 == code2 + 1) {
        return true;
      }
      // Descending (e.g., cba, 321)
      if (code2 == code1 - 1 && code3 == code2 - 1) {
        return true;
      }
    }
    return false;
  }

  static bool _checkRepeated(String password) {
    if (password.length < 2) return false;

    // Check for consecutive identical chars (e.g., aa, 11)
    for (int i = 0; i < password.length - 1; i++) {
      if (password[i] == password[i + 1]) {
        // Find if we have 3 identical in a row (e.g., aaa)
        if (i < password.length - 2 && password[i] == password[i + 2]) {
          return true;
        }
      }
    }

    // Check for repeating patterns of length 2 or 3 (e.g. ababab, abcabc)
    if (password.length >= 6) {
      for (int patternLen = 2; patternLen <= 3; patternLen++) {
        final chunk1 = password.substring(0, patternLen);
        final chunk2 = password.substring(patternLen, patternLen * 2);
        final chunk3 = password.substring(patternLen * 2, patternLen * 3);
        if (chunk1 == chunk2 && chunk2 == chunk3) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _checkPersonalInfo(String password) {
    // 1. Date heuristics (e.g., YYYY, DDMMYYYY, YYYYMMDD, DD-MM-YYYY)
    final dateReg = RegExp(
      r'^(?:\d{4}|\d{2}[-/. ]?\d{2}[-/. ]?\d{4}|\d{4}[-/. ]?\d{2}[-/. ]?\d{2})$',
    );
    if (dateReg.hasMatch(password)) return true;

    // 2. Email format fragments
    final emailReg = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}');
    if (emailReg.hasMatch(password)) return true;

    // 3. Phone number formats (digits only sequence of length 7-15)
    final phoneReg = RegExp(r'^\+?[0-9]{7,15}$');
    if (phoneReg.hasMatch(password)) return true;

    return false;
  }

  // ── Scoring Logic ──────────────────────────────────────────────────────────

  static int _calculateScore({
    required String password,
    required bool hasUpper,
    required bool hasLower,
    required bool hasDigit,
    required bool hasSpecial,
    required bool isCommon,
    required bool hasKeyboard,
    required bool hasSequential,
    required bool hasRepeated,
    required bool hasPersonal,
  }) {
    if (isCommon) return 5;

    int score = 0;
    final len = password.length;

    // 1. Length contribution (Max 35 points)
    if (len >= 16) {
      score += 35;
    } else if (len >= 12) {
      score += 28;
    } else if (len >= 8) {
      score += 18;
    } else if (len >= 6) {
      score += 8;
    } else {
      score += 3;
    }

    // 2. Character diversity contribution (Max 40 points)
    if (hasUpper) score += 10;
    if (hasLower) score += 10;
    if (hasDigit) score += 10;
    if (hasSpecial) score += 10;

    // 3. Variety bonus (Max 15 points)
    int categoriesCount = 0;
    if (hasUpper) categoriesCount++;
    if (hasLower) categoriesCount++;
    if (hasDigit) categoriesCount++;
    if (hasSpecial) categoriesCount++;

    if (categoriesCount == 4) {
      score += 15;
    } else if (categoriesCount == 3) {
      score += 8;
    }

    // 4. Length bonus (Max 10 points)
    if (len >= 20) {
      score += 10;
    } else if (len >= 14) {
      score += 5;
    }

    // 5. Deductions (Max 50 points deduction)
    int deductions = 0;
    if (hasKeyboard) deductions += 15;
    if (hasSequential) deductions += 15;
    if (hasRepeated) deductions += 10;
    if (hasPersonal) deductions += 15;

    // Extra deduction for extremely short passwords
    if (len < 8) {
      deductions += 15;
    }

    score -= deductions;
    return score.clamp(0, 100);
  }

  static PasswordStrengthLevel _mapScoreToStrength(int score) {
    if (score < 20) return PasswordStrengthLevel.veryWeak;
    if (score < 40) return PasswordStrengthLevel.weak;
    if (score < 60) return PasswordStrengthLevel.fair;
    if (score < 80) return PasswordStrengthLevel.good;
    if (score < 90) return PasswordStrengthLevel.strong;
    return PasswordStrengthLevel.excellent;
  }

  // ── Metrics Helpers ────────────────────────────────────────────────────────

  static String _estimateCrackTime(double entropy) {
    if (entropy <= 0) return 'Instantly';
    if (entropy >= 256) return 'Longer than the age of the universe';

    const guessesPerSecond = 1e12; // 1 Trillion guesses/sec
    final seconds = pow(2.0, entropy) / guessesPerSecond;

    String timeStr;
    if (seconds < 1) {
      timeStr = 'Less than a second';
    } else if (seconds < 60) {
      timeStr = '${seconds.toStringAsFixed(0)} second${seconds < 2 ? '' : 's'}';
    } else {
      final minutes = seconds / 60;
      if (minutes < 60) {
        timeStr = '${minutes.toStringAsFixed(0)} minute${minutes < 2 ? '' : 's'}';
      } else {
        final hours = minutes / 60;
        if (hours < 24) {
          timeStr = '${hours.toStringAsFixed(0)} hour${hours < 2 ? '' : 's'}';
        } else {
          final days = hours / 24;
          if (days < 30.44) {
            timeStr = '${days.toStringAsFixed(0)} day${days < 2 ? '' : 's'}';
          } else {
            final months = days / 30.44;
            if (months < 12) {
              timeStr = '${months.toStringAsFixed(0)} month${months < 2 ? '' : 's'}';
            } else {
              final years = days / 365.25;
              if (years < 1000) {
                timeStr = '${years.toStringAsFixed(0)} years';
              } else if (years < 1e6) {
                timeStr = '${(years / 1e3).toStringAsFixed(0)}K years';
              } else if (years < 1e9) {
                timeStr = '${(years / 1e6).toStringAsFixed(1)}M years';
              } else if (years < 1e12) {
                timeStr = '${(years / 1e9).toStringAsFixed(1)}B years';
              } else {
                timeStr = 'Longer than the age of the universe';
              }
            }
          }
        }
      }
    }
    
    if (timeStr == 'Instantly' || timeStr == 'Longer than the age of the universe' || timeStr == 'Less than a second') {
      return timeStr;
    }
    
    return 'Approximately $timeStr using modern hardware';
  }

  static String _estimateBruteForceAttempts(double entropy) {
    if (entropy <= 0) return '0';
    if (entropy >= 120) return '> 1.0 × 10³⁶';

    final attempts = pow(2.0, entropy);

    // Format scientific notation for larger sizes
    if (attempts >= 1e12) {
      final exp = (log(attempts) / log(10)).floor();
      final coeff = attempts / pow(10.0, exp);
      return '${coeff.toStringAsFixed(1)} × 10^$exp';
    }
    return attempts.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

import 'dart:math';

/// Utility class for generating unique IDs
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  /// Generate UUID v4
  static String uuid() {
    const hexDigits = '0123456789abcdef';
    final uuid = List<String>.generate(36, (index) {
      if (index == 8 || index == 13 || index == 18 || index == 23) {
        return '-';
      }
      if (index == 14) {
        return '4'; // Version 4
      }
      if (index == 19) {
        return hexDigits[(_random.nextInt(4) + 8)]; // Variant
      }
      return hexDigits[_random.nextInt(16)];
    });
    return uuid.join();
  }

  /// Generate layer ID with type prefix
  static String layerId(String type) {
    return 'l_${type}_${_shortId()}';
  }

  /// Generate asset ID with type prefix
  static String assetId(String type) {
    return 'a_${type}_${_shortId()}';
  }

  /// Generate short random ID (8 chars)
  static String _shortId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Generate timestamp-based ID
  static String timestampId([String prefix = '']) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(9999).toString().padLeft(4, '0');
    return prefix.isEmpty ? '$timestamp$random' : '${prefix}_$timestamp$random';
  }
}
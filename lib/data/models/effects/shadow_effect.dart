import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Shadow effect for layers
class ShadowEffect {
  final bool enabled;
  final Color color;
  final double offsetX;
  final double offsetY;
  final double blur;
  final double spread;

  const ShadowEffect({
    this.enabled = true,
    this.color = const Color(0x40000000),
    this.offsetX = 0,
    this.offsetY = 4,
    this.blur = 8,
    this.spread = 0,
  });

  /// No shadow
  static const ShadowEffect none = ShadowEffect(enabled: false);

  /// Default subtle shadow
  static const ShadowEffect subtle = ShadowEffect(
    color: Color(0x20000000),
    offsetY: 2,
    blur: 4,
  );

  /// Medium shadow
  static const ShadowEffect medium = ShadowEffect(
    color: Color(0x40000000),
    offsetY: 4,
    blur: 8,
  );

  /// Heavy shadow
  static const ShadowEffect heavy = ShadowEffect(
    color: Color(0x60000000),
    offsetY: 8,
    blur: 16,
    spread: 2,
  );

  /// Create from JSON
  factory ShadowEffect.fromJson(JsonMap? json) {
    if (json == null) return ShadowEffect.none;

    return ShadowEffect(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', true)!,
      color: JsonUtils.parseColor(json['color'], const Color(0x40000000))!,
      offsetX: JsonUtils.getValue<double>(json, 'offset_x', 0)!,
      offsetY: JsonUtils.getValue<double>(json, 'offset_y', 4)!,
      blur: JsonUtils.getValue<double>(json, 'blur', 8)!,
      spread: JsonUtils.getValue<double>(json, 'spread', 0)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'color': JsonUtils.colorToJson(color),
    'offset_x': offsetX,
    'offset_y': offsetY,
    'blur': blur,
    'spread': spread,
  };

  /// Convert to Flutter BoxShadow
  BoxShadow? toBoxShadow() {
    if (!enabled) return null;

    return BoxShadow(
      color: color,
      offset: Offset(offsetX, offsetY),
      blurRadius: blur,
      spreadRadius: spread,
    );
  }

  /// Convert to Flutter Shadow (for text)
  Shadow? toShadow() {
    if (!enabled) return null;

    return Shadow(
      color: color,
      offset: Offset(offsetX, offsetY),
      blurRadius: blur,
    );
  }

  /// Create copy with modifications
  ShadowEffect copyWith({
    bool? enabled,
    Color? color,
    double? offsetX,
    double? offsetY,
    double? blur,
    double? spread,
  }) {
    return ShadowEffect(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      blur: blur ?? this.blur,
      spread: spread ?? this.spread,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShadowEffect &&
        other.enabled == enabled &&
        other.color == color &&
        other.offsetX == offsetX &&
        other.offsetY == offsetY &&
        other.blur == blur &&
        other.spread == spread;
  }

  @override
  int get hashCode => Object.hash(enabled, color, offsetX, offsetY, blur, spread);
}
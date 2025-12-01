import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Border style types
enum BorderStyleType {
  solid,
  dashed,
  dotted,
}

/// Border position types
enum BorderPosition {
  inside,
  center,
  outside,
}

/// Border effect for layers
class BorderEffect {
  final bool enabled;
  final Color color;
  final double width;
  final BorderStyleType style;
  final BorderPosition position;
  final List<double>? dashArray; // For dashed/dotted styles

  const BorderEffect({
    this.enabled = true,
    this.color = Colors.black,
    this.width = 1.0,
    this.style = BorderStyleType.solid,
    this.position = BorderPosition.inside,
    this.dashArray,
  });

  /// No border
  static const BorderEffect none = BorderEffect(enabled: false);

  /// Thin black border
  static const BorderEffect thin = BorderEffect(width: 1.0);

  /// Medium black border
  static const BorderEffect medium = BorderEffect(width: 2.0);

  /// Thick black border
  static const BorderEffect thick = BorderEffect(width: 4.0);

  /// Create from JSON
  factory BorderEffect.fromJson(JsonMap? json) {
    if (json == null) return BorderEffect.none;

    return BorderEffect(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', true)!,
      color: JsonUtils.parseColor(json['color'], Colors.black)!,
      width: JsonUtils.getValue<double>(json, 'width', 1.0)!,
      style: JsonUtils.parseEnum(json['style'] as String?, BorderStyleType.values) ??
          BorderStyleType.solid,
      position: JsonUtils.parseEnum(json['position'] as String?, BorderPosition.values) ??
          BorderPosition.inside,
      dashArray: (json['dash_array'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'color': JsonUtils.colorToJson(color),
    'width': width,
    'style': style.name,
    'position': position.name,
    if (dashArray != null) 'dash_array': dashArray,
  };

  /// Convert to Flutter Border
  Border? toBorder() {
    if (!enabled) return null;

    return Border.all(
      color: color,
      width: width,
      style: style == BorderStyleType.solid
          ? BorderStyle.solid
          : BorderStyle.none, // Flutter doesn't support dashed natively
    );
  }

  /// Convert to Flutter BorderSide
  BorderSide toBorderSide() {
    return BorderSide(
      color: enabled ? color : Colors.transparent,
      width: enabled ? width : 0,
    );
  }

  /// Create copy with modifications
  BorderEffect copyWith({
    bool? enabled,
    Color? color,
    double? width,
    BorderStyleType? style,
    BorderPosition? position,
    List<double>? dashArray,
  }) {
    return BorderEffect(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
      position: position ?? this.position,
      dashArray: dashArray ?? this.dashArray,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BorderEffect &&
        other.enabled == enabled &&
        other.color == color &&
        other.width == width &&
        other.style == style &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(enabled, color, width, style, position);
}
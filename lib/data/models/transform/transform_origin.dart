import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Represents the origin point for transformations (0.0 to 1.0)
class TransformOrigin {
  final double x;
  final double y;

  const TransformOrigin({
    this.x = 0.5,
    this.y = 0.5,
  });

  /// Center origin (default)
  static const TransformOrigin center = TransformOrigin(x: 0.5, y: 0.5);

  /// Top-left origin
  static const TransformOrigin topLeft = TransformOrigin(x: 0.0, y: 0.0);

  /// Top-center origin
  static const TransformOrigin topCenter = TransformOrigin(x: 0.5, y: 0.0);

  /// Top-right origin
  static const TransformOrigin topRight = TransformOrigin(x: 1.0, y: 0.0);

  /// Center-left origin
  static const TransformOrigin centerLeft = TransformOrigin(x: 0.0, y: 0.5);

  /// Center-right origin
  static const TransformOrigin centerRight = TransformOrigin(x: 1.0, y: 0.5);

  /// Bottom-left origin
  static const TransformOrigin bottomLeft = TransformOrigin(x: 0.0, y: 1.0);

  /// Bottom-center origin
  static const TransformOrigin bottomCenter = TransformOrigin(x: 0.5, y: 1.0);

  /// Bottom-right origin
  static const TransformOrigin bottomRight = TransformOrigin(x: 1.0, y: 1.0);

  /// Create from JSON
  factory TransformOrigin.fromJson(JsonMap? json) {
    if (json == null) return TransformOrigin.center;

    return TransformOrigin(
      x: JsonUtils.getValue<double>(json, 'x', 0.5)!,
      y: JsonUtils.getValue<double>(json, 'y', 0.5)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'x': x,
    'y': y,
  };

  /// Create copy with modifications
  TransformOrigin copyWith({
    double? x,
    double? y,
  }) {
    return TransformOrigin(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformOrigin && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'TransformOrigin(x: $x, y: $y)';
}
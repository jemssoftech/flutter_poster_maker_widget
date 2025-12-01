/// Available shape types
enum ShapeType {
  rectangle,
  circle,
  ellipse,
  triangle,
  polygon,
  star,
  line,
  arrow,
}

/// Extension methods for ShapeType
extension ShapeTypeExtension on ShapeType {
  /// Get display name
  String get displayName {
    switch (this) {
      case ShapeType.rectangle:
        return 'Rectangle';
      case ShapeType.circle:
        return 'Circle';
      case ShapeType.ellipse:
        return 'Ellipse';
      case ShapeType.triangle:
        return 'Triangle';
      case ShapeType.polygon:
        return 'Polygon';
      case ShapeType.star:
        return 'Star';
      case ShapeType.line:
        return 'Line';
      case ShapeType.arrow:
        return 'Arrow';
    }
  }

  /// Check if shape supports fill
  bool get supportsFill {
    switch (this) {
      case ShapeType.line:
        return false;
      default:
        return true;
    }
  }

  /// Check if shape supports corner radius
  bool get supportsCornerRadius {
    switch (this) {
      case ShapeType.rectangle:
        return true;
      default:
        return false;
    }
  }

  /// Check if shape has configurable sides
  bool get hasConfigurableSides {
    switch (this) {
      case ShapeType.polygon:
      case ShapeType.star:
        return true;
      default:
        return false;
    }
  }

  /// Get default number of sides/points
  int get defaultSides {
    switch (this) {
      case ShapeType.triangle:
        return 3;
      case ShapeType.polygon:
        return 6;
      case ShapeType.star:
        return 5;
      default:
        return 0;
    }
  }

  /// Parse from string
  static ShapeType? fromString(String? value) {
    if (value == null) return null;

    for (final type in ShapeType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}
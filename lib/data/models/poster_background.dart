import 'package:flutter/material.dart';
import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';
import '../../core/constants/editor_constants.dart';
import 'gradient_stop.dart';

/// Background type enum
enum BackgroundType {
  solid,
  linearGradient,
  radialGradient,
  image,
  pattern,
}

/// Pattern type for pattern backgrounds
enum PatternType {
  dots,
  lines,
  grid,
  checkerboard,
  diagonal,
}

/// Poster background configuration
class PosterBackground {
  /// Background type
  final BackgroundType type;

  /// Solid color (for solid type)
  final Color? color;

  /// Opacity
  final double opacity;

  /// Gradient angle in degrees (for linear gradient)
  final double? angle;

  /// Gradient stops
  final List<GradientStop>? stops;

  /// Center point for radial gradient (0-1)
  final Offset? center;

  /// Radius for radial gradient (0-1)
  final double? radius;

  /// Asset ID for image background
  final String? assetId;

  /// Image fit mode
  final String? fit;

  /// Image position (0-1)
  final Offset? position;

  /// Image filters
  final BackgroundImageFilters? imageFilters;

  /// Pattern type
  final PatternType? patternType;

  /// Primary pattern color
  final Color? primaryColor;

  /// Secondary pattern color
  final Color? secondaryColor;

  /// Pattern scale
  final double? patternScale;

  /// Pattern rotation
  final double? patternRotation;

  const PosterBackground({
    this.type = BackgroundType.solid,
    this.color,
    this.opacity = 1.0,
    this.angle,
    this.stops,
    this.center,
    this.radius,
    this.assetId,
    this.fit,
    this.position,
    this.imageFilters,
    this.patternType,
    this.primaryColor,
    this.secondaryColor,
    this.patternScale,
    this.patternRotation,
  });

  /// Solid white background
  const PosterBackground.solid({
    Color color = Colors.white,
    double opacity = 1.0,
  }) : this(
    type: BackgroundType.solid,
    color: color,
    opacity: opacity,
  );

  /// Transparent background
  static const PosterBackground transparent = PosterBackground(
    type: BackgroundType.solid,
    color: Colors.transparent,
    opacity: 0,
  );

  /// Create linear gradient background
  factory PosterBackground.linearGradient({
    required List<GradientStop> stops,
    double angle = 180,
    double opacity = 1.0,
  }) {
    return PosterBackground(
      type: BackgroundType.linearGradient,
      stops: stops,
      angle: angle,
      opacity: opacity,
    );
  }

  /// Create radial gradient background
  factory PosterBackground.radialGradient({
    required List<GradientStop> stops,
    Offset center = const Offset(0.5, 0.5),
    double radius = 0.5,
    double opacity = 1.0,
  }) {
    return PosterBackground(
      type: BackgroundType.radialGradient,
      stops: stops,
      center: center,
      radius: radius,
      opacity: opacity,
    );
  }

  /// Create image background
  factory PosterBackground.image({
    required String assetId,
    String fit = 'cover',
    Offset position = const Offset(0.5, 0.5),
    double opacity = 1.0,
  }) {
    return PosterBackground(
      type: BackgroundType.image,
      assetId: assetId,
      fit: fit,
      position: position,
      opacity: opacity,
    );
  }

  /// Create pattern background
  factory PosterBackground.pattern({
    required PatternType patternType,
    Color primaryColor = Colors.black,
    Color secondaryColor = Colors.white,
    double scale = 1.0,
    double rotation = 0,
    double opacity = 1.0,
  }) {
    return PosterBackground(
      type: BackgroundType.pattern,
      patternType: patternType,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      patternScale: scale,
      patternRotation: rotation,
      opacity: opacity,
    );
  }

  /// Create from JSON
  factory PosterBackground.fromJson(JsonMap? json) {
    if (json == null) return const PosterBackground.solid();

    final typeStr = json['type'] as String?;
    final type = _parseBackgroundType(typeStr);

    return PosterBackground(
      type: type,
      color: JsonUtils.parseColor(json['color']),
      opacity: JsonUtils.getValue<double>(json, 'opacity', 1.0)!,
      angle: JsonUtils.getValue<double>(json, 'angle'),
      stops: (json['stops'] as List<dynamic>?)
          ?.map((e) => GradientStop.fromJson(e as JsonMap))
          .toList(),
      center: JsonUtils.parseOffset(json['center'] as JsonMap?),
      radius: JsonUtils.getValue<double>(json, 'radius'),
      assetId: JsonUtils.getValue<String>(json, 'asset_id'),
      fit: JsonUtils.getValue<String>(json, 'fit'),
      position: JsonUtils.parseOffset(json['position'] as JsonMap?),
      imageFilters: json['filters'] != null
          ? BackgroundImageFilters.fromJson(json['filters'] as JsonMap)
          : null,
      patternType: JsonUtils.parseEnum(
        json['pattern_type'] as String?,
        PatternType.values,
      ),
      primaryColor: JsonUtils.parseColor(json['primary_color']),
      secondaryColor: JsonUtils.parseColor(json['secondary_color']),
      patternScale: JsonUtils.getValue<double>(json, 'scale'),
      patternRotation: JsonUtils.getValue<double>(json, 'rotation'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    final json = <String, dynamic>{
      'type': _backgroundTypeToString(type),
      'opacity': opacity,
    };

    switch (type) {
      case BackgroundType.solid:
        if (color != null) json['color'] = JsonUtils.colorToJson(color);
        break;

      case BackgroundType.linearGradient:
        json['angle'] = angle ?? 180;
        json['stops'] = stops?.map((s) => s.toJson()).toList() ?? [];
        break;

      case BackgroundType.radialGradient:
        json['center'] = JsonUtils.offsetToJson(center ?? const Offset(0.5, 0.5));
        json['radius'] = radius ?? 0.5;
        json['stops'] = stops?.map((s) => s.toJson()).toList() ?? [];
        break;

      case BackgroundType.image:
        if (assetId != null) json['asset_id'] = assetId;
        json['fit'] = fit ?? 'cover';
        json['position'] = JsonUtils.offsetToJson(position ?? const Offset(0.5, 0.5));
        if (imageFilters != null) json['filters'] = imageFilters!.toJson();
        break;

      case BackgroundType.pattern:
        json['pattern_type'] = patternType?.name ?? 'dots';
        if (primaryColor != null) json['primary_color'] = JsonUtils.colorToJson(primaryColor);
        if (secondaryColor != null) json['secondary_color'] = JsonUtils.colorToJson(secondaryColor);
        json['scale'] = patternScale ?? 1.0;
        json['rotation'] = patternRotation ?? 0;
        break;
    }

    return json;
  }

  /// Parse background type from string
  static BackgroundType _parseBackgroundType(String? value) {
    if (value == null) return BackgroundType.solid;

    switch (value) {
      case 'solid':
        return BackgroundType.solid;
      case 'linear_gradient':
        return BackgroundType.linearGradient;
      case 'radial_gradient':
        return BackgroundType.radialGradient;
      case 'image':
        return BackgroundType.image;
      case 'pattern':
        return BackgroundType.pattern;
      default:
        return BackgroundType.solid;
    }
  }

  /// Convert background type to string
  static String _backgroundTypeToString(BackgroundType type) {
    switch (type) {
      case BackgroundType.solid:
        return 'solid';
      case BackgroundType.linearGradient:
        return 'linear_gradient';
      case BackgroundType.radialGradient:
        return 'radial_gradient';
      case BackgroundType.image:
        return 'image';
      case BackgroundType.pattern:
        return 'pattern';
    }
  }

  /// Build decoration for rendering
  BoxDecoration? toBoxDecoration() {
    switch (type) {
      case BackgroundType.solid:
        return BoxDecoration(
          color: (color ?? Colors.white).withOpacity(opacity),
        );

      case BackgroundType.linearGradient:
        if (stops == null || stops!.isEmpty) return null;
        return BoxDecoration(
          gradient: LinearGradient(
            colors: stops!.map((s) => s.color.withOpacity(opacity)).toList(),
            stops: stops!.map((s) => s.offset).toList(),
            begin: _angleToAlignment(angle ?? 180),
            end: _angleToAlignment((angle ?? 180) + 180),
          ),
        );

      case BackgroundType.radialGradient:
        if (stops == null || stops!.isEmpty) return null;
        return BoxDecoration(
          gradient: RadialGradient(
            colors: stops!.map((s) => s.color.withOpacity(opacity)).toList(),
            stops: stops!.map((s) => s.offset).toList(),
            center: Alignment(
              (center?.dx ?? 0.5) * 2 - 1,
              (center?.dy ?? 0.5) * 2 - 1,
            ),
            radius: radius ?? 0.5,
          ),
        );

      case BackgroundType.image:
      case BackgroundType.pattern:
        return null; // Handled separately
    }
  }

  /// Convert angle to alignment
  static Alignment _angleToAlignment(double angle) {
    final normalizedAngle = angle % 360;
    final radians = normalizedAngle * (3.14159265359 / 180);
    return Alignment(
      double.parse((-1 * (radians - 1.5708).abs() + 1.5708).toStringAsFixed(2)),
      double.parse((-1 * radians.abs() + 1.5708).toStringAsFixed(2)),
    );
  }

  /// Create copy with modifications
  PosterBackground copyWith({
    BackgroundType? type,
    Color? color,
    double? opacity,
    double? angle,
    List<GradientStop>? stops,
    Offset? center,
    double? radius,
    String? assetId,
    String? fit,
    Offset? position,
    BackgroundImageFilters? imageFilters,
    PatternType? patternType,
    Color? primaryColor,
    Color? secondaryColor,
    double? patternScale,
    double? patternRotation,
  }) {
    return PosterBackground(
      type: type ?? this.type,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      angle: angle ?? this.angle,
      stops: stops ?? this.stops,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      assetId: assetId ?? this.assetId,
      fit: fit ?? this.fit,
      position: position ?? this.position,
      imageFilters: imageFilters ?? this.imageFilters,
      patternType: patternType ?? this.patternType,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      patternScale: patternScale ?? this.patternScale,
      patternRotation: patternRotation ?? this.patternRotation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterBackground &&
        other.type == type &&
        other.color == color &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(type, color, opacity);
}

/// Image filter settings for background
class BackgroundImageFilters {
  final double blur;
  final double brightness;
  final double contrast;

  const BackgroundImageFilters({
    this.blur = 0,
    this.brightness = 1.0,
    this.contrast = 1.0,
  });

  /// No filters
  static const BackgroundImageFilters none = BackgroundImageFilters();

  /// Create from JSON
  factory BackgroundImageFilters.fromJson(JsonMap json) {
    return BackgroundImageFilters(
      blur: JsonUtils.getValue<double>(json, 'blur', 0)!,
      brightness: JsonUtils.getValue<double>(json, 'brightness', 1.0)!,
      contrast: JsonUtils.getValue<double>(json, 'contrast', 1.0)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'blur': blur,
    'brightness': brightness,
    'contrast': contrast,
  };

  /// Check if any filters are applied
  bool get hasFilters => blur > 0 || brightness != 1.0 || contrast != 1.0;
}
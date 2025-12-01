import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Blur effect types
enum BlurType {
  gaussian,
  motion,
  zoom,
}

/// Blur effect for layers
class BlurEffect {
  final bool enabled;
  final BlurType type;
  final double sigma;
  final double? angle; // For motion blur (degrees)

  const BlurEffect({
    this.enabled = true,
    this.type = BlurType.gaussian,
    this.sigma = 5.0,
    this.angle,
  });

  /// No blur
  static const BlurEffect none = BlurEffect(enabled: false, sigma: 0);

  /// Subtle blur
  static const BlurEffect subtle = BlurEffect(sigma: 2.0);

  /// Medium blur
  static const BlurEffect medium = BlurEffect(sigma: 5.0);

  /// Heavy blur
  static const BlurEffect heavy = BlurEffect(sigma: 10.0);

  /// Create from JSON
  factory BlurEffect.fromJson(JsonMap? json) {
    if (json == null) return BlurEffect.none;

    return BlurEffect(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', true)!,
      type: JsonUtils.parseEnum(json['type'] as String?, BlurType.values) ??
          BlurType.gaussian,
      sigma: JsonUtils.getValue<double>(json, 'sigma', 5.0)!,
      angle: JsonUtils.getValue<double>(json, 'angle'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'type': type.name,
    'sigma': sigma,
    if (angle != null) 'angle': angle,
  };

  /// Get sigma for X axis
  double get sigmaX => sigma;

  /// Get sigma for Y axis
  double get sigmaY => sigma;

  /// Create copy with modifications
  BlurEffect copyWith({
    bool? enabled,
    BlurType? type,
    double? sigma,
    double? angle,
  }) {
    return BlurEffect(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      sigma: sigma ?? this.sigma,
      angle: angle ?? this.angle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlurEffect &&
        other.enabled == enabled &&
        other.type == type &&
        other.sigma == sigma &&
        other.angle == angle;
  }

  @override
  int get hashCode => Object.hash(enabled, type, sigma, angle);
}
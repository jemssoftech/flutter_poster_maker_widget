import '../../../core/types/typedefs.dart';
import 'shadow_effect.dart';
import 'blur_effect.dart';
import 'border_effect.dart';

/// Combined effects for a layer
class LayerEffects {
  final ShadowEffect? shadow;
  final ShadowEffect? innerShadow;
  final BlurEffect? blur;
  final BorderEffect? border;

  const LayerEffects({
    this.shadow,
    this.innerShadow,
    this.blur,
    this.border,
  });

  /// No effects
  static const LayerEffects none = LayerEffects();

  /// Check if any effects are enabled
  bool get hasEffects {
    return (shadow?.enabled ?? false) ||
        (innerShadow?.enabled ?? false) ||
        (blur?.enabled ?? false) ||
        (border?.enabled ?? false);
  }

  /// Create from JSON
  factory LayerEffects.fromJson(JsonMap? json) {
    if (json == null) return LayerEffects.none;

    return LayerEffects(
      shadow: json['shadow'] != null
          ? ShadowEffect.fromJson(json['shadow'] as JsonMap)
          : null,
      innerShadow: json['inner_shadow'] != null
          ? ShadowEffect.fromJson(json['inner_shadow'] as JsonMap)
          : null,
      blur: json['blur'] != null
          ? BlurEffect.fromJson(json['blur'] as JsonMap)
          : null,
      border: json['border'] != null
          ? BorderEffect.fromJson(json['border'] as JsonMap)
          : null,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    if (shadow != null) 'shadow': shadow!.toJson(),
    if (innerShadow != null) 'inner_shadow': innerShadow!.toJson(),
    if (blur != null) 'blur': blur!.toJson(),
    if (border != null) 'border': border!.toJson(),
  };

  /// Create copy with modifications
  LayerEffects copyWith({
    ShadowEffect? shadow,
    ShadowEffect? innerShadow,
    BlurEffect? blur,
    BorderEffect? border,
    bool clearShadow = false,
    bool clearInnerShadow = false,
    bool clearBlur = false,
    bool clearBorder = false,
  }) {
    return LayerEffects(
      shadow: clearShadow ? null : (shadow ?? this.shadow),
      innerShadow: clearInnerShadow ? null : (innerShadow ?? this.innerShadow),
      blur: clearBlur ? null : (blur ?? this.blur),
      border: clearBorder ? null : (border ?? this.border),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LayerEffects &&
        other.shadow == shadow &&
        other.innerShadow == innerShadow &&
        other.blur == blur &&
        other.border == border;
  }

  @override
  int get hashCode => Object.hash(shadow, innerShadow, blur, border);
}
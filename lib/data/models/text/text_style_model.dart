import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Text style model for text layers
class TextStyleModel {
  final String fontFamily;
  final int fontWeight;
  final String fontStyle; // 'normal' or 'italic'
  final double fontSize;
  final Color color;
  final Color? backgroundColor;
  final bool underline;
  final bool strikethrough;
  final double letterSpacing;
  final double? baselineOffset;

  const TextStyleModel({
    this.fontFamily = 'Roboto',
    this.fontWeight = 400,
    this.fontStyle = 'normal',
    this.fontSize = 48,
    this.color = Colors.black,
    this.backgroundColor,
    this.underline = false,
    this.strikethrough = false,
    this.letterSpacing = 0,
    this.baselineOffset,
  });

  /// Default text style
  static const TextStyleModel defaultStyle = TextStyleModel();

  /// Create from JSON
  factory TextStyleModel.fromJson(JsonMap? json) {
    if (json == null) return TextStyleModel.defaultStyle;

    return TextStyleModel(
      fontFamily: JsonUtils.getValue<String>(json, 'font_family', 'Roboto')!,
      fontWeight: JsonUtils.getValue<int>(json, 'font_weight', 400)!,
      fontStyle: JsonUtils.getValue<String>(json, 'font_style', 'normal')!,
      fontSize: JsonUtils.getValue<double>(json, 'font_size', 48)!,
      color: JsonUtils.parseColor(json['color'], Colors.black)!,
      backgroundColor: JsonUtils.parseColor(json['background_color']),
      underline: JsonUtils.getValue<bool>(json, 'underline', false)!,
      strikethrough: JsonUtils.getValue<bool>(json, 'strikethrough', false)!,
      letterSpacing: JsonUtils.getValue<double>(json, 'letter_spacing', 0)!,
      baselineOffset: JsonUtils.getValue<double>(json, 'baseline_offset'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'font_family': fontFamily,
    'font_weight': fontWeight,
    'font_style': fontStyle,
    'font_size': fontSize,
    'color': JsonUtils.colorToJson(color),
    if (backgroundColor != null) 'background_color': JsonUtils.colorToJson(backgroundColor),
    'underline': underline,
    'strikethrough': strikethrough,
    'letter_spacing': letterSpacing,
    if (baselineOffset != null) 'baseline_offset': baselineOffset,
  };

  /// Convert to Flutter FontWeight
  FontWeight get flutterFontWeight {
    switch (fontWeight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  /// Convert to Flutter FontStyle
  FontStyle get flutterFontStyle {
    return fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal;
  }

  /// Convert to Flutter TextDecoration
  TextDecoration get flutterTextDecoration {
    if (underline && strikethrough) {
      return TextDecoration.combine([
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]);
    }
    if (underline) return TextDecoration.underline;
    if (strikethrough) return TextDecoration.lineThrough;
    return TextDecoration.none;
  }

  /// Convert to Flutter TextStyle
  TextStyle toTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: flutterFontWeight,
      fontStyle: flutterFontStyle,
      fontSize: fontSize,
      color: color,
      backgroundColor: backgroundColor,
      decoration: flutterTextDecoration,
      letterSpacing: letterSpacing,
      height: 1.0, // Line height handled separately
    );
  }

  /// Create copy with modifications
  TextStyleModel copyWith({
    String? fontFamily,
    int? fontWeight,
    String? fontStyle,
    double? fontSize,
    Color? color,
    Color? backgroundColor,
    bool? underline,
    bool? strikethrough,
    double? letterSpacing,
    double? baselineOffset,
    bool clearBackgroundColor = false,
  }) {
    return TextStyleModel(
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      backgroundColor: clearBackgroundColor ? null : (backgroundColor ?? this.backgroundColor),
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      baselineOffset: baselineOffset ?? this.baselineOffset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextStyleModel &&
        other.fontFamily == fontFamily &&
        other.fontWeight == fontWeight &&
        other.fontStyle == fontStyle &&
        other.fontSize == fontSize &&
        other.color == color &&
        other.backgroundColor == backgroundColor &&
        other.underline == underline &&
        other.strikethrough == strikethrough &&
        other.letterSpacing == letterSpacing;
  }

  @override
  int get hashCode => Object.hash(
    fontFamily, fontWeight, fontStyle, fontSize, color,
    backgroundColor, underline, strikethrough, letterSpacing,
  );
}
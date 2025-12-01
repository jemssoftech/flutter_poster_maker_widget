import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/constants/editor_constants.dart';
import '../transform/layer_transform.dart';
import '../effects/layer_effects.dart';
import '../text/text_style_model.dart';
import '../text/paragraph_style.dart';
import '../text/rich_text_span.dart';
import '../text/text_background.dart';
import '../effects/shadow_effect.dart';
import 'layer_base.dart';

/// Text transform options
enum TextTransform {
  none,
  uppercase,
  lowercase,
  capitalize,
}

/// Text overflow options
enum TextOverflow {
  visible,
  clip,
  ellipsis,
  fade,
}

/// Text outline settings
class TextOutline {
  final bool enabled;
  final Color color;
  final double width;

  const TextOutline({
    this.enabled = false,
    this.color = Colors.black,
    this.width = 2,
  });

  /// No outline
  static const TextOutline none = TextOutline();

  /// Create from JSON
  factory TextOutline.fromJson(JsonMap? json) {
    if (json == null) return TextOutline.none;

    return TextOutline(
      enabled: JsonUtils.getValue<bool>(json, 'enabled', false)!,
      color: JsonUtils.parseColor(json['color'], Colors.black)!,
      width: JsonUtils.getValue<double>(json, 'width', 2)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'enabled': enabled,
    'color': JsonUtils.colorToJson(color),
    'width': width,
  };

  /// Create copy with modifications
  TextOutline copyWith({
    bool? enabled,
    Color? color,
    double? width,
  }) {
    return TextOutline(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
}

/// Text layer
class TextLayer extends LayerBase {
  /// Plain text content
  final String text;

  /// Rich text spans (optional, for mixed styles)
  final List<RichTextSpan>? richText;

  /// Font family
  final String fontFamily;

  /// Font weight (100-900)
  final int fontWeight;

  /// Font style ('normal' or 'italic')
  final String fontStyle;

  /// Font size in pixels
  final double fontSize;

  /// Text color
  final Color color;

  /// Letter spacing
  final double letterSpacing;

  /// Paragraph style
  final ParagraphStyle paragraph;

  /// Text transform
  final TextTransform textTransform;

  /// Text overflow behavior
  final TextOverflow overflow;

  /// Auto size text to fit bounds
  final bool autoSize;

  /// Maximum number of lines (null = unlimited)
  final int? maxLines;

  /// Text outline
  final TextOutline outline;

  /// Text background box
  final TextBackground background;

  /// Text shadow (separate from layer effects)
  final ShadowEffect? textShadow;

  const TextLayer({
    required super.id,
    required super.name,
    super.visible,
    super.locked,
    super.opacity,
    super.blendMode,
    super.transform,
    super.effects,
    required this.text,
    this.richText,
    this.fontFamily = 'Roboto',
    this.fontWeight = 400,
    this.fontStyle = 'normal',
    this.fontSize = 48,
    this.color = Colors.black,
    this.letterSpacing = 0,
    this.paragraph = const ParagraphStyle(),
    this.textTransform = TextTransform.none,
    this.overflow = TextOverflow.visible,
    this.autoSize = true,
    this.maxLines,
    this.outline = const TextOutline(),
    this.background = const TextBackground(),
    this.textShadow,
  }) : super(type: LayerTypes.text);

  /// Check if using rich text
  bool get hasRichText => richText != null && richText!.isNotEmpty;

  /// Get transformed text
  String get transformedText {
    switch (textTransform) {
      case TextTransform.none:
        return text;
      case TextTransform.uppercase:
        return text.toUpperCase();
      case TextTransform.lowercase:
        return text.toLowerCase();
      case TextTransform.capitalize:
        return text.split(' ').map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        }).join(' ');
    }
  }

  /// Get Flutter FontWeight
  FontWeight get flutterFontWeight {
    switch (fontWeight) {
      case 100: return FontWeight.w100;
      case 200: return FontWeight.w200;
      case 300: return FontWeight.w300;
      case 400: return FontWeight.w400;
      case 500: return FontWeight.w500;
      case 600: return FontWeight.w600;
      case 700: return FontWeight.w700;
      case 800: return FontWeight.w800;
      case 900: return FontWeight.w900;
      default: return FontWeight.w400;
    }
  }

  /// Get Flutter FontStyle
  FontStyle get flutterFontStyle {
    return fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal;
  }

  /// Build TextStyle
  TextStyle buildTextStyle() {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: flutterFontWeight,
      fontStyle: flutterFontStyle,
      fontSize: fontSize,
      color: color,
      letterSpacing: letterSpacing,
      height: paragraph.lineHeight,
      shadows: textShadow?.enabled == true ? [textShadow!.toShadow()!] : null,
    );
  }

  /// Create from JSON
  factory TextLayer.fromJson(JsonMap json) {
    final props = LayerJsonParser.parseProps(json);

    // Handle both flat props and nested paragraph object
    final paragraphJson = props['paragraph'] as JsonMap?;

    return TextLayer(
      id: LayerJsonParser.parseId(json),
      name: LayerJsonParser.parseName(json, 'Text'),
      visible: LayerJsonParser.parseVisible(json),
      locked: LayerJsonParser.parseLocked(json),
      opacity: LayerJsonParser.parseOpacity(json),
      blendMode: LayerJsonParser.parseBlendMode(json),
      transform: LayerJsonParser.parseTransform(json),
      effects: LayerJsonParser.parseEffects(json),
      text: JsonUtils.getValue<String>(props, 'text', '')!,
      richText: (props['rich_text'] as List<dynamic>?)
          ?.map((e) => RichTextSpan.fromJson(e as JsonMap))
          .toList(),
      fontFamily: JsonUtils.getValue<String>(props, 'font_family') ??
          JsonUtils.getValue<String>(props, 'fontFamily', 'Roboto')!,
      fontWeight: JsonUtils.getValue<int>(props, 'font_weight') ??
          JsonUtils.getValue<int>(props, 'fontWeight', 400)!,
      fontStyle: JsonUtils.getValue<String>(props, 'font_style', 'normal')!,
      fontSize: JsonUtils.getValue<double>(props, 'font_size') ??
          JsonUtils.getValue<double>(props, 'fontSize', 48)!,
      color: JsonUtils.parseColor(props['color'], Colors.black)!,
      letterSpacing: JsonUtils.getValue<double>(props, 'letter_spacing') ??
          JsonUtils.getValue<double>(props, 'letterSpacing', 0)!,
      paragraph: ParagraphStyle.fromJson(paragraphJson),
      textTransform: JsonUtils.parseEnum(
        props['text_transform'] as String?,
        TextTransform.values,
      ) ??
          TextTransform.none,
      overflow: JsonUtils.parseEnum(
        props['overflow'] as String?,
        TextOverflow.values,
      ) ??
          TextOverflow.visible,
      autoSize: JsonUtils.getValue<bool>(props, 'auto_size', true)!,
      maxLines: JsonUtils.getValue<int>(props, 'max_lines'),
      outline: TextOutline.fromJson(props['outline'] as JsonMap?),
      background: TextBackground.fromJson(props['background'] as JsonMap?),
      textShadow: props['text_shadow'] != null
          ? ShadowEffect.fromJson(props['text_shadow'] as JsonMap)
          : null,
    );
  }

  @override
  JsonMap propsToJson() => {
    'text': text,
    if (richText != null) 'rich_text': richText!.map((s) => s.toJson()).toList(),
    'font_family': fontFamily,
    'font_weight': fontWeight,
    'font_style': fontStyle,
    'font_size': fontSize,
    'color': JsonUtils.colorToJson(color),
    'letter_spacing': letterSpacing,
    'paragraph': paragraph.toJson(),
    'text_transform': textTransform.name,
    'overflow': overflow.name,
    'auto_size': autoSize,
    if (maxLines != null) 'max_lines': maxLines,
    'outline': outline.toJson(),
    'background': background.toJson(),
    if (textShadow != null) 'text_shadow': textShadow!.toJson(),
  };

  @override
  TextLayer copyWith({
    String? id,
    String? name,
    bool? visible,
    bool? locked,
    double? opacity,
    LayerBlendMode? blendMode,
    LayerTransform? transform,
    LayerEffects? effects,
    String? text,
    List<RichTextSpan>? richText,
    String? fontFamily,
    int? fontWeight,
    String? fontStyle,
    double? fontSize,
    Color? color,
    double? letterSpacing,
    ParagraphStyle? paragraph,
    TextTransform? textTransform,
    TextOverflow? overflow,
    bool? autoSize,
    int? maxLines,
    TextOutline? outline,
    TextBackground? background,
    ShadowEffect? textShadow,
    bool clearRichText = false,
    bool clearMaxLines = false,
    bool clearTextShadow = false,
  }) {
    return TextLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      transform: transform ?? this.transform,
      effects: effects ?? this.effects,
      text: text ?? this.text,
      richText: clearRichText ? null : (richText ?? this.richText),
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      paragraph: paragraph ?? this.paragraph,
      textTransform: textTransform ?? this.textTransform,
      overflow: overflow ?? this.overflow,
      autoSize: autoSize ?? this.autoSize,
      maxLines: clearMaxLines ? null : (maxLines ?? this.maxLines),
      outline: outline ?? this.outline,
      background: background ?? this.background,
      textShadow: clearTextShadow ? null : (textShadow ?? this.textShadow),
    );
  }

  @override
  TextLayer withTransform(LayerTransform transform) {
    return copyWith(transform: transform);
  }

  @override
  TextLayer withEffects(LayerEffects effects) {
    return copyWith(effects: effects);
  }
}
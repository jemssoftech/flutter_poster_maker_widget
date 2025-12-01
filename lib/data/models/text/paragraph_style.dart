import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Text alignment options
enum TextAlignmentType {
  left,
  center,
  right,
  justify,
}

/// Vertical alignment options
enum VerticalAlignmentType {
  top,
  center,
  bottom,
}

/// Text direction options
enum TextDirectionType {
  ltr,
  rtl,
}

/// Paragraph style model
class ParagraphStyle {
  final TextAlignmentType alignment;
  final double lineHeight;
  final double paragraphSpacing;
  final TextDirectionType textDirection;
  final VerticalAlignmentType verticalAlignment;

  const ParagraphStyle({
    this.alignment = TextAlignmentType.left,
    this.lineHeight = 1.2,
    this.paragraphSpacing = 0,
    this.textDirection = TextDirectionType.ltr,
    this.verticalAlignment = VerticalAlignmentType.top,
  });

  /// Default paragraph style
  static const ParagraphStyle defaultStyle = ParagraphStyle();

  /// Centered paragraph style
  static const ParagraphStyle centered = ParagraphStyle(
    alignment: TextAlignmentType.center,
  );

  /// Create from JSON
  factory ParagraphStyle.fromJson(JsonMap? json) {
    if (json == null) return ParagraphStyle.defaultStyle;

    return ParagraphStyle(
      alignment: JsonUtils.parseEnum(
        json['alignment'] as String?,
        TextAlignmentType.values,
      ) ??
          TextAlignmentType.left,
      lineHeight: JsonUtils.getValue<double>(json, 'line_height', 1.2)!,
      paragraphSpacing: JsonUtils.getValue<double>(json, 'paragraph_spacing', 0)!,
      textDirection: JsonUtils.parseEnum(
        json['text_direction'] as String?,
        TextDirectionType.values,
      ) ??
          TextDirectionType.ltr,
      verticalAlignment: JsonUtils.parseEnum(
        json['vertical_alignment'] as String?,
        VerticalAlignmentType.values,
      ) ??
          VerticalAlignmentType.top,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'alignment': alignment.name,
    'line_height': lineHeight,
    'paragraph_spacing': paragraphSpacing,
    'text_direction': textDirection.name,
    'vertical_alignment': verticalAlignment.name,
  };

  /// Convert to Flutter TextAlign
  TextAlign get flutterTextAlign {
    switch (alignment) {
      case TextAlignmentType.left:
        return TextAlign.left;
      case TextAlignmentType.center:
        return TextAlign.center;
      case TextAlignmentType.right:
        return TextAlign.right;
      case TextAlignmentType.justify:
        return TextAlign.justify;
    }
  }

  /// Convert to Flutter TextDirection
  TextDirection get flutterTextDirection {
    switch (textDirection) {
      case TextDirectionType.ltr:
        return TextDirection.ltr;
      case TextDirectionType.rtl:
        return TextDirection.rtl;
    }
  }

  /// Convert to Flutter CrossAxisAlignment (for vertical alignment)
  CrossAxisAlignment get flutterCrossAxisAlignment {
    switch (verticalAlignment) {
      case VerticalAlignmentType.top:
        return CrossAxisAlignment.start;
      case VerticalAlignmentType.center:
        return CrossAxisAlignment.center;
      case VerticalAlignmentType.bottom:
        return CrossAxisAlignment.end;
    }
  }

  /// Create copy with modifications
  ParagraphStyle copyWith({
    TextAlignmentType? alignment,
    double? lineHeight,
    double? paragraphSpacing,
    TextDirectionType? textDirection,
    VerticalAlignmentType? verticalAlignment,
  }) {
    return ParagraphStyle(
      alignment: alignment ?? this.alignment,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      textDirection: textDirection ?? this.textDirection,
      verticalAlignment: verticalAlignment ?? this.verticalAlignment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParagraphStyle &&
        other.alignment == alignment &&
        other.lineHeight == lineHeight &&
        other.paragraphSpacing == paragraphSpacing &&
        other.textDirection == textDirection &&
        other.verticalAlignment == verticalAlignment;
  }

  @override
  int get hashCode => Object.hash(
    alignment, lineHeight, paragraphSpacing, textDirection, verticalAlignment,
  );
}
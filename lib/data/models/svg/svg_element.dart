import 'package:flutter/material.dart';
import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Represents a single element within an SVG that can be edited
class SvgElement {
  final String id;
  final String tag; // 'path', 'circle', 'rect', 'g', etc.
  final Color? originalFill;
  final Color? originalStroke;
  final double? originalStrokeWidth;
  final double? originalOpacity;
  final String? name; // Optional display name

  const SvgElement({
    required this.id,
    required this.tag,
    this.originalFill,
    this.originalStroke,
    this.originalStrokeWidth,
    this.originalOpacity,
    this.name,
  });

  /// Create from JSON
  factory SvgElement.fromJson(String id, JsonMap json) {
    return SvgElement(
      id: id,
      tag: JsonUtils.getValue<String>(json, 'tag', 'path')!,
      originalFill: JsonUtils.parseColor(json['original_fill']),
      originalStroke: JsonUtils.parseColor(json['original_stroke']),
      originalStrokeWidth: JsonUtils.getValue<double>(json, 'original_stroke_width'),
      originalOpacity: JsonUtils.getValue<double>(json, 'original_opacity'),
      name: JsonUtils.getValue<String>(json, 'name'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'tag': tag,
    if (originalFill != null) 'original_fill': JsonUtils.colorToJson(originalFill),
    if (originalStroke != null) 'original_stroke': JsonUtils.colorToJson(originalStroke),
    if (originalStrokeWidth != null) 'original_stroke_width': originalStrokeWidth,
    if (originalOpacity != null) 'original_opacity': originalOpacity,
    if (name != null) 'name': name,
  };

  /// Get display name (uses name if available, otherwise id)
  String get displayName => name ?? id;

  /// Check if element has fill
  bool get hasFill => originalFill != null;

  /// Check if element has stroke
  bool get hasStroke => originalStroke != null;

  /// Check if element is editable (has fill or stroke)
  bool get isEditable => hasFill || hasStroke;

  /// Create copy with modifications
  SvgElement copyWith({
    String? id,
    String? tag,
    Color? originalFill,
    Color? originalStroke,
    double? originalStrokeWidth,
    double? originalOpacity,
    String? name,
  }) {
    return SvgElement(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      originalFill: originalFill ?? this.originalFill,
      originalStroke: originalStroke ?? this.originalStroke,
      originalStrokeWidth: originalStrokeWidth ?? this.originalStrokeWidth,
      originalOpacity: originalOpacity ?? this.originalOpacity,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SvgElement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SvgElement($id, $tag)';
}
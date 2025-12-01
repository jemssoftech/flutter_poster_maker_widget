import '../../../core/types/typedefs.dart';
import 'text_style_model.dart';

/// A span of text with its own style (for rich text support)
class RichTextSpan {
  final String text;
  final TextStyleModel style;

  const RichTextSpan({
    required this.text,
    required this.style,
  });

  /// Create from JSON
  factory RichTextSpan.fromJson(JsonMap json) {
    return RichTextSpan(
      text: json['text'] as String? ?? '',
      style: TextStyleModel.fromJson(json['style'] as JsonMap?),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'text': text,
    'style': style.toJson(),
  };

  /// Create copy with modifications
  RichTextSpan copyWith({
    String? text,
    TextStyleModel? style,
  }) {
    return RichTextSpan(
      text: text ?? this.text,
      style: style ?? this.style,
    );
  }

  /// Get text length
  int get length => text.length;

  /// Check if span is empty
  bool get isEmpty => text.isEmpty;

  /// Check if span is not empty
  bool get isNotEmpty => text.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RichTextSpan && other.text == text && other.style == style;
  }

  @override
  int get hashCode => Object.hash(text, style);
}
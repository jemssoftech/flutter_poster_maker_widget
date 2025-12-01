import '../../core/types/typedefs.dart';
import '../../core/utils/json_utils.dart';

/// Poster document metadata
class PosterMetadata {
  /// Unique document ID
  final String id;

  /// Document name/title
  final String name;

  /// Optional description
  final String? description;

  /// Author email or identifier
  final String? author;

  /// Creation timestamp
  final DateTime created;

  /// Last modification timestamp
  final DateTime modified;

  /// Tags for organization
  final List<String> tags;

  /// Template ID if created from template
  final String? templateId;

  const PosterMetadata({
    required this.id,
    required this.name,
    this.description,
    this.author,
    required this.created,
    required this.modified,
    this.tags = const [],
    this.templateId,
  });

  /// Create default metadata with new ID
  factory PosterMetadata.create({
    required String id,
    String name = 'Untitled Poster',
    String? author,
  }) {
    final now = DateTime.now();
    return PosterMetadata(
      id: id,
      name: name,
      author: author,
      created: now,
      modified: now,
    );
  }

  /// Create from JSON
  factory PosterMetadata.fromJson(JsonMap json) {
    return PosterMetadata(
      id: JsonUtils.getRequired<String>(json, 'id', 'metadata'),
      name: JsonUtils.getValue<String>(json, 'name', 'Untitled Poster')!,
      description: JsonUtils.getValue<String>(json, 'description'),
      author: JsonUtils.getValue<String>(json, 'author'),
      created: _parseDateTime(json['created']) ?? DateTime.now(),
      modified: _parseDateTime(json['modified']) ?? DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      templateId: JsonUtils.getValue<String>(json, 'template_id'),
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (author != null) 'author': author,
    'created': created.toIso8601String(),
    'modified': modified.toIso8601String(),
    'tags': tags,
    if (templateId != null) 'template_id': templateId,
  };

  /// Parse DateTime from ISO string or null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Create copy with updated modification time
  PosterMetadata touch() {
    return copyWith(modified: DateTime.now());
  }

  /// Create copy with modifications
  PosterMetadata copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    DateTime? created,
    DateTime? modified,
    List<String>? tags,
    String? templateId,
    bool clearDescription = false,
    bool clearAuthor = false,
    bool clearTemplateId = false,
  }) {
    return PosterMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      author: clearAuthor ? null : (author ?? this.author),
      created: created ?? this.created,
      modified: modified ?? this.modified,
      tags: tags ?? this.tags,
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterMetadata && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PosterMetadata($id, $name)';
}
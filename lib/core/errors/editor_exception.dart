/// Base exception for all editor errors
abstract class EditorException implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  final StackTrace? stackTrace;

  const EditorException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'EditorException($code): $message';
}

/// Exception for JSON parsing/serialization errors
class JsonParseException extends EditorException {
  final String? jsonPath;

  const JsonParseException({
    required super.message,
    this.jsonPath,
    super.code = 'JSON_PARSE_ERROR',
    super.details,
    super.stackTrace,
  });

  @override
  String toString() => 'JsonParseException at $jsonPath: $message';
}

/// Exception for schema validation errors
class SchemaValidationException extends EditorException {
  final List<ValidationError> errors;

  const SchemaValidationException({
    required super.message,
    this.errors = const [],
    super.code = 'SCHEMA_VALIDATION_ERROR',
    super.details,
    super.stackTrace,
  });

  @override
  String toString() =>
      'SchemaValidationException: $message\n${errors.map((e) => '  - $e').join('\n')}';
}

/// Single validation error
class ValidationError {
  final String path;
  final String message;
  final dynamic expectedValue;
  final dynamic actualValue;

  const ValidationError({
    required this.path,
    required this.message,
    this.expectedValue,
    this.actualValue,
  });

  @override
  String toString() => '[$path] $message';
}

/// Exception for layer operations
class LayerException extends EditorException {
  final String? layerId;
  final String? layerType;

  const LayerException({
    required super.message,
    this.layerId,
    this.layerType,
    super.code = 'LAYER_ERROR',
    super.details,
    super.stackTrace,
  });

  @override
  String toString() => 'LayerException($layerId): $message';
}

/// Exception for asset operations
class AssetException extends EditorException {
  final String? assetId;
  final String? assetType;

  const AssetException({
    required super.message,
    this.assetId,
    this.assetType,
    super.code = 'ASSET_ERROR',
    super.details,
    super.stackTrace,
  });
}

/// Exception for export operations
class ExportException extends EditorException {
  final String? format;

  const ExportException({
    required super.message,
    this.format,
    super.code = 'EXPORT_ERROR',
    super.details,
    super.stackTrace,
  });
}

/// Exception for font loading
class FontException extends EditorException {
  final String? fontFamily;
  final int? fontWeight;

  const FontException({
    required super.message,
    this.fontFamily,
    this.fontWeight,
    super.code = 'FONT_ERROR',
    super.details,
    super.stackTrace,
  });
}

/// Exception for SVG parsing
class SvgParseException extends EditorException {
  final String? elementId;

  const SvgParseException({
    required super.message,
    this.elementId,
    super.code = 'SVG_PARSE_ERROR',
    super.details,
    super.stackTrace,
  });
}

/// Exception for transform operations
class TransformException extends EditorException {
  const TransformException({
    required super.message,
    super.code = 'TRANSFORM_ERROR',
    super.details,
    super.stackTrace,
  });
}
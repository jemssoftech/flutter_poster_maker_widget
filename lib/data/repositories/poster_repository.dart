import 'dart:convert';

import '../../core/types/typedefs.dart';
import '../../core/errors/editor_exception.dart';
import '../models/poster_document.dart';
import '../../services/json/json_serializer.dart';
import '../../services/json/schema_validator.dart';

/// Repository for poster document operations
abstract class PosterRepository {
  /// Load document from JSON string
  Future<PosterDocument> loadFromJson(String jsonString);

  /// Save document to JSON string
  Future<String> saveToJson(PosterDocument document, {bool pretty = true});

  /// Validate document JSON
  Future<ValidationResult> validateJson(String jsonString);
}

/// Implementation of PosterRepository
class PosterRepositoryImpl implements PosterRepository {
  final JsonSerializer _serializer;
  final SchemaValidator _validator;

  PosterRepositoryImpl({
    JsonSerializer? serializer,
    SchemaValidator? validator,
  })  : _serializer = serializer ?? const JsonSerializer(),
        _validator = validator ?? const SchemaValidator();

  @override
  Future<PosterDocument> loadFromJson(String jsonString) async {
    try {
      // Validate first
      final json = jsonDecode(jsonString) as JsonMap;
      final validationResult = _validator.validate(json);

      if (!validationResult.isValid) {
        throw SchemaValidationException(
          message: 'Document validation failed',
          errors: validationResult.errors,
        );
      }

      // Parse document
      return _serializer.deserialize(jsonString);
    } catch (e) {
      if (e is EditorException) rethrow;
      throw JsonParseException(
        message: 'Failed to load document: $e',
      );
    }
  }

  @override
  Future<String> saveToJson(PosterDocument document, {bool pretty = true}) async {
    try {
      return _serializer.serialize(document, pretty: pretty);
    } catch (e) {
      if (e is EditorException) rethrow;
      throw JsonParseException(
        message: 'Failed to save document: $e',
      );
    }
  }

  @override
  Future<ValidationResult> validateJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString) as JsonMap;
      return _validator.validate(json);
    } catch (e) {
      return ValidationResult(
        isValid: false,
        errors: [
          ValidationError(
            path: 'root',
            message: 'Invalid JSON: $e',
          ),
        ],
      );
    }
  }
}
import 'dart:convert' show JsonEncoder, jsonEncode, jsonDecode;

import '../../core/types/typedefs.dart';
import '../../core/errors/editor_exception.dart';
import '../../data/models/poster_document.dart';

class JsonSerializer {
  const JsonSerializer();

  String serialize(PosterDocument document, {bool pretty = false}) {
    try {
      final json = document.toJson();

      if (pretty) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(json);
      }
      return jsonEncode(json);
    } catch (e) {
      throw JsonParseException(
        message: 'Failed to serialize document: $e',
      );
    }
  }

  /// Deserialize JSON string to document
  PosterDocument deserialize(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as JsonMap;
      return PosterDocument.fromJson(json);
    } on FormatException catch (e) {
      throw JsonParseException(
        message: 'Invalid JSON format: ${e.message}',
      );
    } catch (e) {
      if (e is EditorException) rethrow;
      throw JsonParseException(
        message: 'Failed to deserialize document: $e',
      );
    }
  }

  /// Validate JSON string without parsing
  bool isValidJson(String jsonString) {
    try {
      jsonDecode(jsonString);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Parse JSON string to map
  JsonMap? parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as JsonMap;
    } catch (_) {
      return null;
    }
  }

  /// Deep clone a JSON map
  JsonMap cloneJson(JsonMap json) {
    return jsonDecode(jsonEncode(json)) as JsonMap;
  }

  /// Minify JSON string
  String minify(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return jsonEncode(json);
    } catch (_) {
      return jsonString;
    }
  }

  /// Prettify JSON string
  String prettify(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (_) {
      return jsonString;
    }
  }
}
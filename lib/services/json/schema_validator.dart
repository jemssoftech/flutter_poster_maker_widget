import '../../core/types/typedefs.dart';
import '../../core/errors/editor_exception.dart';
import '../../core/constants/editor_constants.dart';

/// Service for validating poster JSON against schema
class SchemaValidator {
  const SchemaValidator();

  /// Validate document JSON
  ValidationResult validate(JsonMap json) {
    final errors = <ValidationError>[];

    // Validate version
    _validateVersion(json, errors);

    // Validate metadata
    _validateMetadata(json['metadata'] as JsonMap?, errors);

    // Validate poster/canvas
    _validatePoster(json['poster'] as JsonMap?, errors);

    // Validate assets
    _validateAssets(json['assets'] as JsonMap?, errors);

    // Validate layers
    _validateLayers(json['layers'] as List<dynamic>?, errors);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate and throw if invalid
  void validateOrThrow(JsonMap json) {
    final result = validate(json);
    if (!result.isValid) {
      throw SchemaValidationException(
        message: 'Document validation failed',
        errors: result.errors,
      );
    }
  }

  void _validateVersion(JsonMap json, List<ValidationError> errors) {
    final version = json['version'] as String?;
    if (version == null) {
      errors.add(const ValidationError(
        path: 'version',
        message: 'Version is required',
      ));
      return;
    }

    // Check version format (semver)
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    if (!versionRegex.hasMatch(version)) {
      errors.add(ValidationError(
        path: 'version',
        message: 'Invalid version format',
        actualValue: version,
        expectedValue: 'X.Y.Z (semver)',
      ));
    }
  }

  void _validateMetadata(JsonMap? metadata, List<ValidationError> errors) {
    if (metadata == null) {
      errors.add(const ValidationError(
        path: 'metadata',
        message: 'Metadata is required',
      ));
      return;
    }

    // Check ID
    if (metadata['id'] == null) {
      errors.add(const ValidationError(
        path: 'metadata.id',
        message: 'Document ID is required',
      ));
    }

    // Check name
    if (metadata['name'] == null) {
      errors.add(const ValidationError(
        path: 'metadata.name',
        message: 'Document name is required',
      ));
    }

    // Check created timestamp
    final created = metadata['created'];
    if (created != null && created is String) {
      if (DateTime.tryParse(created) == null) {
        errors.add(ValidationError(
          path: 'metadata.created',
          message: 'Invalid timestamp format',
          actualValue: created,
          expectedValue: 'ISO 8601 format',
        ));
      }
    }

    // Check modified timestamp
    final modified = metadata['modified'];
    if (modified != null && modified is String) {
      if (DateTime.tryParse(modified) == null) {
        errors.add(ValidationError(
          path: 'metadata.modified',
          message: 'Invalid timestamp format',
          actualValue: modified,
          expectedValue: 'ISO 8601 format',
        ));
      }
    }
  }

  void _validatePoster(JsonMap? poster, List<ValidationError> errors) {
    if (poster == null) return;

    // Check width
    final width = poster['width'];
    if (width != null) {
      if (width is! num || width <= 0) {
        errors.add(ValidationError(
          path: 'poster.width',
          message: 'Width must be a positive number',
          actualValue: width,
        ));
      } else if (width > 10000) {
        errors.add(ValidationError(
          path: 'poster.width',
          message: 'Width exceeds maximum (10000px)',
          actualValue: width,
        ));
      }
    }

    // Check height
    final height = poster['height'];
    if (height != null) {
      if (height is! num || height <= 0) {
        errors.add(ValidationError(
          path: 'poster.height',
          message: 'Height must be a positive number',
          actualValue: height,
        ));
      } else if (height > 10000) {
        errors.add(ValidationError(
          path: 'poster.height',
          message: 'Height exceeds maximum (10000px)',
          actualValue: height,
        ));
      }
    }

    // Validate background
    _validateBackground(poster['background'] as JsonMap?, errors);
  }

  void _validateBackground(JsonMap? background, List<ValidationError> errors) {
    if (background == null) return;

    final type = background['type'] as String?;
    if (type != null && !BackgroundTypes.all.contains(type)) {
      errors.add(ValidationError(
        path: 'poster.background.type',
        message: 'Invalid background type',
        actualValue: type,
        expectedValue: BackgroundTypes.all,
      ));
    }

    // Validate gradient stops if gradient type
    if (type == BackgroundTypes.linearGradient || type == BackgroundTypes.radialGradient) {
      final stops = background['stops'] as List<dynamic>?;
      if (stops == null || stops.isEmpty) {
        errors.add(ValidationError(
          path: 'poster.background.stops',
          message: 'Gradient requires at least one stop',
          actualValue: stops,
        ));
      } else {
        for (int i = 0; i < stops.length; i++) {
          final stop = stops[i] as JsonMap?;
          if (stop == null) continue;

          final offset = stop['offset'];
          if (offset is num && (offset < 0 || offset > 1)) {
            errors.add(ValidationError(
              path: 'poster.background.stops[$i].offset',
              message: 'Stop offset must be between 0 and 1',
              actualValue: offset,
            ));
          }
        }
      }
    }
  }

  void _validateAssets(JsonMap? assets, List<ValidationError> errors) {
    if (assets == null) return;

    // Validate images
    final images = assets['images'] as Map<String, dynamic>?;
    if (images != null) {
      images.forEach((key, value) {
        if (value is! Map<String, dynamic>) {
          errors.add(ValidationError(
            path: 'assets.images.$key',
            message: 'Image asset must be an object',
          ));
        }
      });
    }

    // Validate fonts
    final fonts = assets['fonts'] as Map<String, dynamic>?;
    if (fonts != null) {
      fonts.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final family = value['family'];
          if (family == null || family is! String) {
            errors.add(ValidationError(
              path: 'assets.fonts.$key.family',
              message: 'Font family is required',
            ));
          }
        }
      });
    }

    // Validate SVGs
    final svgs = assets['svgs'] as Map<String, dynamic>?;
    if (svgs != null) {
      svgs.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final data = value['data'];
          if (data == null || data is! String) {
            errors.add(ValidationError(
              path: 'assets.svgs.$key.data',
              message: 'SVG data is required',
            ));
          }
        }
      });
    }
  }

  void _validateLayers(List<dynamic>? layers, List<ValidationError> errors) {
    if (layers == null) return;

    if (layers.length > EditorConstants.maxLayers) {
      errors.add(ValidationError(
        path: 'layers',
        message: 'Too many layers',
        actualValue: layers.length,
        expectedValue: 'Max ${EditorConstants.maxLayers}',
      ));
    }

    final ids = <String>{};

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];

      if (layer is! Map<String, dynamic>) {
        errors.add(ValidationError(
          path: 'layers[$i]',
          message: 'Layer must be an object',
        ));
        continue;
      }

      // Check ID uniqueness
      final id = layer['id'] as String?;
      if (id == null) {
        errors.add(ValidationError(
          path: 'layers[$i].id',
          message: 'Layer ID is required',
        ));
      } else if (ids.contains(id)) {
        errors.add(ValidationError(
          path: 'layers[$i].id',
          message: 'Duplicate layer ID',
          actualValue: id,
        ));
      } else {
        ids.add(id);
      }

      // Check type
      final type = layer['type'] as String?;
      if (type == null) {
        errors.add(ValidationError(
          path: 'layers[$i].type',
          message: 'Layer type is required',
        ));
      } else if (!LayerTypes.isValid(type)) {
        errors.add(ValidationError(
          path: 'layers[$i].type',
          message: 'Invalid layer type',
          actualValue: type,
          expectedValue: LayerTypes.all,
        ));
      }

      // Validate transform
      _validateTransform(layer['transform'] as JsonMap?, 'layers[$i].transform', errors);

      // Validate props based on type
      final props = layer['props'] as JsonMap?;
      if (type != null && props != null) {
        _validateLayerProps(type, props, 'layers[$i].props', errors);
      }
    }
  }

  void _validateTransform(JsonMap? transform, String path, List<ValidationError> errors) {
    if (transform == null) return;

    // Validate x, y (should be 0-1 for relative positioning)
    final x = transform['x'];
    if (x is num && (x < -1 || x > 2)) {
      errors.add(ValidationError(
        path: '$path.x',
        message: 'X position seems out of normal range',
        actualValue: x,
      ));
    }

    final y = transform['y'];
    if (y is num && (y < -1 || y > 2)) {
      errors.add(ValidationError(
        path: '$path.y',
        message: 'Y position seems out of normal range',
        actualValue: y,
      ));
    }

    // Validate scale
    final scaleX = transform['scale_x'] ?? transform['scale'];
    if (scaleX is num && (scaleX < EditorConstants.minScale || scaleX > EditorConstants.maxScale)) {
      errors.add(ValidationError(
        path: '$path.scale_x',
        message: 'Scale out of range',
        actualValue: scaleX,
        expectedValue: '${EditorConstants.minScale} to ${EditorConstants.maxScale}',
      ));
    }

    // Validate rotation (0-360)
    final rotation = transform['rotation'];
    if (rotation is num && (rotation < -360 || rotation > 360)) {
      errors.add(ValidationError(
        path: '$path.rotation',
        message: 'Rotation should be between -360 and 360',
        actualValue: rotation,
      ));
    }
  }

  void _validateLayerProps(String type, JsonMap props, String path, List<ValidationError> errors) {
    switch (type) {
      case LayerTypes.image:
        if (props['asset_id'] == null) {
          errors.add(ValidationError(
            path: '$path.asset_id',
            message: 'Image layer requires asset_id',
          ));
        }
        break;

      case LayerTypes.text:
        if (props['text'] == null) {
          errors.add(ValidationError(
            path: '$path.text',
            message: 'Text layer requires text content',
          ));
        }
        final fontSize = props['font_size'] ?? props['fontSize'];
        if (fontSize is num) {
          if (fontSize < EditorConstants.minFontSize || fontSize > EditorConstants.maxFontSize) {
            errors.add(ValidationError(
              path: '$path.font_size',
              message: 'Font size out of range',
              actualValue: fontSize,
              expectedValue: '${EditorConstants.minFontSize} to ${EditorConstants.maxFontSize}',
            ));
          }
        }
        break;

      case LayerTypes.svg:
        if (props['asset_id'] == null) {
          errors.add(ValidationError(
            path: '$path.asset_id',
            message: 'SVG layer requires asset_id',
          ));
        }
        break;

      case LayerTypes.shape:
        final shapeType = props['shape_type'];
        if (shapeType != null && !ShapeTypes.all.contains(shapeType)) {
          errors.add(ValidationError(
            path: '$path.shape_type',
            message: 'Invalid shape type',
            actualValue: shapeType,
            expectedValue: ShapeTypes.all,
          ));
        }
        break;
    }
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Get errors as string list
  List<String> get errorMessages => errors.map((e) => e.toString()).toList();

  /// Get formatted error report
  String get errorReport {
    if (isValid) return 'Validation passed';

    final buffer = StringBuffer();
    buffer.writeln('Validation failed with ${errors.length} error(s):');
    for (final error in errors) {
      buffer.writeln('  - $error');
    }
    return buffer.toString();
  }

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: ${errors.length} errors';
}
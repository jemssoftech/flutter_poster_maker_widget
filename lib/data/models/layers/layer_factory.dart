import '../../../core/types/typedefs.dart';
import '../../../core/constants/editor_constants.dart';
import '../../../core/errors/editor_exception.dart';
import 'layer_base.dart';
import 'image_layer.dart';
import 'text_layer.dart';
import 'svg_layer.dart';
import 'shape_layer.dart';

/// Factory class for creating layers from JSON
class LayerFactory {
  LayerFactory._();

  /// Create layer from JSON based on type
  static LayerBase fromJson(JsonMap json) {
    final type = json['type'] as String?;

    if (type == null) {
      throw const JsonParseException(
        message: 'Layer type is required',
        jsonPath: 'layer.type',
      );
    }

    switch (type) {
      case LayerTypes.image:
        return ImageLayer.fromJson(json);
      case LayerTypes.text:
        return TextLayer.fromJson(json);
      case LayerTypes.svg:
        return SvgLayer.fromJson(json);
      case LayerTypes.shape:
        return ShapeLayer.fromJson(json);
      default:
        throw JsonParseException(
          message: 'Unknown layer type: $type',
          jsonPath: 'layer.type',
        );
    }
  }

  /// Create layers list from JSON array
  static List<LayerBase> fromJsonList(List<dynamic>? jsonList) {
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    final layers = <LayerBase>[];

    for (int i = 0; i < jsonList.length; i++) {
      try {
        final layerJson = jsonList[i] as JsonMap;
        layers.add(fromJson(layerJson));
      } catch (e) {
        throw JsonParseException(
          message: 'Failed to parse layer at index $i: $e',
          jsonPath: 'layers[$i]',
        );
      }
    }

    return layers;
  }

  /// Convert layers list to JSON array
  static List<JsonMap> toJsonList(List<LayerBase> layers) {
    return layers.map((layer) => layer.toJson()).toList();
  }

  /// Validate layer JSON structure
  static List<ValidationError> validateLayerJson(JsonMap json) {
    final errors = <ValidationError>[];

    // Check required fields
    if (!json.containsKey('id')) {
      errors.add(const ValidationError(
        path: 'layer.id',
        message: 'Layer ID is required',
      ));
    }

    if (!json.containsKey('type')) {
      errors.add(const ValidationError(
        path: 'layer.type',
        message: 'Layer type is required',
      ));
    } else {
      final type = json['type'] as String?;
      if (type != null && !LayerTypes.isValid(type)) {
        errors.add(ValidationError(
          path: 'layer.type',
          message: 'Invalid layer type: $type',
          actualValue: type,
          expectedValue: LayerTypes.all,
        ));
      }
    }

    // Check transform
    final transform = json['transform'];
    if (transform != null && transform is! Map<String, dynamic>) {
      errors.add(const ValidationError(
        path: 'layer.transform',
        message: 'Transform must be an object',
      ));
    }

    // Check props
    final props = json['props'];
    if (props != null && props is! Map<String, dynamic>) {
      errors.add(const ValidationError(
        path: 'layer.props',
        message: 'Props must be an object',
      ));
    }

    return errors;
  }

  /// Check if JSON represents a valid layer
  static bool isValidLayerJson(JsonMap json) {
    return validateLayerJson(json).isEmpty;
  }
}
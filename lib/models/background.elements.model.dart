// ============================================================================
// 📁 FILE: template_element.dart - ADD BackgroundElement
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_poster_maker/models/template_element.dart';

/// Background Image Presets
class BackgroundPreset {
  final String id;
  final String name;
  final String url;
  final String category;
  final String? thumbnailUrl;

  const BackgroundPreset({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    this.thumbnailUrl,
  });

  factory BackgroundPreset.fromJson(Map<String, dynamic> json) {
    return BackgroundPreset(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? 'general',
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'category': category,
    'thumbnailUrl': thumbnailUrl,
  };
}

/// Static Background Presets (will be replaced by API)
class BackgroundPresets {
  static const List<BackgroundPreset> presets = [
    // Gradients
    BackgroundPreset(
      id: 'gradient_1',
      name: 'Blue Gradient',
      url: 'https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=800',
      category: 'gradients',
    ),
    BackgroundPreset(
      id: 'gradient_2',
      name: 'Purple Gradient',
      url: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
      category: 'gradients',
    ),
    BackgroundPreset(
      id: 'gradient_3',
      name: 'Orange Sunset',
      url: 'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=800',
      category: 'gradients',
    ),

    // Patterns
    BackgroundPreset(
      id: 'pattern_1',
      name: 'Geometric',
      url: 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=800',
      category: 'patterns',
    ),
    BackgroundPreset(
      id: 'pattern_2',
      name: 'Abstract Lines',
      url: 'https://images.unsplash.com/photo-1550684376-efcbd6e3f031?w=800',
      category: 'patterns',
    ),
    BackgroundPreset(
      id: 'pattern_3',
      name: 'Dots Pattern',
      url: 'https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=800',
      category: 'patterns',
    ),

    // Textures
    BackgroundPreset(
      id: 'texture_1',
      name: 'Paper Texture',
      url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      category: 'textures',
    ),
    BackgroundPreset(
      id: 'texture_2',
      name: 'Marble',
      url: 'https://images.unsplash.com/photo-1558618047-f4b511bfe6a5?w=800',
      category: 'textures',
    ),
    BackgroundPreset(
      id: 'texture_3',
      name: 'Wood',
      url: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7e69?w=800',
      category: 'textures',
    ),

    // Minimalist
    BackgroundPreset(
      id: 'minimal_1',
      name: 'White Clean',
      url: 'https://images.unsplash.com/photo-1553095066-5f5c37b70a5c?w=800',
      category: 'minimal',
    ),
    BackgroundPreset(
      id: 'minimal_2',
      name: 'Light Gray',
      url: 'https://images.unsplash.com/photo-1533628635777-112b2239b1c7?w=800',
      category: 'minimal',
    ),

    // Business
    BackgroundPreset(
      id: 'business_1',
      name: 'Corporate Blue',
      url: 'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800',
      category: 'business',
    ),
    BackgroundPreset(
      id: 'business_2',
      name: 'Professional Dark',
      url: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      category: 'business',
    ),
  ];

  static List<String> get categories =>
      presets.map((p) => p.category).toSet().toList();

  static List<BackgroundPreset> getByCategory(String category) =>
      presets.where((p) => p.category == category).toList();
}

/// Background Element
class BackgroundElement extends TemplateElement {
  String? imageUrl;
  Uint8List? imageBytes;
  String? presetId;
  BoxFit fit;
  double imageOpacity;
  Color overlayColor;
  double overlayOpacity;
  BlendMode blendMode;

  // Filters
  double brightness;
  double contrast;
  double saturation;
  double blur;

  // Position adjustments
  Alignment alignment;
  double scale;

  BackgroundElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    this.imageUrl,
    this.imageBytes,
    this.presetId,
    this.fit = BoxFit.cover,
    this.imageOpacity = 1.0,
    this.overlayColor = Colors.transparent,
    this.overlayOpacity = 0.0,
    this.blendMode = BlendMode.srcOver,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.blur = 0.0,
    this.alignment = Alignment.center,
    this.scale = 1.0,
  }) : super(type: ElementType.background);

  factory BackgroundElement.fromJson(Map<String, dynamic> json) {
    return BackgroundElement(
      id: json['id'],
      name: json['name'] ?? 'Background',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 595).toDouble(),
        (json['size']?['height'] ?? 842).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? true,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? -1000, // Always at bottom
      imageUrl: json['imageUrl'],
      imageBytes: json['imageBase64'] != null ? base64Decode(json['imageBase64']) : null,
      presetId: json['presetId'],
      fit: BoxFit.values.firstWhere(
            (f) => f.name == json['fit'],
        orElse: () => BoxFit.cover,
      ),
      imageOpacity: (json['imageOpacity'] ?? 1).toDouble(),
      overlayColor: Color(json['overlayColor'] ?? 0x00000000),
      overlayOpacity: (json['overlayOpacity'] ?? 0).toDouble(),
      blendMode: BlendMode.values.firstWhere(
            (b) => b.name == json['blendMode'],
        orElse: () => BlendMode.srcOver,
      ),
      brightness: (json['brightness'] ?? 0).toDouble(),
      contrast: (json['contrast'] ?? 0).toDouble(),
      saturation: (json['saturation'] ?? 0).toDouble(),
      blur: (json['blur'] ?? 0).toDouble(),
      alignment: _parseAlignment(json['alignment']),
      scale: (json['scale'] ?? 1).toDouble(),
    );
  }

  static Alignment _parseAlignment(String? value) {
    switch (value) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return Alignment.center;
    }
  }

  String _alignmentToString() {
    if (alignment == Alignment.topLeft) return 'topLeft';
    if (alignment == Alignment.topCenter) return 'topCenter';
    if (alignment == Alignment.topRight) return 'topRight';
    if (alignment == Alignment.centerLeft) return 'centerLeft';
    if (alignment == Alignment.center) return 'center';
    if (alignment == Alignment.centerRight) return 'centerRight';
    if (alignment == Alignment.bottomLeft) return 'bottomLeft';
    if (alignment == Alignment.bottomCenter) return 'bottomCenter';
    if (alignment == Alignment.bottomRight) return 'bottomRight';
    return 'center';
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': 'background',
    'position': {'x': position.dx, 'y': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'rotation': rotation,
    'opacity': opacity,
    'isLocked': isLocked,
    'isVisible': isVisible,
    'zIndex': zIndex,
    'imageUrl': imageUrl,
    'imageBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
    'presetId': presetId,
    'fit': fit.name,
    'imageOpacity': imageOpacity,
    'overlayColor': overlayColor.value,
    'overlayOpacity': overlayOpacity,
    'blendMode': blendMode.name,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'blur': blur,
    'alignment': _alignmentToString(),
    'scale': scale,
  };

  @override
  BackgroundElement clone() => BackgroundElement(
    id: '${id}_copy',
    name: '$name Copy',
    position: position,
    size: size,
    rotation: rotation,
    opacity: opacity,
    isLocked: isLocked,
    isVisible: isVisible,
    zIndex: zIndex,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    presetId: presetId,
    fit: fit,
    imageOpacity: imageOpacity,
    overlayColor: overlayColor,
    overlayOpacity: overlayOpacity,
    blendMode: blendMode,
    brightness: brightness,
    contrast: contrast,
    saturation: saturation,
    blur: blur,
    alignment: alignment,
    scale: scale,
  );
}


// ============================================================================
// 📁 FILE: template_element.dart - ENHANCED ImageElement
// ============================================================================

/// Image Filter Preset
enum ImageFilterPreset {
  none('None'),
  grayscale('Grayscale'),
  sepia('Sepia'),
  vintage('Vintage'),
  warm('Warm'),
  cool('Cool'),
  dramatic('Dramatic'),
  fade('Fade'),
  vivid('Vivid');

  final String label;
  const ImageFilterPreset(this.label);
}

/// Image Border Style
class ImageBorderStyle {
  Color color;
  double width;
  BorderStyle style;

  ImageBorderStyle({
    this.color = Colors.transparent,
    this.width = 0,
    this.style = BorderStyle.solid,
  });

  factory ImageBorderStyle.fromJson(Map<String, dynamic> json) {
    return ImageBorderStyle(
      color: Color(json['color'] ?? 0x00000000),
      width: (json['width'] ?? 0).toDouble(),
      style: BorderStyle.values.firstWhere(
            (s) => s.name == json['style'],
        orElse: () => BorderStyle.solid,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'width': width,
    'style': style.name,
  };

  ImageBorderStyle copyWith({
    Color? color,
    double? width,
    BorderStyle? style,
  }) {
    return ImageBorderStyle(
      color: color ?? this.color,
      width: width ?? this.width,
      style: style ?? this.style,
    );
  }
}

/// Image Shadow Style
class ImageShadowStyle {
  Color color;
  double blurRadius;
  double spreadRadius;
  Offset offset;

  ImageShadowStyle({
    this.color = Colors.black26,
    this.blurRadius = 0,
    this.spreadRadius = 0,
    this.offset = Offset.zero,
  });

  factory ImageShadowStyle.fromJson(Map<String, dynamic> json) {
    return ImageShadowStyle(
      color: Color(json['color'] ?? 0x42000000),
      blurRadius: (json['blurRadius'] ?? 0).toDouble(),
      spreadRadius: (json['spreadRadius'] ?? 0).toDouble(),
      offset: Offset(
        (json['offsetX'] ?? 0).toDouble(),
        (json['offsetY'] ?? 0).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'blurRadius': blurRadius,
    'spreadRadius': spreadRadius,
    'offsetX': offset.dx,
    'offsetY': offset.dy,
  };

  ImageShadowStyle copyWith({
    Color? color,
    double? blurRadius,
    double? spreadRadius,
    Offset? offset,
  }) {
    return ImageShadowStyle(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      spreadRadius: spreadRadius ?? this.spreadRadius,
      offset: offset ?? this.offset,
    );
  }

  bool get hasShadow => blurRadius > 0 || spreadRadius > 0;

  BoxShadow toBoxShadow() => BoxShadow(
    color: color,
    blurRadius: blurRadius,
    spreadRadius: spreadRadius,
    offset: offset,
  );
}

/// Enhanced Image Element with full customization
class ImageElement extends TemplateElement {
  String? imageUrl;
  Uint8List? imageBytes;
  BoxFit fit;
  String? placeholderKey;

  // Corner Radius (individual corners)
  double borderRadiusTopLeft;
  double borderRadiusTopRight;
  double borderRadiusBottomLeft;
  double borderRadiusBottomRight;
  bool uniformBorderRadius;

  // Border
  ImageBorderStyle border;

  // Shadow
  ImageShadowStyle shadow;

  // Filters
  ImageFilterPreset filterPreset;
  double brightness;      // -1 to 1
  double contrast;        // -1 to 1
  double saturation;      // -1 to 1
  double hue;             // -1 to 1
  double blur;            // 0 to 20
  double grayscale;       // 0 to 1
  double sepia;           // 0 to 1
  double invert;          // 0 to 1

  // Transform
  bool flipHorizontal;
  bool flipVertical;

  // Mask/Clip
  ShapeType? clipShape;

  // Crop
  Rect? cropRect;

  // Overlay
  Color overlayColor;
  double overlayOpacity;
  BlendMode overlayBlendMode;

  ImageElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    this.imageUrl,
    this.imageBytes,
    this.fit = BoxFit.contain,
    this.placeholderKey,
    // Corner Radius
    this.borderRadiusTopLeft = 0,
    this.borderRadiusTopRight = 0,
    this.borderRadiusBottomLeft = 0,
    this.borderRadiusBottomRight = 0,
    this.uniformBorderRadius = true,
    // Crop
    this.cropRect,
    // Border
    ImageBorderStyle? border,
    // Shadow
    ImageShadowStyle? shadow,
    // Filters
    this.filterPreset = ImageFilterPreset.none,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.hue = 0,
    this.blur = 0,
    this.grayscale = 0,
    this.sepia = 0,
    this.invert = 0,
    // Transform
    this.flipHorizontal = false,
    this.flipVertical = false,
    // Clip
    this.clipShape,
    // Overlay
    this.overlayColor = Colors.transparent,
    this.overlayOpacity = 0,
    this.overlayBlendMode = BlendMode.srcOver,
  })  : border = border ?? ImageBorderStyle(),
        shadow = shadow ?? ImageShadowStyle(),
        super(type: ElementType.image);

  /// Get uniform border radius value
  double get borderRadius => borderRadiusTopLeft;

  /// Set uniform border radius
  set borderRadius(double value) {
    borderRadiusTopLeft = value;
    borderRadiusTopRight = value;
    borderRadiusBottomLeft = value;
    borderRadiusBottomRight = value;
  }

  /// Get BorderRadius object
  BorderRadius getBorderRadius() {
    if (uniformBorderRadius) {
      return BorderRadius.circular(borderRadiusTopLeft);
    }
    return BorderRadius.only(
      topLeft: Radius.circular(borderRadiusTopLeft),
      topRight: Radius.circular(borderRadiusTopRight),
      bottomLeft: Radius.circular(borderRadiusBottomLeft),
      bottomRight: Radius.circular(borderRadiusBottomRight),
    );
  }

  /// Apply filter preset
  void applyFilterPreset(ImageFilterPreset preset) {
    filterPreset = preset;

    // Reset all filters first
    brightness = 0;
    contrast = 0;
    saturation = 0;
    hue = 0;
    grayscale = 0;
    sepia = 0;

    switch (preset) {
      case ImageFilterPreset.none:
        break;
      case ImageFilterPreset.grayscale:
        grayscale = 1;
        break;
      case ImageFilterPreset.sepia:
        sepia = 0.8;
        break;
      case ImageFilterPreset.vintage:
        sepia = 0.4;
        contrast = -0.1;
        brightness = 0.1;
        break;
      case ImageFilterPreset.warm:
        saturation = 0.2;
        hue = 0.05;
        brightness = 0.05;
        break;
      case ImageFilterPreset.cool:
        saturation = 0.1;
        hue = -0.1;
        brightness = 0.05;
        break;
      case ImageFilterPreset.dramatic:
        contrast = 0.3;
        saturation = -0.2;
        brightness = -0.1;
        break;
      case ImageFilterPreset.fade:
        contrast = -0.2;
        brightness = 0.1;
        saturation = -0.3;
        break;
      case ImageFilterPreset.vivid:
        saturation = 0.4;
        contrast = 0.1;
        break;
    }
  }

  /// Get ColorFilter matrix for filters
  ColorFilter? getColorFilter() {
    if (grayscale == 0 && sepia == 0 && brightness == 0 &&
        contrast == 0 && saturation == 0 && invert == 0) {
      return null;
    }

    // Create color matrix
    List<double> matrix = [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

    // Apply grayscale
    if (grayscale > 0) {
      final gs = grayscale;
      final invGs = 1 - gs;
      matrix = _multiplyMatrix(matrix, [
        0.2126 + 0.7874 * invGs, 0.7152 - 0.7152 * invGs, 0.0722 - 0.0722 * invGs, 0, 0,
        0.2126 - 0.2126 * invGs, 0.7152 + 0.2848 * invGs, 0.0722 - 0.0722 * invGs, 0, 0,
        0.2126 - 0.2126 * invGs, 0.7152 - 0.7152 * invGs, 0.0722 + 0.9278 * invGs, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }

    // Apply sepia
    if (sepia > 0) {
      final s = sepia;
      matrix = _multiplyMatrix(matrix, [
        1 - 0.607 * s, 0.769 * s, 0.189 * s, 0, 0,
        0.349 * s, 1 - 0.314 * s, 0.168 * s, 0, 0,
        0.272 * s, 0.534 * s, 1 - 0.869 * s, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }

    // Apply brightness
    if (brightness != 0) {
      final b = brightness * 255;
      matrix = _multiplyMatrix(matrix, [
        1, 0, 0, 0, b,
        0, 1, 0, 0, b,
        0, 0, 1, 0, b,
        0, 0, 0, 1, 0,
      ]);
    }

    // Apply contrast
    if (contrast != 0) {
      final c = contrast + 1;
      final t = (1 - c) / 2 * 255;
      matrix = _multiplyMatrix(matrix, [
        c, 0, 0, 0, t,
        0, c, 0, 0, t,
        0, 0, c, 0, t,
        0, 0, 0, 1, 0,
      ]);
    }

    // Apply saturation
    if (saturation != 0) {
      final s = saturation + 1;
      final sr = (1 - s) * 0.3086;
      final sg = (1 - s) * 0.6094;
      final sb = (1 - s) * 0.0820;
      matrix = _multiplyMatrix(matrix, [
        sr + s, sg, sb, 0, 0,
        sr, sg + s, sb, 0, 0,
        sr, sg, sb + s, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    }

    // Apply invert
    if (invert > 0) {
      final i = invert;
      matrix = _multiplyMatrix(matrix, [
        1 - 2 * i, 0, 0, 0, i * 255,
        0, 1 - 2 * i, 0, 0, i * 255,
        0, 0, 1 - 2 * i, 0, i * 255,
        0, 0, 0, 1, 0,
      ]);
    }

    return ColorFilter.matrix(matrix);
  }

  List<double> _multiplyMatrix(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += a[i * 5 + k] * b[k * 5 + j];
        }
        if (j == 4) {
          sum += a[i * 5 + 4];
        }
        result[i * 5 + j] = sum;
      }
    }
    return result;
  }

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    Rect? cropRect;
    if (json['cropRect'] != null) {
      final cropData = json['cropRect'];
      cropRect = Rect.fromLTWH(
        (cropData['left'] ?? 0.0).toDouble(),
        (cropData['top'] ?? 0.0).toDouble(),
        (cropData['width'] ?? 1.0).toDouble(),
        (cropData['height'] ?? 1.0).toDouble(),
      );
    }

    return ImageElement(
      id: json['id'],
      name: json['name'] ?? 'Image',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']['height'] ?? 100).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      imageUrl: json['imageUrl'],
      imageBytes: json['imageBase64'] != null ? base64Decode(json['imageBase64']) : null,
      fit: BoxFit.values.firstWhere(
            (e) => e.name == json['fit'],
        orElse: () => BoxFit.contain,
      ),
      placeholderKey: json['placeholderKey'],
      // Corner Radius
      borderRadiusTopLeft: (json['borderRadiusTopLeft'] ?? json['borderRadius'] ?? 0).toDouble(),
      borderRadiusTopRight: (json['borderRadiusTopRight'] ?? json['borderRadius'] ?? 0).toDouble(),
      borderRadiusBottomLeft: (json['borderRadiusBottomLeft'] ?? json['borderRadius'] ?? 0).toDouble(),
      borderRadiusBottomRight: (json['borderRadiusBottomRight'] ?? json['borderRadius'] ?? 0).toDouble(),
      uniformBorderRadius: json['uniformBorderRadius'] ?? true,
      // Crop
      cropRect: cropRect,
      // Border
      border: json['border'] != null ? ImageBorderStyle.fromJson(json['border']) : null,
      // Shadow
      shadow: json['shadow'] != null ? ImageShadowStyle.fromJson(json['shadow']) : null,
      // Filters
      filterPreset: ImageFilterPreset.values.firstWhere(
            (f) => f.name == json['filterPreset'],
        orElse: () => ImageFilterPreset.none,
      ),
      brightness: (json['brightness'] ?? 0).toDouble(),
      contrast: (json['contrast'] ?? 0).toDouble(),
      saturation: (json['saturation'] ?? 0).toDouble(),
      hue: (json['hue'] ?? 0).toDouble(),
      blur: (json['blur'] ?? 0).toDouble(),
      grayscale: (json['grayscale'] ?? 0).toDouble(),
      sepia: (json['sepia'] ?? 0).toDouble(),
      invert: (json['invert'] ?? 0).toDouble(),
      // Transform
      flipHorizontal: json['flipHorizontal'] ?? false,
      flipVertical: json['flipVertical'] ?? false,
      // Clip
      clipShape: json['clipShape'] != null
          ? ShapeType.values.firstWhere(
            (s) => s.name == json['clipShape'],
        orElse: () => ShapeType.rectangle,
      )
          : null,
      // Overlay
      overlayColor: Color(json['overlayColor'] ?? 0x00000000),
      overlayOpacity: (json['overlayOpacity'] ?? 0).toDouble(),
      overlayBlendMode: BlendMode.values.firstWhere(
            (b) => b.name == json['overlayBlendMode'],
        orElse: () => BlendMode.srcOver,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'position': {'x': position.dx, 'y': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'rotation': rotation,
    'opacity': opacity,
    'isLocked': isLocked,
    'isVisible': isVisible,
    'zIndex': zIndex,
    'imageUrl': imageUrl,
    'imageBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
    'fit': fit.name,
    'placeholderKey': placeholderKey,
    // Corner Radius
    'borderRadiusTopLeft': borderRadiusTopLeft,
    'borderRadiusTopRight': borderRadiusTopRight,
    'borderRadiusBottomLeft': borderRadiusBottomLeft,
    'borderRadiusBottomRight': borderRadiusBottomRight,
    'uniformBorderRadius': uniformBorderRadius,
    // Crop
    'cropRect': cropRect != null ? {
      'left': cropRect!.left,
      'top': cropRect!.top,
      'width': cropRect!.width,
      'height': cropRect!.height,
    } : null,
    // Border
    'border': border.toJson(),
    // Shadow
    'shadow': shadow.toJson(),
    // Filters
    'filterPreset': filterPreset.name,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'hue': hue,
    'blur': blur,
    'grayscale': grayscale,
    'sepia': sepia,
    'invert': invert,
    // Transform
    'flipHorizontal': flipHorizontal,
    'flipVertical': flipVertical,
    // Clip
    'clipShape': clipShape?.name,
    // Overlay
    'overlayColor': overlayColor.value,
    'overlayOpacity': overlayOpacity,
    'overlayBlendMode': overlayBlendMode.name,
  };

  @override
  ImageElement clone() => ImageElement(
    id: '${id}_copy',
    name: '$name Copy',
    position: position + const Offset(20, 20),
    size: size,
    rotation: rotation,
    opacity: opacity,
    isLocked: false,
    isVisible: isVisible,
    zIndex: zIndex,
    imageUrl: imageUrl,
    imageBytes: imageBytes,
    fit: fit,
    placeholderKey: placeholderKey,
    borderRadiusTopLeft: borderRadiusTopLeft,
    borderRadiusTopRight: borderRadiusTopRight,
    borderRadiusBottomLeft: borderRadiusBottomLeft,
    borderRadiusBottomRight: borderRadiusBottomRight,
    uniformBorderRadius: uniformBorderRadius,
    cropRect: cropRect, // Clone crop rectangle too
    border: border.copyWith(),
    shadow: shadow.copyWith(),
    filterPreset: filterPreset,
    brightness: brightness,
    contrast: contrast,
    saturation: saturation,
    hue: hue,
    blur: blur,
    grayscale: grayscale,
    sepia: sepia,
    invert: invert,
    flipHorizontal: flipHorizontal,
    flipVertical: flipVertical,
    clipShape: clipShape,
    overlayColor: overlayColor,
    overlayOpacity: overlayOpacity,
    overlayBlendMode: overlayBlendMode,
  );
}
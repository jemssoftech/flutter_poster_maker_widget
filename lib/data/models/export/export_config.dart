import '../../../core/types/typedefs.dart';
import '../../../core/utils/json_utils.dart';

/// Export format types
enum ExportFormat {
  png,
  jpeg,
  pdf,
  json,
  svg,
}

/// Extension for ExportFormat
extension ExportFormatExtension on ExportFormat {
  /// Get file extension
  String get extension {
    switch (this) {
      case ExportFormat.png:
        return 'png';
      case ExportFormat.jpeg:
        return 'jpg';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.svg:
        return 'svg';
    }
  }

  /// Get MIME type
  String get mimeType {
    switch (this) {
      case ExportFormat.png:
        return 'image/png';
      case ExportFormat.jpeg:
        return 'image/jpeg';
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.svg:
        return 'image/svg+xml';
    }
  }

  /// Get display name
  String get displayName {
    switch (this) {
      case ExportFormat.png:
        return 'PNG Image';
      case ExportFormat.jpeg:
        return 'JPEG Image';
      case ExportFormat.pdf:
        return 'PDF Document';
      case ExportFormat.json:
        return 'JSON File';
      case ExportFormat.svg:
        return 'SVG Image';
    }
  }

  /// Check if format supports transparency
  bool get supportsTransparency {
    return this == ExportFormat.png || this == ExportFormat.svg;
  }

  /// Check if format is raster
  bool get isRaster {
    return this == ExportFormat.png || this == ExportFormat.jpeg;
  }

  /// Check if format is vector
  bool get isVector {
    return this == ExportFormat.pdf || this == ExportFormat.svg;
  }
}

/// Export configuration
class ExportConfig {
  /// Export format
  final ExportFormat format;

  /// DPI for raster exports
  final int dpi;

  /// JPEG quality (0-100)
  final int quality;

  /// Include background
  final bool includeBackground;

  /// Include bleed area
  final bool includeBleed;

  /// Scale factor (1.0 = original size)
  final double scale;

  /// Custom width (null = use original)
  final int? customWidth;

  /// Custom height (null = use original)
  final int? customHeight;

  /// Flatten layers (for PDF)
  final bool flattenLayers;

  /// Embed fonts (for PDF)
  final bool embedFonts;

  /// Compress output
  final bool compress;

  const ExportConfig({
    this.format = ExportFormat.png,
    this.dpi = 300,
    this.quality = 90,
    this.includeBackground = true,
    this.includeBleed = false,
    this.scale = 1.0,
    this.customWidth,
    this.customHeight,
    this.flattenLayers = true,
    this.embedFonts = true,
    this.compress = true,
  });

  /// Default PNG export
  static const ExportConfig defaultPng = ExportConfig(
    format: ExportFormat.png,
    dpi: 300,
  );

  /// Web-optimized PNG (72 DPI)
  static const ExportConfig webPng = ExportConfig(
    format: ExportFormat.png,
    dpi: 72,
  );

  /// High-res PNG (600 DPI)
  static const ExportConfig printPng = ExportConfig(
    format: ExportFormat.png,
    dpi: 600,
    includeBleed: true,
  );

  /// Default JPEG export
  static const ExportConfig defaultJpeg = ExportConfig(
    format: ExportFormat.jpeg,
    dpi: 300,
    quality: 90,
  );

  /// Default PDF export
  static const ExportConfig defaultPdf = ExportConfig(
    format: ExportFormat.pdf,
    dpi: 300,
    embedFonts: true,
  );

  /// Default JSON export
  static const ExportConfig defaultJson = ExportConfig(
    format: ExportFormat.json,
  );

  /// Calculate output width
  int calculateWidth(double originalWidth) {
    if (customWidth != null) return customWidth!;
    return (originalWidth * scale * (dpi / 72)).round();
  }

  /// Calculate output height
  int calculateHeight(double originalHeight) {
    if (customHeight != null) return customHeight!;
    return (originalHeight * scale * (dpi / 72)).round();
  }

  /// Create from JSON
  factory ExportConfig.fromJson(JsonMap json) {
    return ExportConfig(
      format: JsonUtils.parseEnum(
        json['format'] as String?,
        ExportFormat.values,
      ) ??
          ExportFormat.png,
      dpi: JsonUtils.getValue<int>(json, 'dpi', 300)!,
      quality: JsonUtils.getValue<int>(json, 'quality', 90)!,
      includeBackground: JsonUtils.getValue<bool>(json, 'include_background', true)!,
      includeBleed: JsonUtils.getValue<bool>(json, 'include_bleed', false)!,
      scale: JsonUtils.getValue<double>(json, 'scale', 1.0)!,
      customWidth: JsonUtils.getValue<int>(json, 'custom_width'),
      customHeight: JsonUtils.getValue<int>(json, 'custom_height'),
      flattenLayers: JsonUtils.getValue<bool>(json, 'flatten_layers', true)!,
      embedFonts: JsonUtils.getValue<bool>(json, 'embed_fonts', true)!,
      compress: JsonUtils.getValue<bool>(json, 'compress', true)!,
    );
  }

  /// Convert to JSON
  JsonMap toJson() => {
    'format': format.name,
    'dpi': dpi,
    'quality': quality,
    'include_background': includeBackground,
    'include_bleed': includeBleed,
    'scale': scale,
    if (customWidth != null) 'custom_width': customWidth,
    if (customHeight != null) 'custom_height': customHeight,
    'flatten_layers': flattenLayers,
    'embed_fonts': embedFonts,
    'compress': compress,
  };

  /// Create copy with modifications
  ExportConfig copyWith({
    ExportFormat? format,
    int? dpi,
    int? quality,
    bool? includeBackground,
    bool? includeBleed,
    double? scale,
    int? customWidth,
    int? customHeight,
    bool? flattenLayers,
    bool? embedFonts,
    bool? compress,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      dpi: dpi ?? this.dpi,
      quality: quality ?? this.quality,
      includeBackground: includeBackground ?? this.includeBackground,
      includeBleed: includeBleed ?? this.includeBleed,
      scale: scale ?? this.scale,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      flattenLayers: flattenLayers ?? this.flattenLayers,
      embedFonts: embedFonts ?? this.embedFonts,
      compress: compress ?? this.compress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExportConfig &&
        other.format == format &&
        other.dpi == dpi &&
        other.quality == quality &&
        other.includeBackground == includeBackground;
  }

  @override
  int get hashCode => Object.hash(format, dpi, quality, includeBackground);

  @override
  String toString() => 'ExportConfig(${format.name}, ${dpi}dpi)';
}
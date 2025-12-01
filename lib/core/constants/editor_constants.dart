/// Editor-wide constants
class EditorConstants {
  EditorConstants._();

  // Schema version
  static const String schemaVersion = '1.0.0';
  static const String schemaUrl = 'https://posterapp.dev/schema/v1.json';

  // Default poster dimensions
  static const double defaultPosterWidth = 1080;
  static const double defaultPosterHeight = 1920;

  // Zoom limits
  static const double minZoom = 0.1;
  static const double maxZoom = 5.0;
  static const double defaultZoom = 1.0;
  static const double zoomStep = 0.1;

  // Layer limits
  static const int maxLayers = 100;
  static const int maxUndoHistory = 50;

  // Transform constraints
  static const double minScale = 0.01;
  static const double maxScale = 10.0;
  static const double snapThreshold = 5.0;
  static const double rotationSnapAngle = 15.0;

  // Text constraints
  static const double minFontSize = 6.0;
  static const double maxFontSize = 500.0;
  static const double defaultFontSize = 48.0;
  static const int maxTextLength = 10000;

  // Asset limits
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxSvgSizeBytes = 1 * 1024 * 1024; // 1MB

  // Export settings
  static const List<int> exportDpiOptions = [72, 150, 300, 600];
  static const int defaultExportDpi = 300;

  // UI dimensions
  static const double layersSidebarWidth = 240.0;
  static const double assetsSidebarWidth = 280.0;
  static const double bottomToolbarHeight = 56.0;
  static const double propertyPanelMinHeight = 0.30;
  static const double propertyPanelMaxHeight = 0.45;
  static const double propertyPanelDefaultHeight = 0.35;

  // Animation durations
  static const Duration panelAnimationDuration = Duration(milliseconds: 250);
  static const Duration selectionAnimationDuration = Duration(milliseconds: 150);
}

/// Layer type identifiers
class LayerTypes {
  LayerTypes._();

  static const String image = 'image';
  static const String text = 'text';
  static const String svg = 'svg';
  static const String shape = 'shape';

  static const List<String> all = [image, text, svg, shape];

  static bool isValid(String type) => all.contains(type);
}

/// Blend mode identifiers
class BlendModes {
  BlendModes._();

  static const String normal = 'normal';
  static const String multiply = 'multiply';
  static const String screen = 'screen';
  static const String overlay = 'overlay';
  static const String darken = 'darken';
  static const String lighten = 'lighten';
  static const String colorDodge = 'color_dodge';
  static const String colorBurn = 'color_burn';
  static const String hardLight = 'hard_light';
  static const String softLight = 'soft_light';
  static const String difference = 'difference';
  static const String exclusion = 'exclusion';
  static const String hue = 'hue';
  static const String saturation = 'saturation';
  static const String color = 'color';
  static const String luminosity = 'luminosity';

  static const List<String> all = [
    normal, multiply, screen, overlay, darken, lighten,
    colorDodge, colorBurn, hardLight, softLight,
    difference, exclusion, hue, saturation, color, luminosity,
  ];
}

/// Background type identifiers
class BackgroundTypes {
  BackgroundTypes._();

  static const String solid = 'solid';
  static const String linearGradient = 'linear_gradient';
  static const String radialGradient = 'radial_gradient';
  static const String image = 'image';
  static const String pattern = 'pattern';

  static const List<String> all = [
    solid, linearGradient, radialGradient, image, pattern,
  ];
}

/// Shape type identifiers
class ShapeTypes {
  ShapeTypes._();

  static const String rectangle = 'rectangle';
  static const String circle = 'circle';
  static const String ellipse = 'ellipse';
  static const String triangle = 'triangle';
  static const String polygon = 'polygon';
  static const String star = 'star';
  static const String line = 'line';
  static const String arrow = 'arrow';

  static const List<String> all = [
    rectangle, circle, ellipse, triangle, polygon, star, line, arrow,
  ];
}

/// Text alignment identifiers
class TextAlignments {
  TextAlignments._();

  static const String left = 'left';
  static const String center = 'center';
  static const String right = 'right';
  static const String justify = 'justify';

  static const List<String> all = [left, center, right, justify];
}

/// Asset source identifiers
class AssetSources {
  AssetSources._();

  static const String userUpload = 'user_upload';
  static const String url = 'url';
  static const String googleFonts = 'google_fonts';
  static const String custom = 'custom';
  static const String builtinPack = 'builtin_pack';
}
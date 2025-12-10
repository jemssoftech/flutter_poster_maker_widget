import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_poster_maker/models/background.elements.model.dart';
import 'package:flutter_poster_maker/models/invoice_model.dart';
import 'package:flutter_poster_maker/models/svg_element.dart';

import '../widgets/signature_layer.dart';

/// Element behavior for pagination
enum ElementBehavior {
  /// Appears only on Page 1 (default behavior)
  fixed,
  
  /// Cloned to every generated page (Backgrounds, Theme Decorations)
  repeatAll,
  
  /// The master element that drives pagination (The ItemTable)
  dynamicTable,
  
  /// Cloned to every page where the Table exists (Table borders/decorations)
  repeatWithTable,
  
  /// Pushed to the Last Page immediately after the table ends (Totals, Signature, Signature Decorations)
  flowFooter,
}

/// Base Template Element - Like Layer in Pro Image Editor
abstract class TemplateElement {
  final String id;
  String name;
  Offset position;
  Size size;
  double rotation;
  double opacity;
  bool isLocked;
  bool isVisible;
  int zIndex;
  ElementType type;
  ElementBehavior behavior;

  TemplateElement({
    required this.id,
    required this.name,
    required this.position,
    required this.size,
    this.rotation = 0,
    this.opacity = 1.0,
    this.isLocked = false,
    this.isVisible = true,
    this.zIndex = 0,
    required this.type,
    this.behavior = ElementBehavior.fixed,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson();

  /// Create from JSON
  static TemplateElement fromJson(Map<String, dynamic> json) {
    final type = ElementType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ElementType.text,
    );

    switch (type) {
      case ElementType.text:
        return TextElement.fromJson(json);
      case ElementType.image:
        return ImageElement.fromJson(json);
      case ElementType.table:
        return TableElement.fromJson(json);
      case ElementType.shape:
        return ShapeElement.fromJson(json);
      case ElementType.background:
        return BackgroundElement.fromJson(json);
      case ElementType.qrCode:
        return QrElement.fromJson(json);
      case ElementType.group:
        return GroupElement.fromJson(json);
      case ElementType.signature:
        return SignatureElement.fromJson(json);
      case ElementType.svg:
        return SvgElement.fromJson(json);
      case ElementType.productGrid:
        return ProductGridElement.fromJson(json);
      case ElementType.itemTable:
        return ItemTableElement.fromJson(json);
    }
  }

  /// Parse behavior from JSON
  static ElementBehavior _parseBehavior(String? behaviorStr) {
    if (behaviorStr == null) return ElementBehavior.fixed;
    return ElementBehavior.values.firstWhere(
      (e) => e.name == behaviorStr,
      orElse: () => ElementBehavior.fixed,
    );
  }

  /// Clone element
  TemplateElement clone();

  /// Get bounds
  Rect get bounds => Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

  /// Check if point is inside
  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }
}

enum ElementType {
  text,
  image,
  table,
  shape,
  qrCode,
  // placeholder,
  group,
  signature,
  background,
  svg,
  productGrid,
  itemTable, // NEW: For Smart Invoice Tables
}

class TextShadowStyle {
  Color color;
  double blurRadius;
  Offset offset;

  TextShadowStyle({
    this.color = Colors.black38,
    this.blurRadius = 2,
    this.offset = const Offset(1, 1),
  });

  factory TextShadowStyle.fromJson(Map<String, dynamic> json) {
    return TextShadowStyle(
      color: Color(json['color'] ?? 0x61000000),
      blurRadius: (json['blurRadius'] ?? 2).toDouble(),
      offset: Offset(
        (json['offsetX'] ?? 1).toDouble(),
        (json['offsetY'] ?? 1).toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'color': color.value,
        'blurRadius': blurRadius,
        'offsetX': offset.dx,
        'offsetY': offset.dy,
      };

  Shadow toShadow() => Shadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
      );

  TextShadowStyle copyWith({
    Color? color,
    double? blurRadius,
    Offset? offset,
  }) {
    return TextShadowStyle(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      offset: offset ?? this.offset,
    );
  }
}

/// Text Border/Stroke Style
class TextStrokeStyle {
  Color color;
  double width;

  TextStrokeStyle({
    this.color = Colors.black,
    this.width = 0,
  });

  factory TextStrokeStyle.fromJson(Map<String, dynamic> json) {
    return TextStrokeStyle(
      color: Color(json['color'] ?? 0xFF000000),
      width: (json['width'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'color': color.value,
        'width': width,
      };
}

/// Text Background Style
class TextBackgroundStyle {
  Color color;
  double paddingHorizontal;
  double paddingVertical;
  double borderRadius;
  Color? borderColor;
  double borderWidth;

  TextBackgroundStyle({
    this.color = Colors.transparent,
    this.paddingHorizontal = 0,
    this.paddingVertical = 0,
    this.borderRadius = 0,
    this.borderColor,
    this.borderWidth = 0,
  });

  factory TextBackgroundStyle.fromJson(Map<String, dynamic> json) {
    return TextBackgroundStyle(
      color: Color(json['color'] ?? 0x00000000),
      paddingHorizontal: (json['paddingHorizontal'] ?? 0).toDouble(),
      paddingVertical: (json['paddingVertical'] ?? 0).toDouble(),
      borderRadius: (json['borderRadius'] ?? 0).toDouble(),
      borderColor:
          json['borderColor'] != null ? Color(json['borderColor']) : null,
      borderWidth: (json['borderWidth'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'color': color.value,
        'paddingHorizontal': paddingHorizontal,
        'paddingVertical': paddingVertical,
        'borderRadius': borderRadius,
        'borderColor': borderColor?.value,
        'borderWidth': borderWidth,
      };

  bool get hasBackground => color != Colors.transparent || borderWidth > 0;
}

/// Google Fonts List
class GoogleFontsList {
  static const List<String> fonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
    'Nunito',
    'Ubuntu',
    'Playfair Display',
    'Merriweather',
    'Source Sans Pro',
    'PT Sans',
    'Noto Sans',
    'Oswald',
    'Quicksand',
    'Rubik',
    'Work Sans',
    'Fira Sans',
    'Barlow',
    'Karla',
    'Inter',
    'Manrope',
    'DM Sans',
    'Outfit',
    'Space Grotesk',
    // Hindi/Devanagari fonts
    'Noto Sans Devanagari',
    'Hind',
    'Mukta',
    'Tiro Devanagari Hindi',
    'Martel',
    // Decorative fonts
    'Pacifico',
    'Dancing Script',
    'Lobster',
    'Caveat',
    'Satisfy',
    'Great Vibes',
    'Sacramento',
    // Monospace
    'Roboto Mono',
    'Source Code Pro',
    'Fira Code',
    'JetBrains Mono',
  ];

  static const Map<String, String> fontCategories = {
    'Sans Serif':
        'Roboto,Open Sans,Lato,Montserrat,Poppins,Raleway,Nunito,Ubuntu',
    'Serif': 'Playfair Display,Merriweather,Martel',
    'Display': 'Oswald,Barlow',
    'Handwriting':
        'Pacifico,Dancing Script,Lobster,Caveat,Satisfy,Great Vibes,Sacramento',
    'Monospace': 'Roboto Mono,Source Code Pro,Fira Code,JetBrains Mono',
    'Hindi': 'Noto Sans Devanagari,Hind,Mukta,Tiro Devanagari Hindi',
  };
}

// ============================================================================
// ENHANCED TEXT ELEMENT
// ============================================================================

class TextElement extends TemplateElement {
  String text;
  String fontFamily;
  double fontSize;
  Color textColor;
  FontWeight fontWeight;
  FontStyle fontStyle;
  TextDecoration textDecoration;
  TextAlign textAlign;
  double letterSpacing;
  double wordSpacing;
  double lineHeight;
  TextShadowStyle? shadow;
  TextStrokeStyle? stroke;
  TextBackgroundStyle? background;
  String? placeholderKey;
  bool autoSize;
  double maxWidth;
  String displayFormat; // NEW
  String defaultValue; // NEW

  TextElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    super.behavior,
    required this.text,
    this.fontFamily = 'Roboto',
    this.fontSize = 14,
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
    this.wordSpacing = 0,
    this.lineHeight = 1.2,
    this.shadow,
    this.stroke,
    this.background,
    this.placeholderKey,
    this.autoSize = false,
    this.maxWidth = double.infinity,
    this.displayFormat = '{value}', // NEW
    this.defaultValue = '', // NEW
  }) : super(type: ElementType.text);

  /// Get TextStyle for rendering
  TextStyle get textStyle {
    List<Shadow>? shadows;
    if (shadow != null) {
      shadows = [shadow!.toShadow()];
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: textDecoration,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: lineHeight,
      shadows: shadows,
    );
  }


  /// Get stroke TextStyle (for outlined text effect)
  TextStyle? get strokeStyle {
    if (stroke == null || stroke!.width <= 0) return null;

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: lineHeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke!.width
        ..color = stroke!.color,
    );
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    String text = json['text'] ?? '';
    String? placeholderKey = json['placeholderKey'];

    if (placeholderKey == null && text.startsWith('{{') && text.endsWith('}}')) {
      placeholderKey = text.substring(2, text.length - 2);
    }
    return TextElement(
      id: json['id'] ?? 'text_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'Text',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']?['height'] ?? 30).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      behavior: _parseBehavior(json['behavior']),
      text: text,
      placeholderKey: placeholderKey,
      fontFamily: json['fontFamily'] ?? 'Roboto',
      fontSize: (json['fontSize'] ?? 14).toDouble(),
      textColor: Color(json['textColor'] ?? 0xFF000000),
      fontWeight: FontWeight.values[json['fontWeight'] ?? 3],
      fontStyle: json['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
      textDecoration: _parseTextDecoration(json['textDecoration']),
      textAlign: TextAlign.values.firstWhere(
        (e) => e.name == json['textAlign'],
        orElse: () => TextAlign.left,
      ),
      letterSpacing: (json['letterSpacing'] ?? 0).toDouble(),
      wordSpacing: (json['wordSpacing'] ?? 0).toDouble(),
      lineHeight: (json['lineHeight'] ?? 1.2).toDouble(),
      shadow: json['shadow'] != null
          ? TextShadowStyle.fromJson(json['shadow'])
          : null,
      stroke: json['stroke'] != null
          ? TextStrokeStyle.fromJson(json['stroke'])
          : null,
      background: json['background'] != null
          ? TextBackgroundStyle.fromJson(json['background'])
          : null,
      autoSize: json['autoSize'] ?? false,
      maxWidth: json['maxWidth'] == null
          ? double.infinity
          : (json['maxWidth'] as num).toDouble(),
      displayFormat: json['displayFormat'] ?? '{value}', // NEW
      defaultValue: json['defaultValue'] ?? '', // NEW
    );
  }

  static TextDecoration _parseTextDecoration(String? decoration) {
    switch (decoration) {
      case 'underline':
        return TextDecoration.underline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'overline':
        return TextDecoration.overline;
      default:
        return TextDecoration.none;
    }
  }

  static String _textDecorationToString(TextDecoration decoration) {
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.lineThrough) return 'lineThrough';
    if (decoration == TextDecoration.overline) return 'overline';
    return 'none';
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
        'behavior': behavior.name,
        'text': text,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'textColor': textColor.value,
        'fontWeight': fontWeight.index,
        'fontStyle': fontStyle == FontStyle.italic ? 'italic' : 'normal',
        'textDecoration': _textDecorationToString(textDecoration),
        'textAlign': textAlign.name,
        'letterSpacing': letterSpacing,
        'wordSpacing': wordSpacing,
        'lineHeight': lineHeight,
        'shadow': shadow?.toJson(),
        'stroke': stroke?.toJson(),
        'background': background?.toJson(),
        'placeholderKey': placeholderKey,
        'autoSize': autoSize,
        'maxWidth': maxWidth.isInfinite ? null : maxWidth,
        'displayFormat': displayFormat, // NEW
        'defaultValue': defaultValue, // NEW
      };

  @override
  TextElement clone() => TextElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        behavior: behavior,
        text: text,
        fontFamily: fontFamily,
        fontSize: fontSize,
        textColor: textColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        textDecoration: textDecoration,
        textAlign: textAlign,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        lineHeight: lineHeight,
        shadow: shadow?.copyWith(),
        stroke: stroke != null
            ? TextStrokeStyle(color: stroke!.color, width: stroke!.width)
            : null,
        background: background != null
            ? TextBackgroundStyle(
                color: background!.color,
                paddingHorizontal: background!.paddingHorizontal,
                paddingVertical: background!.paddingVertical,
                borderRadius: background!.borderRadius,
                borderColor: background!.borderColor,
                borderWidth: background!.borderWidth,
              )
            : null,
        placeholderKey: placeholderKey,
        autoSize: autoSize,
        maxWidth: maxWidth,
        displayFormat: displayFormat, // NEW
        defaultValue: defaultValue, // NEW
      );
}

/// Table Element
class TableElement extends TemplateElement {
  int rows;
  int columns;
  List<List<TableCell>> cells;
  TableStyle tableStyle;
  String? dataSourceKey; // e.g., 'invoice.items'
  int? templateRowIndex;
  TableElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    required this.rows,
    required this.columns,
    required this.cells,
    this.tableStyle = const TableStyle(),
    this.dataSourceKey,
    this.templateRowIndex,
  }) : super(type: ElementType.table);

  factory TableElement.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] ?? 3;
    final columns = json['columns'] ?? 3;

    List<List<TableCell>> cells = [];
    if (json['cells'] != null) {
      for (var row in json['cells']) {
        cells.add((row as List).map((c) => TableCell.fromJson(c)).toList());
      }
    } else {
      cells = List.generate(
        rows,
        (r) => List.generate(columns, (c) => TableCell()),
      );
    }

    return TableElement(
      id: json['id'] ?? 'table_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'Table',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 300).toDouble(),
        (json['size']?['height'] ?? 150).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      rows: rows,
      columns: columns,
      cells: cells,
      tableStyle: TableStyle.fromJson(json['tableStyle'] ?? {}),
      dataSourceKey: json['dataSourceKey'],
      templateRowIndex: json['templateRowIndex'],
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
        'rows': rows,
        'columns': columns,
        'cells':
            cells.map((row) => row.map((c) => c.toJson()).toList()).toList(),
        'tableStyle': tableStyle.toJson(),
        'dataSourceKey': dataSourceKey,
        'templateRowIndex': templateRowIndex,
      };

  @override
  TableElement clone() => TableElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        rows: rows,
        columns: columns,
        cells: cells.map((row) => row.map((c) => c.clone()).toList()).toList(),
        tableStyle: tableStyle,
        dataSourceKey: dataSourceKey,
        templateRowIndex: templateRowIndex,
      );
}

class TableCell {
  String content;
  String? placeholderKey;
  TextStyle textStyle;
  TextAlign textAlign;
  Color? backgroundColor;
  int rowSpan;
  int colSpan;

  TableCell({
    this.content = '',
    this.placeholderKey,
    this.textStyle = const TextStyle(fontSize: 12),
    this.textAlign = TextAlign.left,
    this.backgroundColor,
    this.rowSpan = 1,
    this.colSpan = 1,
  });

  factory TableCell.fromJson(Map<String, dynamic> json) {
    return TableCell(
      content: json['content'] ?? '',
      placeholderKey: json['placeholderKey'],
      textAlign: TextAlign.values.firstWhere(
        (e) => e.name == json['textAlign'],
        orElse: () => TextAlign.left,
      ),
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'])
          : null,
      rowSpan: json['rowSpan'] ?? 1,
      colSpan: json['colSpan'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'placeholderKey': placeholderKey,
        'textAlign': textAlign.name,
        'backgroundColor': backgroundColor?.value,
        'rowSpan': rowSpan,
        'colSpan': colSpan,
      };

  TableCell clone() => TableCell(
        content: content,
        placeholderKey: placeholderKey,
        textStyle: textStyle,
        textAlign: textAlign,
        backgroundColor: backgroundColor,
        rowSpan: rowSpan,
        colSpan: colSpan,
      );
}

class TableStyle {
  final Color borderColor;
  final double borderWidth;
  final Color headerBackgroundColor;
  final TextStyle headerTextStyle;
  final double cellPadding;
  final bool showHeader;

  const TableStyle({
    this.borderColor = Colors.black,
    this.borderWidth = 1,
    this.headerBackgroundColor = const Color(0xFFE0E0E0),
    this.headerTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    this.cellPadding = 8,
    this.showHeader = true,
  });

  factory TableStyle.fromJson(Map<String, dynamic> json) {
    return TableStyle(
      borderColor: Color(json['borderColor'] ?? 0xFF000000),
      borderWidth: (json['borderWidth'] ?? 1).toDouble(),
      headerBackgroundColor: Color(json['headerBackgroundColor'] ?? 0xFFE0E0E0),
      cellPadding: (json['cellPadding'] ?? 8).toDouble(),
      showHeader: json['showHeader'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'borderColor': borderColor.value,
        'borderWidth': borderWidth,
        'headerBackgroundColor': headerBackgroundColor.value,
        'cellPadding': cellPadding,
        'showHeader': showHeader,
      };
}

/// Shape Element
class ShapeElement extends TemplateElement {
  ShapeType shapeType;
  Color fillColor;
  Color strokeColor;
  double strokeWidth;
  double cornerRadius;

  // Line-specific properties
  Offset startPoint;
  Offset endPoint;
  double dashLength;
  double dashGap;
  double arrowSize;
  double curvature; // For curved lines

  // Shadow
  bool hasShadow;
  Color shadowColor;
  double shadowBlur;
  Offset shadowOffset;

  ShapeElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    super.behavior,
    required this.shapeType,
    this.fillColor = Colors.transparent,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2,
    this.cornerRadius = 0,
    // Line properties
    Offset? startPoint,
    Offset? endPoint,
    this.dashLength = 10,
    this.dashGap = 5,
    this.arrowSize = 12,
    this.curvature = 0,
    // Shadow
    this.hasShadow = false,
    this.shadowColor = Colors.black38,
    this.shadowBlur = 4,
    this.shadowOffset = const Offset(2, 2),
  })  : startPoint = startPoint ?? Offset.zero,
        endPoint = endPoint ?? Offset(100, 0),
        super(type: ElementType.shape);

  factory ShapeElement.fromJson(Map<String, dynamic> json) {
    return ShapeElement(
      id: json['id'] ?? 'shape_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'Shape',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']?['height'] ?? 100).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      behavior: _parseBehavior(json['behavior']),
      shapeType: ShapeType.values.firstWhere(
        (e) => e.name == json['shapeType'],
        orElse: () => ShapeType.rectangle,
      ),
      fillColor: Color(json['fillColor'] ?? 0x00000000),
      strokeColor: Color(json['strokeColor'] ?? 0xFF000000),
      strokeWidth: (json['strokeWidth'] ?? 2).toDouble(),
      cornerRadius: (json['cornerRadius'] ?? 0).toDouble(),
      startPoint: json['startPoint'] != null
          ? Offset(
              (json['startPoint']?['x'] ?? 0).toDouble(),
              (json['startPoint']?['y'] ?? 0).toDouble(),
            )
          : null,
      endPoint: json['endPoint'] != null
          ? Offset(
              (json['endPoint']?['x'] ?? 100).toDouble(),
              (json['endPoint']?['y'] ?? 0).toDouble(),
            )
          : null,
      dashLength: (json['dashLength'] ?? 10).toDouble(),
      dashGap: (json['dashGap'] ?? 5).toDouble(),
      arrowSize: (json['arrowSize'] ?? 12).toDouble(),
      curvature: (json['curvature'] ?? 0).toDouble(),
      hasShadow: json['hasShadow'] ?? false,
      shadowColor: Color(json['shadowColor'] ?? 0x61000000),
      shadowBlur: (json['shadowBlur'] ?? 4).toDouble(),
      // Helper to parse Shadow Offset safely
      shadowOffset: _parseShadowOffset(json),
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
        'behavior': behavior.name,
        'shapeType': shapeType.name,
        'fillColor': fillColor.value,
        'strokeColor': strokeColor.value,
        'strokeWidth': strokeWidth,
        'cornerRadius': cornerRadius,
        'startPoint': {'x': startPoint.dx, 'y': startPoint.dy},
        'endPoint': {'x': endPoint.dx, 'y': endPoint.dy},
        'dashLength': dashLength,
        'dashGap': dashGap,
        'arrowSize': arrowSize,
        'curvature': curvature,
        'hasShadow': hasShadow,
        'shadowColor': shadowColor.value,
        'shadowBlur': shadowBlur,
        'shadowOffsetX': shadowOffset.dx,
        'shadowOffsetY': shadowOffset.dy,
      };

  @override
  ShapeElement clone() => ShapeElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        behavior: behavior,
        shapeType: shapeType,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        cornerRadius: cornerRadius,
        startPoint: startPoint,
        endPoint: endPoint,
        dashLength: dashLength,
        dashGap: dashGap,
        arrowSize: arrowSize,
        curvature: curvature,
        hasShadow: hasShadow,
        shadowColor: shadowColor,
        shadowBlur: shadowBlur,
        shadowOffset: shadowOffset,
      );
}

/// Helper to parse Shadow Offset safely supporting both formats
Offset _parseShadowOffset(Map<String, dynamic> json) {
  if (json['shadowOffset'] != null) {
    return Offset(
      (json['shadowOffset']['dx'] ?? 2).toDouble(),
      (json['shadowOffset']['dy'] ?? 2).toDouble(),
    );
  }
  return Offset(
    (json['shadowOffsetX'] ?? 2).toDouble(),
    (json['shadowOffsetY'] ?? 2).toDouble(),
  );
}

enum ShapeType {
  // Shapes
  rectangle,
  circle,
  triangle,
  diamond,
  pentagon,
  hexagon,
  star,
  arrow,

  // Lines (merged)
  lineSolid,
  lineDashed,
  lineDotted,
  lineArrow,
  lineDoubleArrow,
  lineCurved,
}

extension ShapeTypeExtension on ShapeType {
  bool get isLine => [
        ShapeType.lineSolid,
        ShapeType.lineDashed,
        ShapeType.lineDotted,
        ShapeType.lineArrow,
        ShapeType.lineDoubleArrow,
        ShapeType.lineCurved,
      ].contains(this);

  String get displayName {
    switch (this) {
      case ShapeType.rectangle:
        return 'Rectangle';
      case ShapeType.circle:
        return 'Circle';
      case ShapeType.triangle:
        return 'Triangle';
      case ShapeType.diamond:
        return 'Diamond';
      case ShapeType.pentagon:
        return 'Pentagon';
      case ShapeType.hexagon:
        return 'Hexagon';
      case ShapeType.star:
        return 'Star';
      case ShapeType.arrow:
        return 'Arrow Shape';
      case ShapeType.lineSolid:
        return 'Solid Line';
      case ShapeType.lineDashed:
        return 'Dashed Line';
      case ShapeType.lineDotted:
        return 'Dotted Line';
      case ShapeType.lineArrow:
        return 'Arrow Line';
      case ShapeType.lineDoubleArrow:
        return 'Double Arrow';
      case ShapeType.lineCurved:
        return 'Curved Line';
    }
  }

  IconData get icon {
    switch (this) {
      case ShapeType.rectangle:
        return Icons.rectangle_outlined;
      case ShapeType.circle:
        return Icons.circle_outlined;
      case ShapeType.triangle:
        return Icons.change_history;
      case ShapeType.diamond:
        return Icons.diamond_outlined;
      case ShapeType.pentagon:
        return Icons.pentagon_outlined;
      case ShapeType.hexagon:
        return Icons.hexagon_outlined;
      case ShapeType.star:
        return Icons.star_outline;
      case ShapeType.arrow:
        return Icons.arrow_forward;
      case ShapeType.lineSolid:
        return Icons.horizontal_rule;
      case ShapeType.lineDashed:
        return Icons.more_horiz;
      case ShapeType.lineDotted:
        return Icons.more_horiz;
      case ShapeType.lineArrow:
        return Icons.arrow_right_alt;
      case ShapeType.lineDoubleArrow:
        return Icons.swap_horiz;
      case ShapeType.lineCurved:
        return Icons.gesture;
    }
  }
}

/// QR Data Type Enum
enum QrDataType {
  placeholder,
  customText,
}

/// QR Placeholder Type Enum
enum QrPlaceholderType {
  paymentQr('payment_qr', 'Payment QR', 'UPI/Payment link QR code'),
  websiteQr('website_qr', 'Website QR', 'Business website URL'),
  invoiceQr('invoice_qr', 'Invoice QR', 'Invoice details QR'),
  contactQr('contact_qr', 'Contact QR', 'Business contact vCard'),
  customPlaceholder('custom', 'Custom Placeholder', 'Custom placeholder key');

  final String key;
  final String label;
  final String description;

  const QrPlaceholderType(this.key, this.label, this.description);
}

// ============================================================================
// QR CODE ELEMENT - UPDATED
// ============================================================================

class QrElement extends TemplateElement {
  QrDataType dataType;
  QrPlaceholderType? placeholderType;
  String? customPlaceholderKey;
  String customText;
  Color foregroundColor;
  Color backgroundColor;

  QrElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    this.dataType = QrDataType.placeholder,
    this.placeholderType = QrPlaceholderType.paymentQr,
    this.customPlaceholderKey,
    this.customText = 'https://example.com',
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  }) : super(type: ElementType.qrCode);

  /// Get the actual data to encode in QR
  String getQrData(InvoiceDocument? invoiceData) {
    if (dataType == QrDataType.customText) {
      return customText;
    }

    // Placeholder mode
    if (invoiceData == null) {
      // Return placeholder display text
      if (placeholderType == QrPlaceholderType.customPlaceholder &&
          customPlaceholderKey != null) {
        return '{{$customPlaceholderKey}}';
      }
      return '{{${placeholderType?.key ?? 'qr_data'}}}';
    }

    // Get actual value from invoice data
    final key = placeholderType == QrPlaceholderType.customPlaceholder
        ? customPlaceholderKey
        : 'invoice.${placeholderType?.key}';

    if (key == null) return customText;

    final json = invoiceData.toJson();
    final value = _getNestedValue(json, key);
    return value?.toString() ?? customText;
  }

  dynamic _getNestedValue(Map<String, dynamic> json, String path) {
    final keys = path.split('.');
    dynamic current = json;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Get placeholder key for display
  String get placeholderKey {
    if (dataType == QrDataType.customText) return '';
    if (placeholderType == QrPlaceholderType.customPlaceholder) {
      return customPlaceholderKey ?? '';
    }
    return 'invoice.${placeholderType?.key ?? ''}';
  }

  factory QrElement.fromJson(Map<String, dynamic> json) {
    return QrElement(
      id: json['id'] ?? 'qr_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'QR Code',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']?['height'] ?? 100).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      dataType: QrDataType.values.firstWhere(
        (e) => e.name == json['dataType'],
        orElse: () => QrDataType.placeholder,
      ),
      placeholderType: json['placeholderType'] != null
          ? QrPlaceholderType.values.firstWhere(
              (e) => e.name == json['placeholderType'],
              orElse: () => QrPlaceholderType.paymentQr,
            )
          : QrPlaceholderType.paymentQr,
      customPlaceholderKey: json['customPlaceholderKey'],
      customText: json['customText'] ?? 'https://example.com',
      foregroundColor: Color(json['foregroundColor'] ?? 0xFF000000),
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
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
        'dataType': dataType.name,
        'placeholderType': placeholderType?.name,
        'customPlaceholderKey': customPlaceholderKey,
        'customText': customText,
        'foregroundColor': foregroundColor.value,
        'backgroundColor': backgroundColor.value,
      };

  @override
  QrElement clone() => QrElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        dataType: dataType,
        placeholderType: placeholderType,
        customPlaceholderKey: customPlaceholderKey,
        customText: customText,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      );
}

/// Group Element
class GroupElement extends TemplateElement {
  List<TemplateElement> children;

  GroupElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    required this.children,
  }) : super(type: ElementType.group);

  factory GroupElement.fromJson(Map<String, dynamic> json) {
    return GroupElement(
      id: json['id'] ?? 'group_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'Group',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']?['height'] ?? 100).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      // ✅ Fix: Support 'elements' key if 'children' is missing
      children: _parseGroupChildren(json),
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
        'children': children.map((c) => c.toJson()).toList(),
      };

  @override
  GroupElement clone() => GroupElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        children: children.map((c) => c.clone()).toList(),
      );
}

/// Helper method to parse group children supporting both 'children' and 'elements' keys
List<TemplateElement> _parseGroupChildren(Map<String, dynamic> json) {
  // ✅ Fix: Support 'elements' key if 'children' is missing
  var childrenList = json['children'] as List?;
  if (childrenList == null && json['elements'] != null) {
    childrenList = json['elements'] as List?;
  }

  return childrenList
          ?.map((c) => TemplateElement.fromJson(c))
          .toList() ??
      [];
}

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

enum InvoiceType { thermal, gst, shipping }

enum PageSize {
  pos58mm('POS-58mm'),
  pos80mm('POS-80mm'),
  a4('A4'),
  a5('A5'),
  letter('Letter');

  final String value;
  const PageSize(this.value);

  static PageSize fromString(String value) {
    return PageSize.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PageSize.a4,
    );
  }
}

class TemplateMeta {
  final String name;
  final PageSize pageSize;
  final InvoiceType invoiceType;
  final String currency;

  TemplateMeta({
    required this.name,
    required this.pageSize,
    required this.invoiceType,
    required this.currency,
  });

  factory TemplateMeta.fromJson(Map<String, dynamic> json) {
    return TemplateMeta(
      name: json['name'] ?? 'Untitled',
      pageSize: PageSize.fromString(json['pageSize'] ?? 'A4'),
      invoiceType: _parseInvoiceType(json['invoiceType']),
      currency: json['currency'] ?? 'INR',
    );
  }

  static InvoiceType _parseInvoiceType(String? type) {
    switch (type?.toLowerCase()) {
      case 'thermal':
        return InvoiceType.thermal;
      case 'gst':
        return InvoiceType.gst;
      case 'shipping':
        return InvoiceType.shipping;
      default:
        return InvoiceType.gst;
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'pageSize': pageSize.value,
        'invoiceType': invoiceType.name,
        'currency': currency,
      };

  bool get isThermal => invoiceType == InvoiceType.thermal;
  bool get isGst => invoiceType == InvoiceType.gst;
  bool get isShipping => invoiceType == InvoiceType.shipping;
}

// ============================================================================
// PRODUCT GRID ELEMENT - For Catalogs, Brochures, and Menu Cards
// ============================================================================

/// Product Grid Element - Displays products in a grid layout
/// The "Magic" element that auto-repeats for catalog products
class ProductGridElement extends TemplateElement {
  /// Number of columns in the grid (e.g., 2 for Menu, 3 for Brochure)
  final int crossAxisCount;

  /// Height/Width ratio of each card (e.g., 1.2 = taller cards, 0.8 = wider cards)
  final double childAspectRatio;

  /// Spacing between columns
  final double crossAxisSpacing;

  /// Spacing between rows
  final double mainAxisSpacing;

  /// The template for a single product card
  /// Contains sub-elements (Text, Image) with placeholders like {{product.name}}
  final List<TemplateElement> cardTemplate;

  /// Optional: Data source key (e.g., 'catalog.categories[0].products')
  final String? dataSourceKey;

  /// Optional: Category filter (if null, shows all products)
  final String? categoryFilter;

  /// Show category header (name + image) above products
  final bool showCategoryHeader;

  /// Category header template (optional, for custom category header design)
  final List<TemplateElement>? categoryHeaderTemplate;

  /// Background color for the grid container
  final Color backgroundColor;

  /// Padding around the entire grid
  final double padding;

  ProductGridElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.8,
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    this.cardTemplate = const [],
    this.dataSourceKey,
    this.categoryFilter,
    this.showCategoryHeader = false,
    this.categoryHeaderTemplate,
    this.backgroundColor = Colors.transparent,
    this.padding = 8.0,
  }) : super(type: ElementType.productGrid);

  factory ProductGridElement.fromJson(Map<String, dynamic> json) {
    // Parse card template elements
    final cardTemplateJson = json['cardTemplate'] as List?;
    final cardTemplate = cardTemplateJson != null
        ? cardTemplateJson
            .map((e) => TemplateElement.fromJson(e as Map<String, dynamic>))
            .toList()
        : <TemplateElement>[];

    return ProductGridElement(
      id: json['id'] ?? 'grid_${DateTime.now().microsecondsSinceEpoch}',
      name: json['name'] ?? 'Product Grid',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 400).toDouble(),
        (json['size']?['height'] ?? 400).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      crossAxisCount: json['crossAxisCount'] ?? 2,
      childAspectRatio: (json['childAspectRatio'] ?? 0.8).toDouble(),
      crossAxisSpacing: (json['crossAxisSpacing'] ?? 12.0).toDouble(),
      mainAxisSpacing: (json['mainAxisSpacing'] ?? 12.0).toDouble(),
      cardTemplate: cardTemplate,
      dataSourceKey: json['dataSourceKey'],
      categoryFilter: json['categoryFilter'],
      showCategoryHeader: json['showCategoryHeader'] ?? false,
      categoryHeaderTemplate: json['categoryHeaderTemplate'] != null
          ? (json['categoryHeaderTemplate'] as List)
              .map((e) => TemplateElement.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'])
          : Colors.transparent,
      padding: (json['padding'] ?? 8.0).toDouble(),
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
        'crossAxisCount': crossAxisCount,
        'childAspectRatio': childAspectRatio,
        'crossAxisSpacing': crossAxisSpacing,
        'mainAxisSpacing': mainAxisSpacing,
        'cardTemplate': cardTemplate.map((e) => e.toJson()).toList(),
        'dataSourceKey': dataSourceKey,
        'categoryFilter': categoryFilter,
        'showCategoryHeader': showCategoryHeader,
        'categoryHeaderTemplate':
            categoryHeaderTemplate?.map((e) => e.toJson()).toList(),
        'backgroundColor': backgroundColor.value,
        'padding': padding,
      };

  @override
  ProductGridElement clone() => ProductGridElement(
        id: '${id}_copy',
        name: '$name Copy',
        position: position + const Offset(20, 20),
        size: size,
        rotation: rotation,
        opacity: opacity,
        isLocked: false,
        isVisible: isVisible,
        zIndex: zIndex,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        cardTemplate: cardTemplate.map((e) => e.clone()).toList(),
        dataSourceKey: dataSourceKey,
        categoryFilter: categoryFilter,
        showCategoryHeader: showCategoryHeader,
        categoryHeaderTemplate:
            categoryHeaderTemplate?.map((e) => e.clone()).toList(),
        backgroundColor: backgroundColor,
        padding: padding,
      );

  /// Calculate how many products can fit in this grid
  int get maxProductsPerPage {
    // Calculate card dimensions
    final gridWidth = size.width - (padding * 2);
    final gridHeight = size.height - (padding * 2);

    final cardWidth = (gridWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;
    final cardHeight = cardWidth / childAspectRatio;

    final rowsPerPage =
        ((gridHeight + mainAxisSpacing) / (cardHeight + mainAxisSpacing))
            .floor();

    return crossAxisCount * rowsPerPage.clamp(1, 100);
  }
}

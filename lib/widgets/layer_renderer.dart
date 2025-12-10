import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_poster_maker/models/background.elements.model.dart';
import 'package:flutter_poster_maker/widgets/signature_layer.dart';
import 'package:flutter_poster_maker/widgets/auto_scale_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/template_element.dart';
import '../models/invoice_model.dart';
import '../models/svg_element.dart';
/// Layer Renderer - Renders different element types
class LayerRenderer extends StatelessWidget {
  final TemplateElement element;
  final InvoiceDocument? invoiceData;

  const LayerRenderer({
    super.key,
    required this.element,
    this.invoiceData,
  });

  @override
  Widget build(BuildContext context) {
    if (element is ItemTableElement) {
      return _buildItemTableLayer(element as ItemTableElement);
    }
    else if (element is BackgroundElement) {
      return _buildBackgroundLayer(element as BackgroundElement);
    }
    switch (element.type) {
      case ElementType.text:
        return _buildTextLayer(element as TextElement);
      case ElementType.table:
        return _buildTableLayer(element as TableElement);
      case ElementType.shape:
        return _buildShapeLayer(element as ShapeElement);
      case ElementType.image:
        return _buildEnhancedImageLayer(element as ImageElement);
      case ElementType.qrCode:
        return _buildQrLayer(element as QrElement);
      case ElementType.group:
        return _buildGroupLayer(element as GroupElement);
      case ElementType.signature:  // ✅ ADD THIS
        return _buildSignatureLayer(element as SignatureElement);
      case ElementType.svg:
        return SvgLayerWidget(element: element as SvgElement);
      case ElementType.productGrid:
        return _buildProductGridLayer(element as ProductGridElement);
      default:
        return const SizedBox();
    }
  }
  Widget _buildItemTableLayer(ItemTableElement element) {
    // Get items from invoice data
    List<Map<String, dynamic>> items = [];

    if (invoiceData != null) {
      final data = _getPlaceholderValue(element.dataSourceKey);
      if (data is List) {
        items = data.map((e) => e as Map<String, dynamic>).toList();
      }
    }

    // If no items and in design mode, show preview
    if (items.isEmpty && invoiceData == null) {
      return _buildItemTablePreview(element);
    }

    // Render actual table
    return _buildItemTableActual(element, items);
  }

  Widget _buildItemTablePreview(ItemTableElement element) {
    final visibleColumns = element.visibleColumns;

    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(element.outerBorderRadius),
        border: element.showOuterBorder
            ? Border.all(
          color: element.outerBorderColor,
          width: element.outerBorderWidth,
        )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(element.outerBorderRadius),
        child: Column(
          children: [
            // Header
            if (element.showHeader) _buildTableHeader(element, visibleColumns),

            // Sample rows
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildSampleRow(element, visibleColumns, index);
                },
              ),
            ),

            // Footer preview
            if (element.showFooter) _buildTableFooterPreview(element),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTableActual(ItemTableElement element, List<Map<String, dynamic>> items) {
    final visibleColumns = element.visibleColumns;

    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(element.outerBorderRadius),
        border: element.showOuterBorder
            ? Border.all(
          color: element.outerBorderColor,
          width: element.outerBorderWidth,
        )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(element.outerBorderRadius),
        child: Column(
          children: [
            // Header
            if (element.showHeader) _buildTableHeader(element, visibleColumns),

            // Items
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildItemRow(element, visibleColumns, items[index], index);
                },
              ),
            ),

            // Footer
            if (element.showFooter) _buildTableFooter(element),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(ItemTableElement element, List<ItemTableColumn> columns) {
    final style = element.headerStyle;

    return Container(
      height: element.rowHeight + 4,
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        boxShadow: style.shadowColor != null
            ? [
          BoxShadow(
            color: style.shadowColor!,
            blurRadius: style.shadowBlur,
            offset: style.shadowOffset,
          ),
        ]
            : null,
      ),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            flex: (col.widthFlex * 10).toInt(),
            child: Container(
              padding: EdgeInsets.symmetric(
                // FIX: Clamp padding to prevent cells becoming only padding when table is small
                horizontal: style.paddingHorizontal.clamp(2.0, 20.0),
                vertical: style.paddingVertical.clamp(1.0, 10.0),
              ),
              decoration: BoxDecoration(
                border: element.showVerticalBorders
                    ? Border(
                  right: BorderSide(
                    color: style.borderColor,
                    width: style.borderWidth,
                  ),
                )
                    : null,
              ),
              child: FittedBox(
                // FIX: Wrap cell text in FittedBox to ensure text shrinks to fit narrow columns on mobile
                fit: BoxFit.scaleDown,
                alignment: _getAlignmentFromTextAlign(col.alignment),
                child: Text(
                  col.title,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: style.fontSize,
                    fontWeight: style.fontWeight,
                    fontFamily: style.fontFamily,
                  ),
                  textAlign: col.alignment,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSampleRow(ItemTableElement element, List<ItemTableColumn> columns, int index) {
    final style = element.itemsStyle;
    final isAlternate = element.alternateRowColors && index.isOdd;

    return Container(
      height: element.rowHeight,
      decoration: BoxDecoration(
        color: isAlternate ? element.alternateRowColor : style.backgroundColor,
        border: element.showHorizontalBorders
            ? Border(
          bottom: BorderSide(
            color: style.borderColor,
            width: style.borderWidth,
          ),
        )
            : null,
      ),
      child: Row(
        children: columns.map((col) {
          String sampleValue = '{{${col.key}}}';
          if (col.key == 'sr') sampleValue = '${index + 1}';

          return Expanded(
            flex: (col.widthFlex * 10).toInt(),
            child: Container(
              padding: EdgeInsets.symmetric(
                // FIX: Clamp padding to prevent cells becoming only padding when table is small
                horizontal: style.paddingHorizontal.clamp(2.0, 20.0),
                vertical: style.paddingVertical.clamp(1.0, 10.0),
              ),
              decoration: BoxDecoration(
                border: element.showVerticalBorders
                    ? Border(
                  right: BorderSide(
                    color: style.borderColor,
                    width: style.borderWidth,
                  ),
                )
                    : null,
              ),
              child: FittedBox(
                // FIX: Wrap cell text in FittedBox to ensure text shrinks to fit narrow columns on mobile
                fit: BoxFit.scaleDown,
                alignment: _getAlignmentFromTextAlign(col.alignment),
                child: Text(
                  sampleValue,
                  style: TextStyle(
                    color: style.textColor.withOpacity(0.6),
                    fontSize: style.fontSize,
                    fontWeight: style.fontWeight,
                    fontFamily: style.fontFamily,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: col.alignment,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemRow(ItemTableElement element, List<ItemTableColumn> columns, Map<String, dynamic> item, int index) {
    final style = element.itemsStyle;
    final isAlternate = element.alternateRowColors && index.isOdd;

    return Container(
      height: element.rowHeight,
      decoration: BoxDecoration(
        color: isAlternate ? element.alternateRowColor : style.backgroundColor,
        border: element.showHorizontalBorders
            ? Border(
          bottom: BorderSide(
            color: style.borderColor,
            width: style.borderWidth,
          ),
        )
            : null,
      ),
      child: Row(
        children: columns.map((col) {
          String value = '';
          if (col.key == 'sr') {
            value = '${index + 1}';
          } else {
            final rawValue = item[col.key];
            if (rawValue != null) {
              value = '${col.prefix ?? ''}$rawValue${col.suffix ?? ''}';
            }
          }

          return Expanded(
            flex: (col.widthFlex * 10).toInt(),
            child: Container(
              padding: EdgeInsets.symmetric(
                // FIX: Clamp padding to prevent cells becoming only padding when table is small
                horizontal: style.paddingHorizontal.clamp(2.0, 20.0),
                vertical: style.paddingVertical.clamp(1.0, 10.0),
              ),
              decoration: BoxDecoration(
                border: element.showVerticalBorders
                    ? Border(
                  right: BorderSide(
                    color: style.borderColor,
                    width: style.borderWidth,
                  ),
                )
                    : null,
              ),
              child: FittedBox(
                // FIX: Wrap cell text in FittedBox to ensure text shrinks to fit narrow columns on mobile
                fit: BoxFit.scaleDown,
                alignment: _getAlignmentFromTextAlign(col.alignment),
                child: Text(
                  value,
                  style: TextStyle(
                    color: style.textColor,
                    fontSize: style.fontSize,
                    fontWeight: style.fontWeight,
                    fontFamily: style.fontFamily,
                  ),
                  textAlign: col.alignment,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableFooterPreview(ItemTableElement element) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: element.footerStyle.backgroundColor,
        border: Border(
          top: BorderSide(
            color: element.footerStyle.borderColor,
            width: element.footerStyle.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: element.footerRows.take(2).map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row.label,
                  style: TextStyle(
                    color: element.footerStyle.textColor.withOpacity(0.7),
                    fontSize: element.footerStyle.fontSize - 1,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  '{{${row.valueKey.split('.').last}}}',
                  style: TextStyle(
                    color: element.footerStyle.textColor.withOpacity(0.7),
                    fontSize: element.footerStyle.fontSize - 1,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableFooter(ItemTableElement element) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: element.footerStyle.paddingVertical,
        horizontal: element.footerStyle.paddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: element.footerStyle.backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(element.outerBorderRadius),
          bottomRight: Radius.circular(element.outerBorderRadius),
        ),
        border: Border(
          top: BorderSide(
            color: element.footerStyle.borderColor,
            width: element.footerStyle.borderWidth,
          ),
        ),
      ),
      child: Column(
        children: element.footerRows.map((row) {
          final value = invoiceData != null ? _getPlaceholderValue(row.valueKey) : null;
          final displayValue = value != null ? '${row.prefix ?? ''}$value${row.suffix ?? ''}' : '---';

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: row.isHighlighted
                ? BoxDecoration(
              color: row.highlightColor?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row.label,
                  style: TextStyle(
                    color: row.isHighlighted ? row.highlightColor : element.footerStyle.textColor,
                    fontSize: element.footerStyle.fontSize,
                    fontWeight: row.isBold ? FontWeight.bold : element.footerStyle.fontWeight,
                  ),
                ),
                Text(
                  displayValue,
                  style: TextStyle(
                    color: row.isHighlighted ? row.highlightColor : element.footerStyle.textColor,
                    fontSize: element.footerStyle.fontSize,
                    fontWeight: row.isBold ? FontWeight.bold : element.footerStyle.fontWeight,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextLayer(TextElement element) {
    String displayText = element.text;
    TextStyle style;
    TextStyle? strokeStyle;
    
    try {
      style = GoogleFonts.getFont(
        element.fontFamily,
        fontSize: element.fontSize,
        color: element.textColor,
        fontWeight: element.fontWeight,
        fontStyle: element.fontStyle,
        decoration: element.textDecoration,
        letterSpacing: element.letterSpacing,
        wordSpacing: element.wordSpacing,
        height: element.lineHeight,
        shadows: element.shadow != null ? [element.shadow!.toShadow()] : null,
      );
    } catch (e) {
      // Fallback if font not found
      style = TextStyle(
        fontFamily: element.fontFamily,
        fontSize: element.fontSize,
        color: element.textColor,
        fontWeight: element.fontWeight,
      );
    }
    
    if (element.placeholderKey != null && element.placeholderKey!.isNotEmpty) {
      if (invoiceData != null) {
        // Runtime Mode: Fetch real value
        final value = _getPlaceholderValue(element.placeholderKey!);
        if (value != null) {
          // Apply Format
          displayText = element.displayFormat.replaceAll('{value}', value.toString());
        } else {
          // HIDE ELEMENT: If data missing, return empty sized box to hide the element
          return const SizedBox.shrink();
        }
      } else {
        // Design Mode: Show Default Value or formatted placeholder
        displayText = element.defaultValue.isNotEmpty
            ? element.defaultValue
            : '{{${element.placeholderKey}}}';
      }
    }

    // Check if stroke is needed
    if (element.stroke != null && element.stroke!.width > 0) {
      try {
        strokeStyle = GoogleFonts.getFont(
          element.fontFamily,
          fontSize: element.fontSize,
          fontWeight: element.fontWeight,
          fontStyle: element.fontStyle,
          letterSpacing: element.letterSpacing,
          wordSpacing: element.wordSpacing,
          height: element.lineHeight,
        ).copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = element.stroke!.width
            ..color = element.stroke!.color,
        );
      } catch (e) {
        // Fallback if font not found
        strokeStyle = TextStyle(
          fontFamily: element.fontFamily,
          fontSize: element.fontSize,
          fontWeight: element.fontWeight,
          fontStyle: element.fontStyle,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = element.stroke!.width
            ..color = element.stroke!.color,
        );
      }
    }

    // Create text widget based on autoSize setting
    Widget textWidget;

    if (element.autoSize) {
      // Case 1: Auto-size enabled - use AutoScaleTextWithStroke
      // FIX: ZERO PADDING - text must fill the entire bounds
      textWidget = AutoScaleTextWithStroke(
        text: displayText,
        style: style,
        strokeStyle: strokeStyle,
        textAlign: element.textAlign,
        maxLines: null, // Support multiline
        minFontSize: 8.0,
        maxFontSize: 500.0,
        scaleFactor: 1.0,
        padding: EdgeInsets.zero, // CRITICAL: Zero padding for tight fit
      );
    } else {
      // Case 2: Auto-size disabled - use AutoScaleTextWithStroke to ensure text fits in bounds
      // Even when autoSize is false, we still need the text to fit the container
      // but limit the maximum size to the original font size
      final maxFontSize = element.fontSize;
      textWidget = AutoScaleTextWithStroke(
        text: displayText,
        style: style,
        strokeStyle: strokeStyle,
        textAlign: element.textAlign,
        maxLines: null, // Support multiline
        minFontSize: 8.0,
        maxFontSize: maxFontSize,
        scaleFactor: 1.0,
        padding: EdgeInsets.zero, // CRITICAL: Zero padding for tight fit
      );
    }

    // Wrap with background if needed (background adds its own padding)
    if (element.background != null && element.background!.hasBackground) {
      textWidget = Container(
        padding: EdgeInsets.symmetric(
          horizontal: element.background!.paddingHorizontal,
          vertical: element.background!.paddingVertical,
        ),
        decoration: BoxDecoration(
          color: element.background!.color,
          borderRadius: BorderRadius.circular(element.background!.borderRadius),
          border: element.background!.borderWidth > 0
              ? Border.all(
            color: element.background!.borderColor ?? Colors.transparent,
            width: element.background!.borderWidth,
          )
              : null,
        ),
        child: textWidget,
      );
    }

    // FIX: Return SizedBox with EXACT dimensions, NO ClipRect to avoid clipping text
    // The text should be fully visible and touch the borders
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: textWidget, // REMOVED ClipRect - no clipping, text is visible
    );
  }

  Alignment _getAlignmentFromTextAlign(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.justify:
        return Alignment.centerLeft;
    }
  }


  Widget _buildBackgroundLayer(BackgroundElement element) {
    Widget? imageWidget;

    // Get image source
    if (element.imageBytes != null) {
      imageWidget = Image.memory(
        element.imageBytes!,
        fit: element.fit,
        width: element.size.width,
        height: element.size.height,
      );
    } else if (element.imageUrl != null) {
      imageWidget = Image.network(
        element.imageUrl!,
        fit: element.fit,
        width: element.size.width,
        height: element.size.height,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      );
    } else if (element.presetId != null) {
      final preset = BackgroundPresets.presets.firstWhere(
            (p) => p.id == element.presetId,
        orElse: () => BackgroundPresets.presets.first,
      );
      imageWidget = Image.network(
        preset.url,
        fit: element.fit,
        width: element.size.width,
        height: element.size.height,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
      );
    }

    if (imageWidget == null) {
      return SizedBox(
        width: element.size.width,
        height: element.size.height,
      );
    }

    // Apply transformations
    Widget result = Transform.scale(
      scale: element.scale,
      alignment: element.alignment,
      child: imageWidget,
    );

    // Apply blur
    if (element.blur > 0) {
      result = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: element.blur,
          sigmaY: element.blur,
        ),
        child: result,
      );
    }

    // Apply color filters
    if (element.brightness != 0 || element.contrast != 0 || element.saturation != 0) {
      result = ColorFiltered(
        colorFilter: _createBackgroundColorFilter(element),
        child: result,
      );
    }

    // Apply opacity
    result = Opacity(
      opacity: element.imageOpacity,
      child: result,
    );

    // Apply overlay
    if (element.overlayOpacity > 0) {
      result = Stack(
        children: [
          result,
          Positioned.fill(
            child: Container(
              color: element.overlayColor.withOpacity(element.overlayOpacity),
            ),
          ),
        ],
      );
    }

    return IgnorePointer(
      child: ClipRect(
        child: SizedBox(
          width: element.size.width,
          height: element.size.height,
          child: result,
        ),
      ),
    );
  }

  ColorFilter _createBackgroundColorFilter(BackgroundElement element) {
    List<double> matrix = [
      1, 0, 0, 0, element.brightness * 255,
      0, 1, 0, 0, element.brightness * 255,
      0, 0, 1, 0, element.brightness * 255,
      0, 0, 0, 1, 0,
    ];

    // Apply contrast
    if (element.contrast != 0) {
      final c = element.contrast + 1;
      final t = (1 - c) / 2 * 255;
      matrix = [
        c, 0, 0, 0, t + element.brightness * 255,
        0, c, 0, 0, t + element.brightness * 255,
        0, 0, c, 0, t + element.brightness * 255,
        0, 0, 0, 1, 0,
      ];
    }

    return ColorFilter.matrix(matrix);
  }

  // ==================== ENHANCED SHAPE LAYER (with lines) ====================
  Widget _buildShapeLayer(ShapeElement element) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: CustomPaint(
        painter: EnhancedShapePainter(
          shapeType: element.shapeType,
          fillColor: element.fillColor,
          strokeColor: element.strokeColor,
          strokeWidth: element.strokeWidth,
          cornerRadius: element.cornerRadius,
          startPoint: element.startPoint,
          endPoint: element.endPoint,
          dashLength: element.dashLength,
          dashGap: element.dashGap,
          arrowSize: element.arrowSize,
          curvature: element.curvature,
          hasShadow: element.hasShadow,
          shadowColor: element.shadowColor,
          shadowBlur: element.shadowBlur,
          shadowOffset: element.shadowOffset,
        ),
      ),
    );
  }

  // ==================== ENHANCED IMAGE LAYER ====================
  Widget _buildEnhancedImageLayer(ImageElement element) {
    Widget? imageWidget;

    // Get image source
    if (element.imageBytes != null) {
      imageWidget = Image.memory(element.imageBytes!, fit: element.fit);
    } else if (element.imageUrl != null) {
      imageWidget = Image.network(
        element.imageUrl!,
        fit: element.fit,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
      );
    } else if (element.placeholderKey != null && invoiceData != null) {
      final value = _getPlaceholderValue(element.placeholderKey!);
      final url = value?.toString();
      if (url != null && url.isNotEmpty) {
        imageWidget = Image.network(
          url,
          fit: element.fit,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        );
      }
    }

    if (imageWidget == null) {
      imageWidget = _buildImagePlaceholder();
    }

    // Apply flip transforms
    if (element.flipHorizontal || element.flipVertical) {
      imageWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            element.flipHorizontal ? -1.0 : 1.0,
            element.flipVertical ? -1.0 : 1.0,
          ),
        child: imageWidget,
      );
    }

    // Apply color filter
    final colorFilter = element.getColorFilter();
    if (colorFilter != null) {
      imageWidget = ColorFiltered(
        colorFilter: colorFilter,
        child: imageWidget,
      );
    }

    // Apply blur
    if (element.blur > 0) {
      imageWidget = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: element.blur,
          sigmaY: element.blur,
        ),
        child: imageWidget,
      );
    }

    // Apply clip shape
    if (element.clipShape != null) {
      imageWidget = ClipPath(
        clipper: _ShapeClipper(element.clipShape!, element.size),
        child: imageWidget,
      );
    }

    // Apply crop if cropRect is specified
    if (element.cropRect != null) {
      final cropRect = element.cropRect!;
      // Convert normalized values (0.0 to 1.0) to actual pixel coordinates
      final pixelCropRect = Rect.fromLTRB(
        cropRect.left * element.size.width,
        cropRect.top * element.size.height,
        cropRect.right * element.size.width,
        cropRect.bottom * element.size.height,
      );

      imageWidget = ClipRect(
        clipper: _CropRectClipper(
          cropRect: pixelCropRect,
          elementSize: element.size,
        ),
        child: Container(
          width: element.size.width,
          height: element.size.height,
          child: imageWidget,
        ),
      );
    }

    // Build container with border radius, border, and shadow
    Widget container = Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        borderRadius: element.getBorderRadius(),
        border: element.border.width > 0
            ? Border.all(
          color: element.border.color,
          width: element.border.width,
          style: element.border.style,
        )
            : null,
        boxShadow: element.shadow.hasShadow
            ? [element.shadow.toBoxShadow()]
            : null,
      ),
      child: ClipRRect(
        borderRadius: element.getBorderRadius(),
        child: imageWidget,
      ),
    );

    // Apply overlay
    if (element.overlayOpacity > 0) {
      container = Stack(
        children: [
          container,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: element.getBorderRadius(),
                color: element.overlayColor.withOpacity(element.overlayOpacity),
              ),
            ),
          ),
        ],
      );
    }

    return container;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }

  dynamic _getPlaceholderValue(String key) {
    if (invoiceData == null) return null;
    final json = invoiceData!.toJson();
    final keys = key.split('.');
    dynamic current = json;
    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null; // Return null if key path doesn't exist - element will be hidden
      }
    }
    return current;
  }



  Widget _buildTableLayer(TableElement element) {
    List<List<TableCell>> displayCells = element.cells;

    // Check if it's a dynamic table (has dataSource and a template row)
    if (element.dataSourceKey != null &&
        element.templateRowIndex != null &&
        invoiceData != null) {
      displayCells = _buildDynamicTableCells(element);
    } else if (element.dataSourceKey != null && invoiceData != null) {
      // Fallback to old logic if no template row specified
      displayCells = _buildDataBoundCells(element);
    }

    // FIX: Use Transform to ensure border width is NOT scaled
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Table(
        border: TableBorder.all(
          color: element.tableStyle.borderColor,
          // Border width should remain constant, not scale with element
          width: element.tableStyle.borderWidth,
        ),
        // Use column widths if you add support for them in TableElement
        // defaultColumnWidth: const FlexColumnWidth(1.0),
        children: displayCells.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final row = entry.value;
          // Logic to style header separately if needed
          final isHeader = rowIndex == 0 && element.tableStyle.showHeader;

          return TableRow(
            decoration: isHeader
                ? BoxDecoration(color: element.tableStyle.headerBackgroundColor)
                : null,
            children: row.map((cell) {
              String displayContent = cell.content;

              // Handle cell-level placeholders (e.g., {{invoice.date}})
              if (cell.placeholderKey != null && invoiceData != null) {
                final val = _getPlaceholderValue(cell.placeholderKey!);
                if (val != null) displayContent = val.toString();
              }

              return Container(
                padding: EdgeInsets.all(
                  // FIX: Clamp padding to ensure cells don't become only padding when table is shrunk
                  element.tableStyle.cellPadding.clamp(2.0, 20.0),
                ),
                color: cell.backgroundColor,
                child: FittedBox(
                  // FIX: Wrap cell text in FittedBox to ensure text shrinks to fit narrow columns on mobile
                  fit: BoxFit.scaleDown,
                  alignment: _getAlignmentFromTextAlign(cell.textAlign),
                  child: Text(
                    displayContent,
                    style: isHeader ? element.tableStyle.headerTextStyle : cell.textStyle,
                    textAlign: cell.textAlign,
                    overflow: TextOverflow.visible,
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
  List<List<TableCell>> _buildDynamicTableCells(TableElement element) {
    final data = _getPlaceholderValue(element.dataSourceKey!);
    if (data is! List) return element.cells;

    List<List<TableCell>> finalRows = [];
    int templateIndex = element.templateRowIndex!;

    // 1. Add rows BEFORE the template row (Headers/Title)
    for (int i = 0; i < templateIndex; i++) {
      if (i < element.cells.length) finalRows.add(element.cells[i]);
    }

    // 2. Generate Item Rows
    final templateRow = element.cells[templateIndex];

    for (int i = 0; i < data.length; i++) {
      final itemData = data[i]; // The item map

      // Create a new row based on the template
      List<TableCell> newRow = templateRow.map((templateCell) {
        String content = templateCell.content;

        // Replace {{item.field}} placeholders
        // We use a regex to find {{...}} patterns
        content = content.replaceAllMapped(RegExp(r'\{\{([^}]+)\}\}'), (match) {
          String key = match.group(1)!.trim();
          // Remove 'item.' prefix if present to match map keys
          if (key.startsWith('item.')) key = key.substring(5);

          if (itemData is Map && itemData.containsKey(key)) {
            return itemData[key].toString();
          }
          // Special keys
          if (key == 'sr' || key == 'index') return '${i + 1}';

          return match.group(0)!; // Return original if not found
        });

        return templateCell.clone()..content = content;
      }).toList();

      finalRows.add(newRow);
    }

    // 3. Add rows AFTER the template row (Footer/Totals)
    // Be careful not to add the template row itself again if it was the last one
    for (int i = templateIndex + 1; i < element.cells.length; i++) {
      finalRows.add(element.cells[i]);
    }

    return finalRows;
  }
  List<List<TableCell>> _buildDataBoundCells(TableElement element) {
    // Get data from invoice (e.g., invoice.items)
    final data = _getPlaceholderValue(element.dataSourceKey!);

    // Check if data is a List
    if (data == null) return element.cells;

    // Parse data as List if it's a string representation or actual list
    List<dynamic>? dataList;

    if (data is List) {
      dataList = data;
    } else if (data is String) {
      // If data is a string, it's not iterable - return original cells
      return element.cells;
    } else {
      return element.cells;
    }

    final headers = element.cells.isNotEmpty ? element.cells[0] : <TableCell>[];
    final cells = <List<TableCell>>[headers];

    for (final item in dataList) {
      if (item is Map<String, dynamic>) {
        final row = headers.map((header) {
          final key = header.placeholderKey?.split('.').last ?? '';
          return TableCell(
            content: item[key]?.toString() ?? '',
            textAlign: header.textAlign,
          );
        }).toList();
        cells.add(row);
      }
    }

    return cells;
  }



  Widget _buildSignatureLayer(SignatureElement element) {
    // Check if signature image exists
    if (element.signatureImage != null) {
      return SizedBox(
        width: element.size.width,
        height: element.size.height,
        child: Image.memory(
          element.signatureImage!,
          fit: BoxFit.contain,
        ),
      );
    }

    // Check placeholder key for invoice data
    if (element.placeholderKey != null && invoiceData != null) {
      final value = _getPlaceholderValue(element.placeholderKey!);
      if (value != null && value is String && value.isNotEmpty) {
        // If it's a URL, load from network
        return SizedBox(
          width: element.size.width,
          height: element.size.height,
          child: Image.network(
            value,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildSignaturePlaceholder(),
          ),
        );
      }
    }

    // Show placeholder
    return _buildSignaturePlaceholder();
  }

  Widget _buildSignaturePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.draw, color: Colors.grey.shade500),
          const SizedBox(height: 4),
          Text(
            'Signature',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildQrLayer(QrElement element) {
    String qrData = element.getQrData(invoiceData);

    // If in design mode (no invoice data) and using placeholder
    final isDesignMode = invoiceData == null && element.dataType == QrDataType.placeholder;

    if (qrData.isEmpty) {
      return _buildQrPlaceholder(element, 'No QR Data');
    }

    // In design mode, show placeholder indicator
    if (isDesignMode) {
      return _buildQrDesignPreview(element, qrData);
    }

    // Render actual QR code
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        backgroundColor: element.backgroundColor,
        eyeStyle: QrEyeStyle(color: element.foregroundColor),
        dataModuleStyle: QrDataModuleStyle(color: element.foregroundColor),
      ),
    );
  }

  Widget _buildQrPlaceholder(QrElement element, String message) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, color: Colors.grey.shade500, size: 32),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildQrDesignPreview(QrElement element, String placeholderText) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        color: element.backgroundColor,
        border: Border.all(color: Colors.teal.shade300, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // QR pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: _QrPatternPainter(color: element.foregroundColor.withOpacity(0.3)),
            ),
          ),

          // Placeholder label
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code, color: Colors.teal.shade700, size: 20),
                    const SizedBox(height: 2),
                    Text(
                      placeholderText,
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGroupLayer(GroupElement element) {
    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: Stack(
        children: element.children.map((child) {
          return Positioned(
            left: child.position.dx,
            top: child.position.dy,
            child: LayerRenderer(
              element: child,
              invoiceData: invoiceData,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGridLayer(ProductGridElement element) {
    // Get products from catalog data
    List<Map<String, dynamic>> products = [];

    if (invoiceData != null && invoiceData!.catalog != null) {
      // Runtime mode - get actual products
      if (element.dataSourceKey != null) {
        final data = _getPlaceholderValue(element.dataSourceKey!);
        if (data is List) {
          products = data.map((e) => e as Map<String, dynamic>).toList();
        }
      } else {
        // Get all products from catalog
        for (var category in invoiceData!.catalog!.categories) {
          if (element.categoryFilter == null || category.name == element.categoryFilter) {
            for (var product in category.products) {
              products.add(product.toJson());
            }
          }
        }
      }
    }

    // If no products and in design mode, show preview
    if (products.isEmpty && invoiceData == null) {
      return _buildProductGridPreview(element);
    }

    // If still no products, show empty state
    if (products.isEmpty) {
      return _buildProductGridEmpty(element);
    }

    // Render actual product grid
    return _buildProductGridActual(element, products);
  }

  Widget _buildProductGridPreview(ProductGridElement element) {
    // Generate mock products for preview
    final mockProducts = List.generate(
      element.maxProductsPerPage.clamp(1, 6),
      (index) => {
        'name': 'Product ${index + 1}',
        'price': ((index + 1) * 100).toDouble(),
        'image': null,
        'description': 'Description',
        'code': 'P00${index + 1}',
      },
    );

    return _buildProductGridPreviewWithHeader(element, mockProducts);
  }

  Widget _buildProductGridPreviewWithHeader(ProductGridElement element, List<Map<String, dynamic>> mockProducts) {
    // Calculate grid dimensions
    final gridWidth = element.size.width - (element.padding * 2);
    final cardWidth = (gridWidth - (element.crossAxisSpacing * (element.crossAxisCount - 1))) / 
                      element.crossAxisCount;
    final cardHeight = cardWidth / element.childAspectRatio;

    return Container(
      width: element.size.width,
      height: element.size.height,
      padding: EdgeInsets.all(element.padding),
      decoration: BoxDecoration(
        color: element.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Category Header (if enabled)
          if (element.showCategoryHeader)
            _buildMockCategoryHeader(element),
          
          // Product Grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: element.crossAxisCount,
                childAspectRatio: element.childAspectRatio,
                crossAxisSpacing: element.crossAxisSpacing,
                mainAxisSpacing: element.mainAxisSpacing,
              ),
              itemCount: mockProducts.length,
              itemBuilder: (context, index) {
                return _buildProductCard(
                  element,
                  mockProducts[index],
                  cardWidth,
                  cardHeight,
                  true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockCategoryHeader(ProductGridElement element) {
    // Mock category header for preview
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Row(
        children: [
          // Mock category image
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Icon(Icons.category, color: Colors.amber.shade700, size: 30),
          ),
          
          // Mock category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  element.categoryFilter ?? 'Category Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Category header preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridEmpty(ProductGridElement element) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      padding: EdgeInsets.all(element.padding),
      decoration: BoxDecoration(
        color: element.backgroundColor,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Product Grid',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${element.crossAxisCount} columns',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGridActual(
    ProductGridElement element,
    List<Map<String, dynamic>> products, {
    bool isPreview = false,
  }) {
    // Calculate grid dimensions
    final gridWidth = element.size.width - (element.padding * 2);
    final cardWidth = (gridWidth - (element.crossAxisSpacing * (element.crossAxisCount - 1))) / 
                      element.crossAxisCount;
    final cardHeight = cardWidth / element.childAspectRatio;

    // Get category info if showing header
    String? categoryName;
    String? categoryImage;
    
    if (element.showCategoryHeader && invoiceData?.catalog != null) {
      if (element.categoryFilter != null) {
        final category = invoiceData!.catalog!.getCategoryByName(element.categoryFilter!);
        if (category != null) {
          categoryName = category.name;
          categoryImage = category.image;
        }
      }
    }

    return Container(
      width: element.size.width,
      height: element.size.height,
      padding: EdgeInsets.all(element.padding),
      decoration: BoxDecoration(
        color: element.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          if (element.showCategoryHeader && categoryName != null)
            _buildCategoryHeader(element, categoryName, categoryImage),
          
          // Product Grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: element.crossAxisCount,
                childAspectRatio: element.childAspectRatio,
                crossAxisSpacing: element.crossAxisSpacing,
                mainAxisSpacing: element.mainAxisSpacing,
              ),
              itemCount: products.length.clamp(0, element.maxProductsPerPage),
              itemBuilder: (context, index) {
                return _buildProductCard(
                  element,
                  products[index],
                  cardWidth,
                  cardHeight,
                  isPreview,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    ProductGridElement element,
    String categoryName,
    String? categoryImage,
  ) {
    // Check if custom category header template exists
    if (element.categoryHeaderTemplate != null && 
        element.categoryHeaderTemplate!.isNotEmpty) {
      // Render custom header template
      return SizedBox(
        height: 80,
        child: Stack(
          children: element.categoryHeaderTemplate!.map((headerElement) {
            // Clone and replace category placeholders
            final renderedElement = _applyCategoryDataToElement(
              headerElement,
              categoryName,
              categoryImage,
            );
            
            return Positioned(
              left: headerElement.position.dx,
              top: headerElement.position.dy,
              child: LayerRenderer(
                element: renderedElement,
                invoiceData: invoiceData,
              ),
            );
          }).toList(),
        ),
      );
    }

    // Default category header design
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Category Image
          if (categoryImage != null && categoryImage.isNotEmpty)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(categoryImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Category Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (invoiceData?.catalog != null)
                  Text(
                    '${invoiceData!.catalog!.getCategoryByName(element.categoryFilter!)?.products.length ?? 0} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TemplateElement _applyCategoryDataToElement(
    TemplateElement element,
    String categoryName,
    String? categoryImage,
  ) {
    // Handle category placeholders for header elements
    if (element is TextElement) {
      String text = element.text;
      
      // Replace category placeholders
      text = text.replaceAll('{{category.name}}', categoryName);
      
      if (invoiceData?.catalog != null && element.text.contains('{{category.')) {
        final category = invoiceData!.catalog!.getCategoryByName(categoryName);
        if (category != null) {
          text = text.replaceAll('{{category.description}}', category.description ?? '');
          text = text.replaceAll('{{category.productCount}}', category.products.length.toString());
        }
      }
      
      // Create modified text element
      return TextElement(
        id: element.id,
        name: element.name,
        position: element.position,
        size: element.size,
        rotation: element.rotation,
        opacity: element.opacity,
        isLocked: element.isLocked,
        isVisible: element.isVisible,
        zIndex: element.zIndex,
        text: text,
        fontFamily: element.fontFamily,
        fontSize: element.fontSize,
        textColor: element.textColor,
        fontWeight: element.fontWeight,
        fontStyle: element.fontStyle,
        textDecoration: element.textDecoration,
        textAlign: element.textAlign,
        letterSpacing: element.letterSpacing,
        wordSpacing: element.wordSpacing,
        lineHeight: element.lineHeight,
        shadow: element.shadow,
        stroke: element.stroke,
        background: element.background,
        autoSize: element.autoSize,
        maxWidth: element.maxWidth,
      );
    } else if (element is ImageElement) {
      // Handle category image placeholder
      if (element.placeholderKey == 'category.image' && categoryImage != null) {
        return ImageElement(
          id: element.id,
          name: element.name,
          position: element.position,
          size: element.size,
          rotation: element.rotation,
          opacity: element.opacity,
          isLocked: element.isLocked,
          isVisible: element.isVisible,
          zIndex: element.zIndex,
          imageUrl: categoryImage,
          fit: element.fit,
          border: element.border,
          shadow: element.shadow,
          blur: element.blur,
          brightness: element.brightness,
          contrast: element.contrast,
          saturation: element.saturation,
          overlayColor: element.overlayColor,
          overlayOpacity: element.overlayOpacity,
          flipHorizontal: element.flipHorizontal,
          flipVertical: element.flipVertical,
          borderRadiusTopLeft: element.borderRadiusTopLeft,
          borderRadiusTopRight: element.borderRadiusTopRight,
          borderRadiusBottomLeft: element.borderRadiusBottomLeft,
          borderRadiusBottomRight: element.borderRadiusBottomRight,
          clipShape: element.clipShape,
        );
      }
    }
    
    // Return element as-is
    return element;
  }

  Widget _buildProductCard(
    ProductGridElement element,
    Map<String, dynamic> product,
    double cardWidth,
    double cardHeight,
    bool isPreview,
  ) {
    if (element.cardTemplate.isEmpty) {
      // Default card if no template is defined
      return _buildDefaultProductCard(product, isPreview);
    }

    // Render card template with product data
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        children: element.cardTemplate.map((templateElement) {
          // Clone the template element and replace placeholders
          final renderedElement = _applyProductDataToElement(templateElement, product, isPreview);
          
          return Positioned(
            left: templateElement.position.dx,
            top: templateElement.position.dy,
            child: LayerRenderer(
              element: renderedElement,
              invoiceData: invoiceData,
            ),
          );
        }).toList(),
      ),
    );
  }

  TemplateElement _applyProductDataToElement(
    TemplateElement element,
    Map<String, dynamic> product,
    bool isPreview,
  ) {
    // Handle different element types and replace placeholders
    if (element is TextElement) {
      String text = element.text;
      
      // Replace product placeholders
      text = text.replaceAllMapped(RegExp(r'\{\{product\.([^}]+)\}\}'), (match) {
        final key = match.group(1)!;
        
        if (isPreview) {
          // In preview mode, show placeholder text
          return '{{product.$key}}';
        }
        
        // Replace with actual product data
        switch (key) {
          case 'name':
            return product['name']?.toString() ?? '';
          case 'price':
            return '₹${product['price']?.toString() ?? '0'}';
          case 'discountedPrice':
          case 'price_discounted':
            final price = (product['price'] ?? 0).toDouble();
            final discount = (product['discount'] ?? 0).toDouble();
            final discounted = price - (price * discount / 100);
            return '₹${discounted.toStringAsFixed(0)}';
          case 'description':
            return product['description']?.toString() ?? '';
          case 'code':
            return product['code']?.toString() ?? '';
          case 'discount':
            final discount = product['discount'];
            return discount != null && discount > 0 ? '$discount% OFF' : '';
          case 'unit':
            return product['unit']?.toString() ?? '';
          default:
            return product[key]?.toString() ?? '';
        }
      });
      
      // Create a modified text element
      return TextElement(
        id: element.id,
        name: element.name,
        position: element.position,
        size: element.size,
        rotation: element.rotation,
        opacity: element.opacity,
        isLocked: element.isLocked,
        isVisible: element.isVisible,
        zIndex: element.zIndex,
        text: text,
        fontFamily: element.fontFamily,
        fontSize: element.fontSize,
        textColor: element.textColor,
        fontWeight: element.fontWeight,
        fontStyle: element.fontStyle,
        textDecoration: element.textDecoration,
        textAlign: element.textAlign,
        letterSpacing: element.letterSpacing,
        wordSpacing: element.wordSpacing,
        lineHeight: element.lineHeight,
        shadow: element.shadow,
        stroke: element.stroke,
        background: element.background,
        autoSize: element.autoSize,
        maxWidth: element.maxWidth,
      );
    } else if (element is ImageElement) {
      // Handle image placeholders
      if (element.placeholderKey != null && element.placeholderKey!.contains('product.image')) {
        final imageUrl = product['image']?.toString();
        
        return ImageElement(
          id: element.id,
          name: element.name,
          position: element.position,
          size: element.size,
          rotation: element.rotation,
          opacity: element.opacity,
          isLocked: element.isLocked,
          isVisible: element.isVisible,
          zIndex: element.zIndex,
          imageUrl: imageUrl,
          fit: element.fit,
          border: element.border,
          shadow: element.shadow,
          blur: element.blur,
          brightness: element.brightness,
          contrast: element.contrast,
          saturation: element.saturation,
          overlayColor: element.overlayColor,
          overlayOpacity: element.overlayOpacity,
          flipHorizontal: element.flipHorizontal,
          flipVertical: element.flipVertical,
          borderRadiusTopLeft: element.borderRadiusTopLeft,
          borderRadiusTopRight: element.borderRadiusTopRight,
          borderRadiusBottomLeft: element.borderRadiusBottomLeft,
          borderRadiusBottomRight: element.borderRadiusBottomRight,
          clipShape: element.clipShape,
        );
      }
    }
    
    // Return element as-is for other types
    return element;
  }

  Widget _buildDefaultProductCard(Map<String, dynamic> product, bool isPreview) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Icon(Icons.image, color: Colors.grey.shade400, size: 32),
              ),
            ),
          ),
          // Product details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product['name']?.toString() ?? 'Product',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '₹${product['price']?.toString() ?? '0'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
class _QrPatternPainter extends CustomPainter {
  final Color color;

  _QrPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cellSize = size.width / 10;

    // Draw corner squares (like real QR)
    _drawCornerSquare(canvas, paint, 0, 0, cellSize * 2.5);
    _drawCornerSquare(canvas, paint, size.width - cellSize * 2.5, 0, cellSize * 2.5);
    _drawCornerSquare(canvas, paint, 0, size.height - cellSize * 2.5, cellSize * 2.5);

    // Draw some random dots
    for (int i = 3; i < 7; i++) {
      for (int j = 3; j < 7; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize * 0.8, cellSize * 0.8),
            paint,
          );
        }
      }
    }
  }

  void _drawCornerSquare(Canvas canvas, Paint paint, double x, double y, double size) {
    // Outer square
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);

    // Inner white square
    final innerPaint = Paint()..color = Colors.white;
    final innerOffset = size * 0.2;
    final innerSize = size * 0.6;
    canvas.drawRect(
      Rect.fromLTWH(x + innerOffset, y + innerOffset, innerSize, innerSize),
      innerPaint,
    );

    // Center dot
    final centerOffset = size * 0.35;
    final centerSize = size * 0.3;
    canvas.drawRect(
      Rect.fromLTWH(x + centerOffset, y + centerOffset, centerSize, centerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
/// Shape Painter
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double cornerRadius;

  ShapePainter({
    required this.shapeType,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    switch (shapeType) {
      case ShapeType.rectangle:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        );
        canvas.drawRRect(rect, fillPaint);
        canvas.drawRRect(rect, strokePaint);
        break;

      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width < size.height ? size.width / 2 : size.height / 2;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, strokePaint);
        break;

      case ShapeType.triangle:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;

      case ShapeType.diamond:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;

      default:
        final rect = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== SHAPE CLIPPER ====================
class _ShapeClipper extends CustomClipper<Path> {
  final ShapeType shapeType;
  final Size elementSize;

  _ShapeClipper(this.shapeType, this.elementSize);

  @override
  Path getClip(Size size) {
    switch (shapeType) {
      case ShapeType.circle:
        return Path()
          ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
      case ShapeType.triangle:
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
      case ShapeType.diamond:
        return Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
      case ShapeType.hexagon:
        return _createPolygonClip(size, 6);
      case ShapeType.star:
        return _createStarClip(size, 5, 0.5);
      default:
        return Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
  }

  Path _createPolygonClip(Size size, int sides) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;
    final angle = 2 * math.pi / sides;
    final startAngle = -math.pi / 2;

    for (int i = 0; i < sides; i++) {
      final x = centerX + radius * math.cos(startAngle + angle * i);
      final y = centerY + radius * math.sin(startAngle + angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createStarClip(Size size, int points, double innerRatio) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * innerRatio;
    final angle = math.pi / points;
    final startAngle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * math.cos(startAngle + angle * i);
      final y = centerY + radius * math.sin(startAngle + angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ==================== ENHANCED SHAPE PAINTER ====================
class EnhancedShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double cornerRadius;
  final Offset startPoint;
  final Offset endPoint;
  final double dashLength;
  final double dashGap;
  final double arrowSize;
  final double curvature;
  final bool hasShadow;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  EnhancedShapePainter({
    required this.shapeType,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.startPoint,
    required this.endPoint,
    required this.dashLength,
    required this.dashGap,
    required this.arrowSize,
    required this.curvature,
    required this.hasShadow,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Check if it's a line type
    if (shapeType.isLine) {
      _paintLine(canvas, size);
    } else {
      _paintShape(canvas, size);
    }
  }

  void _paintShape(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shadow paint
    Paint? shadowPaint;
    if (hasShadow) {
      shadowPaint = Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
    }

    Path path;

    switch (shapeType) {
      case ShapeType.rectangle:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        );
        path = Path()..addRRect(rect);
        break;

      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = math.min(size.width, size.height) / 2;
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        break;

      case ShapeType.triangle:
        path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        break;

      case ShapeType.diamond:
        path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        break;

      case ShapeType.pentagon:
        path = _createPolygonPath(size, 5);
        break;

      case ShapeType.hexagon:
        path = _createPolygonPath(size, 6);
        break;

      case ShapeType.star:
        path = _createStarPath(size, 5, 0.5);
        break;

      case ShapeType.arrow:
        path = _createArrowShapePath(size);
        break;

      default:
        path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    // Draw shadow
    if (hasShadow && shadowPaint != null) {
      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // Draw fill
    if (fillColor != Colors.transparent) {
      canvas.drawPath(path, fillPaint);
    }

    // Draw stroke
    if (strokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }
  }

  void _paintLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate actual start and end points based on size
    final start = Offset(0, size.height / 2);
    final end = Offset(size.width, size.height / 2);

    // Draw shadow
    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = shadowColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);

      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawLine(start, end, shadowPaint);
      canvas.restore();
    }

    switch (shapeType) {
      case ShapeType.lineSolid:
        canvas.drawLine(start, end, paint);
        break;

      case ShapeType.lineDashed:
        _drawDashedLine(canvas, start, end, paint);
        break;

      case ShapeType.lineDotted:
        _drawDottedLine(canvas, start, end, paint);
        break;

      case ShapeType.lineArrow:
        canvas.drawLine(start, end, paint);
        _drawArrowHead(canvas, start, end, paint);
        break;

      case ShapeType.lineDoubleArrow:
        canvas.drawLine(start, end, paint);
        _drawArrowHead(canvas, start, end, paint);
        _drawArrowHead(canvas, end, start, paint);
        break;

      case ShapeType.lineCurved:
        _drawCurvedLine(canvas, start, end, paint);
        break;

      default:
        canvas.drawLine(start, end, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / length;
    final unitY = dy / length;

    double currentX = start.dx;
    double currentY = start.dy;
    double remaining = length;

    while (remaining > 0) {
      final dashLen = math.min(dashLength, remaining);
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX + unitX * dashLen, currentY + unitY * dashLen),
        paint,
      );
      currentX += unitX * (dashLength + dashGap);
      currentY += unitY * (dashLength + dashGap);
      remaining -= dashLength + dashGap;
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final unitX = dx / length;
    final unitY = dy / length;
    final dotSpacing = strokeWidth * 3;

    double currentX = start.dx;
    double currentY = start.dy;

    while ((currentX - start.dx).abs() <= dx.abs() &&
        (currentY - start.dy).abs() <= dy.abs()) {
      canvas.drawCircle(
        Offset(currentX, currentY),
        strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      currentX += unitX * dotSpacing;
      currentY += unitY * dotSpacing;
    }
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowAngle = math.pi / 6; // 30 degrees

    final path = Path();
    path.moveTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * math.cos(angle - arrowAngle),
      to.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    path.moveTo(to.dx, to.dy);
    path.lineTo(
      to.dx - arrowSize * math.cos(angle + arrowAngle),
      to.dy - arrowSize * math.sin(angle + arrowAngle),
    );

    canvas.drawPath(path, paint);
  }

  void _drawCurvedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final controlPoint = Offset(midX, midY - curvature);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }

  Path _createPolygonPath(Size size, int sides) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // Use separate radii for X and Y to fill the bounding box
    final radiusX = size.width / 2;
    final radiusY = size.height / 2;
    final angle = 2 * math.pi / sides;
    final startAngle = -math.pi / 2;

    for (int i = 0; i < sides; i++) {
      final x = centerX + radiusX * math.cos(startAngle + angle * i);
      final y = centerY + radiusY * math.sin(startAngle + angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createStarPath(Size size, int points, double innerRatio) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    // Use separate radii for X and Y to fill the bounding box
    final outerRadiusX = size.width / 2;
    final outerRadiusY = size.height / 2;
    final innerRadiusX = outerRadiusX * innerRatio;
    final innerRadiusY = outerRadiusY * innerRatio;
    final angle = math.pi / points;
    final startAngle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final radiusX = i.isEven ? outerRadiusX : innerRadiusX;
      final radiusY = i.isEven ? outerRadiusY : innerRadiusY;
      final x = centerX + radiusX * math.cos(startAngle + angle * i);
      final y = centerY + radiusY * math.sin(startAngle + angle * i);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createArrowShapePath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.3);
    path.lineTo(w * 0.6, h * 0.3);
    path.lineTo(w * 0.6, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.6, h);
    path.lineTo(w * 0.6, h * 0.7);
    path.lineTo(0, h * 0.7);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


// ============================================================================
// 📁 FILE: lib/widgets/layers/svg_layer.dart
// ============================================================================



/// SVG Layer Widget
class SvgLayerWidget extends StatelessWidget {
  final SvgElement element;

  const SvgLayerWidget({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    Widget svgWidget = SvgPicture.string(
      element.processedSvgString,
      width: element.size.width,
      height: element.size.height,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Container(
        width: element.size.width,
        height: element.size.height,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey),
        ),
      ),
    );

    // Apply flip transforms
    if (element.flipHorizontal || element.flipVertical) {
      svgWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            element.flipHorizontal ? -1.0 : 1.0,
            element.flipVertical ? -1.0 : 1.0,
          ),
        child: svgWidget,
      );
    }

    // Apply color filter for brightness/contrast/saturation
    if (element.brightness != 0 || element.contrast != 0 || element.saturation != 0) {
      svgWidget = ColorFiltered(
        colorFilter: _createColorFilter(),
        child: svgWidget,
      );
    }

    // Apply blur
    if (element.blur > 0) {
      svgWidget = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: element.blur,
          sigmaY: element.blur,
        ),
        child: svgWidget,
      );
    }

    // Apply shadow
    if (element.hasShadow) {
      svgWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: element.shadowColor,
              blurRadius: element.shadowBlur,
              offset: element.shadowOffset,
            ),
          ],
        ),
        child: svgWidget,
      );
    }

    return SizedBox(
      width: element.size.width,
      height: element.size.height,
      child: svgWidget,
    );
  }

  ColorFilter _createColorFilter() {
    // Simple brightness adjustment
    final b = element.brightness * 255;
    final c = element.contrast + 1;
    final t = (1 - c) / 2 * 255;

    return ColorFilter.matrix([
      c, 0, 0, 0, b + t,
      0, c, 0, 0, b + t,
      0, 0, c, 0, b + t,
      0, 0, 0, 1, 0,
    ]);
  }
}

/// SVG Preview Widget (for picker)
class SvgPreviewWidget extends StatelessWidget {
  final SvgPreset preset;
  final double size;
  final Color? primaryColor;
  final bool isSelected;

  const SvgPreviewWidget({
    super.key,
    required this.preset,
    this.size = 60,
    this.primaryColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    String svgString = preset.svgString;

    // Apply color if provided
    if (primaryColor != null) {
      final hexColor = '#${primaryColor!.value.toRadixString(16).substring(2).toUpperCase()}';
      svgString = svgString.replaceAll('currentColor', hexColor);
      svgString = svgString.replaceAll('currentStroke', hexColor);
    } else {
      // Default colors
      svgString = svgString.replaceAll('currentColor', '#3498DB');
      svgString = svgString.replaceAll('currentStroke', '#2C3E50');
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)]
            : null,
      ),
      padding: const EdgeInsets.all(8),
      child: SvgPicture.string(
        svgString,
        fit: BoxFit.contain,
      ),
    );
  }
}
// ============================================================================
// 📁 FILE: lib/widgets/dialogs/svg_picker_dialog.dart
// ============================================================================

/// SVG Element Picker Dialog
// class SvgPickerDialog extends StatefulWidget {
//   final Function(SvgPreset preset) onSelect;
//
//   const SvgPickerDialog({
//     super.key,
//     required this.onSelect,
//   });
//
//   @override
//   State<SvgPickerDialog> createState() => _SvgPickerDialogState();
// }
//
// class _SvgPickerDialogState extends State<SvgPickerDialog> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(
//       length: SvgPresetsLibrary.categories.length,
//       vsync: this,
//     );
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   List<SvgPreset> get _filteredPresets {
//     if (_searchQuery.isEmpty) {
//       return SvgPresetsLibrary.categories[_tabController.index].presets;
//     }
//     return SvgPresetsLibrary.searchPresets(_searchQuery);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 700,
//         height: 550,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 const Icon(Icons.extension, color: Colors.purple, size: 28),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Elements Library',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Search Bar
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search elements...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     setState(() {
//                       _searchController.clear();
//                       _searchQuery = '';
//                     });
//                   },
//                 )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 isDense: true,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//             ),
//
//             const SizedBox(height: 16),
//
//             // Category Tabs
//             if (_searchQuery.isEmpty)
//               TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 labelColor: Colors.purple,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: Colors.purple,
//                 tabs: SvgPresetsLibrary.categories.map((category) {
//                   return Tab(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(category.icon, size: 18),
//                         const SizedBox(width: 6),
//                         Text(category.name),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 onTap: (_) => setState(() {}),
//               ),
//
//             const SizedBox(height: 16),
//
//             // Grid
//             Expanded(
//               child: _searchQuery.isNotEmpty
//                   ? _buildSearchResults()
//                   : TabBarView(
//                 controller: _tabController,
//                 children: SvgPresetsLibrary.categories.map((category) {
//                   return _buildCategoryGrid(category.presets);
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchResults() {
//     final results = _filteredPresets;
//
//     if (results.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             Text(
//               'No elements found for "$_searchQuery"',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return _buildCategoryGrid(results);
//   }
//
//   Widget _buildCategoryGrid(List<SvgPreset> presets) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 5,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 1,
//       ),
//       itemCount: presets.length,
//       itemBuilder: (context, index) {
//         final preset = presets[index];
//         return _SvgPresetItem(
//           preset: preset,
//           onTap: () {
//             widget.onSelect(preset);
//             Navigator.pop(context);
//           },
//         );
//       },
//     );
//   }
// }
//
// class _SvgPresetItem extends StatefulWidget {
//   final SvgPreset preset;
//   final VoidCallback onTap;
//
//   const _SvgPresetItem({
//     required this.preset,
//     required this.onTap,
//   });
//
//   @override
//   State<_SvgPresetItem> createState() => _SvgPresetItemState();
// }
//
// class _SvgPresetItemState extends State<_SvgPresetItem> {
//   bool _isHovered = false;
//
//   @override
//   Widget build(BuildContext context) {
//     // Process SVG string with default colors
//     String svgString = widget.preset.svgString;
//     svgString = svgString.replaceAll('currentColor', '#3498DB');
//     svgString = svgString.replaceAll('currentStroke', '#2C3E50');
//     svgString = svgString.replaceAll('secondaryColor', '#2980B9');
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTap: widget.onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           decoration: BoxDecoration(
//             color: _isHovered ? Colors.purple.shade50 : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: _isHovered ? Colors.purple : Colors.grey.shade300,
//               width: _isHovered ? 2 : 1,
//             ),
//             boxShadow: _isHovered
//                 ? [
//               BoxShadow(
//                 color: Colors.purple.withOpacity(0.2),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ]
//                 : null,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: SvgPicture.string(
//                     svgString,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _isHovered ? Colors.purple.shade100 : Colors.grey.shade100,
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(11),
//                     bottomRight: Radius.circular(11),
//                   ),
//                 ),
//                 child: Text(
//                   widget.preset.name,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
//                     color: _isHovered ? Colors.purple.shade700 : Colors.grey.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/// Custom clipper for cropping images based on a rectangle
class _CropRectClipper extends CustomClipper<Rect> {
  final Rect cropRect;
  final Size elementSize;

  _CropRectClipper({
    required this.cropRect,
    required this.elementSize,
  });

  @override
  Rect getClip(Size size) {
    // The size parameter is the size of the parent widget
    // We need to scale the cropRect to fit the actual size
    double widthScale = size.width / elementSize.width;
    double heightScale = size.height / elementSize.height;

    return Rect.fromLTRB(
      cropRect.left * widthScale,
      cropRect.top * heightScale,
      cropRect.right * widthScale,
      cropRect.bottom * heightScale,
    );
  }

  @override
  bool shouldReclip(covariant _CropRectClipper oldClipper) {
    return cropRect != oldClipper.cropRect ||
           elementSize != oldClipper.elementSize;
  }
}



import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/template_element.dart'; // Aapka existing model
import '../models/invoice_model.dart';   // Aapka document model

class CompetitorAdapterService {
  static const _uuid = Uuid();

  // ==================== CRITICAL: RESOLUTION-INDEPENDENT COORDINATE SYSTEM ====================
  
  /// Target document size for our app (A4 standard)
  static const double TARGET_DOC_WIDTH = 595.0;  // A4 width in points
  static const double TARGET_DOC_HEIGHT = 842.0; // A4 height in points
  
  /// Main function to convert Competitor JSON to our app format with coordinate normalization
  static Map<String, dynamic> convertToMyAppFormat(Map<String, dynamic> externalJson) {
    try {
      // 1. Extract source document dimensions
      final data = externalJson['data']['posterBackendObject'];
      final double sourceDocWidth = double.tryParse(data['width'].toString()) ?? 636.0;
      final double sourceDocHeight = double.tryParse(data['height'].toString()) ?? 900.0;

      debugPrint('📐 Import: Source document = ${sourceDocWidth}x$sourceDocHeight');
      debugPrint('📐 Import: Target document = ${TARGET_DOC_WIDTH}x$TARGET_DOC_HEIGHT');

      // 2. Calculate normalization scale factors
      // This is THE KEY FIX: Scale all coordinates from source to target document
      final double scaleX = TARGET_DOC_WIDTH / sourceDocWidth;
      final double scaleY = TARGET_DOC_HEIGHT / sourceDocHeight;
      
      debugPrint('📐 Import: Scale factors = scaleX:${scaleX.toStringAsFixed(3)}, scaleY:${scaleY.toStringAsFixed(3)}');

      List<Map<String, dynamic>> myElements = [];

      // 3. Iterate Pages (Usually page 1 for invoices)
      if (data['pages'] != null && (data['pages'] as List).isNotEmpty) {
        final page = data['pages'][0];

        // 3.1 Handle Graphic Items with coordinate normalization
        if (page['graphicItems'] != null) {
          for (var item in page['graphicItems']) {
            final mappedItem = _mapSingleItem(
              item, 
              sourceDocWidth, 
              sourceDocHeight,
              scaleX,
              scaleY,
            );
            if (mappedItem != null) {
              myElements.add(mappedItem);
            }
          }
        }
      }

      debugPrint('✅ Import: Normalized ${myElements.length} elements to target document size');

      // 4. Return format with TARGET document size (not source)
      return {
        'templateName': data['name'] ?? 'Imported Invoice',
        'document': {
          'width': TARGET_DOC_WIDTH,   // Use target size
          'height': TARGET_DOC_HEIGHT, // Use target size
          'color': 0xFFFFFFFF,
        },
        'elements': myElements,
      };

    } catch (e) {
      debugPrint("⚠️ Import Error: $e");
      return {};
    }
  }

  /// Individual Item Mapping with coordinate normalization
  static Map<String, dynamic>? _mapSingleItem(
    Map item, 
    double sourceDocWidth, 
    double sourceDocHeight,
    double scaleX,
    double scaleY,
  ) {
    final String type = item['gitype'] ?? '';

    // ==================== STEP 1: Extract raw dimensions from source ====================
    final double sourceW = (item['width'] as num?)?.toDouble() ?? 100.0;
    final double sourceH = (item['height'] as num?)?.toDouble() ?? 100.0;
    
    // ==================== STEP 2: Extract raw coordinates from source ====================
    // NOTE: Competitor JSON may use CENTER coordinates, Flutter uses TOP-LEFT
    double sourceXCenter = (item['x'] as num?)?.toDouble() ?? 0.0;
    double sourceYCenter = (item['y'] as num?)?.toDouble() ?? 0.0;
    
    // Convert center to top-left if needed (depends on competitor's coordinate system)
    // For now, assume it's already top-left, but add offset adjustment if needed
    double sourceX = sourceXCenter;
    double sourceY = sourceYCenter;

    // ==================== STEP 3: APPLY NORMALIZATION SCALE ====================
    // This ensures designs look IDENTICAL on all devices
    final double targetX = sourceX * scaleX;
    final double targetY = sourceY * scaleY;
    final double targetW = sourceW * scaleX;
    final double targetH = sourceH * scaleY;
    
    debugPrint('  📍 Element: ${item['name'] ?? type} | '
        'Source: (${sourceX.toStringAsFixed(1)}, ${sourceY.toStringAsFixed(1)}, ${sourceW.toStringAsFixed(1)}x${sourceH.toStringAsFixed(1)}) → '
        'Target: (${targetX.toStringAsFixed(1)}, ${targetY.toStringAsFixed(1)}, ${targetW.toStringAsFixed(1)}x${targetH.toStringAsFixed(1)})');

    // Common Base Object with NORMALIZED coordinates
    final base = {
      'id': _uuid.v4(),
      'position': {'x': targetX, 'y': targetY},
      'size': {'width': targetW, 'height': targetH},
      'rotation': (item['rotation'] as num?)?.toDouble() ?? 0,
      'isLocked': item['lockMovement'] ?? false,
      'isVisible': item['visible'] ?? true,
      'opacity': (item['alpha'] as num?)?.toDouble() ?? 1.0,
    };

    // ===========================================
    // 1. TEXT MAPPING (Best Effort)
    // ===========================================
    if (type == 'text') {
      // COLOR HANDLING: Gradient se bachne ke liye 'color' array ya 'gradientFillColor1' ka first color use karein
      int colorValue = 0xFF000000; // Default Black

      if (item['color'] != null && (item['color'] as List).isNotEmpty) {
        colorValue = _parseRgbaColor(item['color']);
      } else if (item['gradientFillColor1'] != null) {
        // Fallback: Agar simple color nahi hai, gradient ka pehla color lelo
        colorValue = _parseRgbaColor(item['gradientFillColor1']);
      }

      // ==================== CRITICAL: Scale font size too! ====================
      final double sourceFontSize = (item['fontSize'] as num?)?.toDouble() ?? 14.0;
      final double targetFontSize = sourceFontSize * scaleX; // Use scaleX for font scaling
      
      return {
        ...base,
        'type': 'text',
        'text': item['text'] ?? '',
        'fontFamily': _mapFontFamily(item['fontFamily']),
        'fontSize': targetFontSize, // SCALED font size
        'textColor': colorValue,
        'textAlign': item['textAlign'] ?? 'left',

        // Future Proofing: Store raw data
        'metadata': {
          'originalVerticalAlign': item['verticalAlign'],
          'originalGlow': item['glow'],
          'originalFontSize': sourceFontSize,
        }
      };
    }

    // ===========================================
    // 2. SHAPE/RECTANGLE MAPPING
    // ===========================================
    if (type == 'shape' || type == 'rectangle') {
      int fillColor = 0xFFCCCCCC; // Default Grey

      // Handling complex fills safely
      if (item['fill'] != null && item['fill']['fillColor'] != null) {
        // Nested fill object structure from Json 3
        var fillArr = item['fill']['fillColor'];
        if (fillArr is List && fillArr.isNotEmpty) {
          if (fillArr[0] is List) {
            fillColor = _parseRgbaColor(fillArr[0]); // Nested array case
          } else {
            fillColor = _parseRgbaColor(fillArr); // Simple array case
          }
        }
      } else if (item['gradientFillColor1'] != null) {
        fillColor = _parseRgbaColor(item['gradientFillColor1']);
      }

      // ==================== Scale corner radius if present ====================
      final double sourceCornerRadius = (item['rx'] as num?)?.toDouble() ?? 0.0;
      final double targetCornerRadius = sourceCornerRadius * ((scaleX + scaleY) / 2); // Average scale
      
      return {
        ...base,
        'type': 'shape',
        'shapeType': 'rectangle',
        'fillColor': fillColor,
        'cornerRadius': targetCornerRadius, // SCALED corner radius

        // Future Proofing
        'metadata': {
          'originalCornerRadius': sourceCornerRadius,
        }
      };
    }

    // ===========================================
    // 3. IMAGE MAPPING
    // ===========================================
    if (type == 'image') {
      // URL construction logic (Placeholder)
      String imgUrl = '';
      if (item['imageUid'] != null) {
        // Competitor URL pattern (Example)
        imgUrl = "https://example-cdn.com/${item['imageUid']}.png";
      }

      return {
        ...base,
        'type': 'image',
        'imageUrl': imgUrl,
        // Agar file upload hai to local path handle karna padega,
        // abhi ke liye sirf URL structure ready rakho.
      };
    }

    return null; // Unknown types ignored (Line, Vector etc for now)
  }

  // --- Helper: Safe Color Parser ---
  static int _parseRgbaColor(List<dynamic>? rgba) {
    if (rgba == null || rgba.length < 3) return 0xFF000000;

    int r = (rgba[0] as num).toInt();
    int g = (rgba[1] as num).toInt();
    int b = (rgba[2] as num).toInt();

    // Alpha handling
    double a = 1.0;
    if (rgba.length > 3) {
      a = (rgba[3] as num).toDouble();
    }

    return Color.fromRGBO(r, g, b, a).value;
  }

  // --- Helper: Font Mapping ---
  static String _mapFontFamily(String? rawFont) {
    if (rawFont == null) return 'Roboto';
    // Yaha par mapping list banani padegi
    // e.g. 'LeagueSpartanBold' -> 'League Spartan'
    // Abhi ke liye safe fallback:
    return 'Roboto';
  }
}
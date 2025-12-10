import 'package:flutter/material.dart';
import 'package:flutter_poster_maker/screens/debug/invoice_test_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'editor/invoice_pro_editor.dart';
import 'editor/editor_configs.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const InvoiceEditorApp(),
    ),
  );
}

class InvoiceEditorApp extends StatelessWidget {
  const InvoiceEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Poster & Invoice Maker',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          // home: const HomeScreen(),
          home: const InvoiceTestScreen(),
          routes: {
            '/editor': (context) => const EditorHomePage(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}

class EditorHomePage extends StatelessWidget {
  const EditorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return InvoiceProEditor(
      configs: const InvoiceEditorConfigs(
        canvasConfig: CanvasConfig(
          pageSize: PageSize.a4,
          showRulers: false, // Default OFF per requirements
          showPageBorder: true,
        ),
        toolbarConfig: ToolbarConfig(
          showMainToolbar: true,
          showPropertiesPanel: true,
          showLayersPanel: true,
        ),
        gridConfig: GridConfig(
          showGrid: false, // Default OFF per requirements
          gridSize: 10,
          snapToGrid: true,
        ),
        snapConfig: SnapConfig(
          enableSnap: true,
          snapToElements: true,
          showSnapLines: true,
        ),
      ),
      callbacks: InvoiceEditorCallbacks(
        onSaveTemplate: (templateJson) async {
          debugPrint('📄 Template Saved:');
          debugPrint(const JsonEncoder.withIndent('  ').convert(templateJson));
        },
        onExportInvoice: (invoiceJson) async {
          debugPrint('📧 Invoice Exported:');
          debugPrint(const JsonEncoder.withIndent('  ').convert(invoiceJson));
        },
        onLayerAdded: (element) {
          debugPrint('➕ Layer Added: ${element.name}');
        },
        onLayerRemoved: (id) {
          debugPrint('➖ Layer Removed: $id');
        },
        onSelectionChanged: (ids) {
          debugPrint('🔷 Selection: ${ids.length} elements');
        },
        onError: (error) {
          debugPrint('❌ Error: $error');
        },
      ),
    );
  }
}

// Global navigator key
final navigatorKey = GlobalKey<NavigatorState>();


/*
lib/
├── main.dart
├── editor/
│ ├── invoice_pro_editor.dart
│ ├── editor_controller.dart
│ ├── editor_configs.dart
│ └── callbacks/editor_callbacks.dart
├── models/
│ ├── template_element.dart (Text, Image, Table, Shape, Line, QR, Placeholder, Group, Signature)
│ └── invoice_model.dart
├── widgets/
│ ├── canvas/editor_canvas.dart, grid_overlay.dart, ruler_widget.dart
│ ├── toolbar/main_toolbar.dart.dep.bin, properties_panel.dart.dep.bin, layers_panel.dart.dep
│ ├── common/resizable_widget.dart
│ └── layers/layer_renderer.dart, signature_layer.dart
└── utils/pdf_export.dart




## Key Features
- ✅ Drag & Drop, Resize, Rotate elements
- ✅ Multi-select, Group/Ungroup
- ✅ Layers panel with reordering
- ✅ Properties panel for each element type
- ✅ 9 Element Types: Text, Image, Table, Shape, Line, QR, Placeholder, Group, Signature
- ✅ Undo/Redo, Copy/Paste
- ✅ Grid, Rulers, Snap
- ✅ JSON Import/Export
- ✅ Invoice Data Binding with Placeholders
- ✅ PDF Export
- ✅ Keyboard shortcuts

## Dependencies
- provider, qr_flutter, uuid, image_picker, pdf, printing

## Usage
```dart
InvoiceProEditor(
  configs: InvoiceEditorConfigs(...),
  callbacks: InvoiceEditorCallbacks(
    onSaveTemplate: (json) => ...,
    onExportInvoice: (json) => ...,
  ),
)

 */
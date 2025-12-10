import 'package:flutter/material.dart' hide TableCell;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_poster_maker/components/inputs/app_text_field.dart';

import '../../editor/editor_controller.dart';
import '../../models/invoice_model.dart';
import '../../models/template_element.dart';
import '../../utils/responsive_utils.dart';
import 'common_properties.dart';

/// ============================================================================
/// SIMPLE TABLE PROPERTIES - UPGRADED
/// ============================================================================
class SimpleTableProperties extends StatelessWidget {
  final TableElement element;
  final InvoiceEditorController controller;

  const SimpleTableProperties({
    super.key,
    required this.element,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. MAIN ACTION: Edit Table Content & Cells
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit_note, size: 20),
            label: const Text('Edit Table Content & Cells'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _showTableContentEditor(context),
          ),
        ),

        const SizedBox(height: 16),

        // 2. DIMENSIONS
        PropertySection(
          title: 'Dimensions',
          children: [
            Row(
              children: [
                Expanded(
                  child: PropertyField(
                    label: 'Rows',
                    child: TextFormField(
                      key: ValueKey('table-rows-${element.id}'),
                      initialValue: element.rows.toString(),
                      decoration: const InputDecoration(
                          isDense: true, border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (value) {
                        final rows = int.tryParse(value);
                        if (rows != null && rows > 0 && rows <= 50) {
                          _updateTableDimensions(
                              element, rows, element.columns);
                          controller.notifyListeners();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PropertyField(
                    label: 'Columns',
                    child: TextFormField(
                      key: ValueKey('table-cols-${element.id}'),
                      initialValue: element.columns.toString(),
                      decoration: const InputDecoration(
                          isDense: true, border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (value) {
                        final columns = int.tryParse(value);
                        if (columns != null && columns > 0 && columns <= 20) {
                          _updateTableDimensions(
                              element, element.rows, columns);
                          controller.notifyListeners();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. STYLING CONTROLS - Enhanced
        PropertySection(
          title: 'Table Style',
          children: [
            // Show Header
            SwitchListTile(
              title:
                  const Text('Show Header', style: TextStyle(fontSize: 13)),
              subtitle: const Text('Display header row with bold text', style: TextStyle(fontSize: 11)),
              value: element.tableStyle.showHeader,
              contentPadding: EdgeInsets.zero,
              dense: true,
              onChanged: (value) {
                element.tableStyle = TableStyle(
                  borderColor: element.tableStyle.borderColor,
                  borderWidth: element.tableStyle.borderWidth,
                  headerBackgroundColor:
                      element.tableStyle.headerBackgroundColor,
                  cellPadding: element.tableStyle.cellPadding,
                  showHeader: value,
                );
                controller.notifyListeners();
              },
            ),
            const SizedBox(height: 12),
            
            // Border Width Slider
            PropertyField(
              label:
                  'Border Width (${element.tableStyle.borderWidth.toStringAsFixed(1)} px)',
              child: Slider(
                value: element.tableStyle.borderWidth,
                min: 0,
                max: 5,
                divisions: 10,
                label: element.tableStyle.borderWidth.toStringAsFixed(1),
                onChanged: (val) {
                  element.tableStyle = TableStyle(
                    borderColor: element.tableStyle.borderColor,
                    borderWidth: val,
                    headerBackgroundColor:
                        element.tableStyle.headerBackgroundColor,
                    cellPadding: element.tableStyle.cellPadding,
                    showHeader: element.tableStyle.showHeader,
                  );
                  controller.notifyListeners();
                },
              ),
            ),
            
            // Cell Padding Slider
            PropertyField(
              label:
                  'Cell Padding (${element.tableStyle.cellPadding.toStringAsFixed(0)} px)',
              child: Slider(
                value: element.tableStyle.cellPadding,
                min: 0,
                max: 20,
                divisions: 20,
                label: element.tableStyle.cellPadding.toStringAsFixed(0),
                onChanged: (val) {
                  element.tableStyle = TableStyle(
                    borderColor: element.tableStyle.borderColor,
                    borderWidth: element.tableStyle.borderWidth,
                    headerBackgroundColor:
                        element.tableStyle.headerBackgroundColor,
                    cellPadding: val,
                    showHeader: element.tableStyle.showHeader,
                  );
                  controller.notifyListeners();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTableContentEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TableContentEditor(
        element: element,
        controller: controller,
      ),
    );
  }
}

void _updateTableDimensions(TableElement element, int newRows, int newColumns) {
  final newCells = <List<TableCell>>[];
  for (int r = 0; r < newRows; r++) {
    final row = <TableCell>[];
    for (int c = 0; c < newColumns; c++) {
      if (r < element.rows && c < element.columns) {
        row.add(element.cells[r][c]);
      } else {
        row.add(TableCell());
      }
    }
    newCells.add(row);
  }
  element.rows = newRows;
  element.columns = newColumns;
  element.cells = newCells;
}

/// ============================================================================
/// TABLE CONTENT EDITOR - SPREADSHEET-STYLE BOTTOM SHEET
/// ============================================================================
class TableContentEditor extends StatefulWidget {
  final TableElement element;
  final InvoiceEditorController controller;

  const TableContentEditor({
    super.key,
    required this.element,
    required this.controller,
  });

  @override
  State<TableContentEditor> createState() => _TableContentEditorState();
}

class _TableContentEditorState extends State<TableContentEditor> {
  int _selectedRow = 0;
  int _selectedCol = 0;
  late TextEditingController _textController;

  TableCell get _currentCell {
    if (_selectedRow < widget.element.rows &&
        _selectedCol < widget.element.columns) {
      return widget.element.cells[_selectedRow][_selectedCol];
    }
    return widget.element.cells[0][0]; // Fallback
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _currentCell.content);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _textController.text = _currentCell.content;
      // If cell has a placeholder key, show that instead of raw content if content is empty
      if (_currentCell.placeholderKey != null && _currentCell.content.isEmpty) {
        _textController.text = '{{${_currentCell.placeholderKey}}}';
      }
    });
  }

  void _updateCellContent(String value) {
    setState(() {
      _currentCell.content = value;
      // Simple check: if value looks like {{key}}, set placeholder
      if (value.startsWith('{{') && value.endsWith('}}')) {
        _currentCell.placeholderKey = value.substring(2, value.length - 2);
      } else {
        _currentCell.placeholderKey = null;
      }
    });
    widget.controller.notifyListeners();
  }

  /// ONE-TAP PLACEHOLDER INSERT - Core POS Feature
  void _insertPlaceholder(String key) {
    final text = '{{$key}}';
    _textController.text = text;
    _updateCellContent(text);
  }

  void _showColorPicker() {
    Color pickerColor = _currentCell.backgroundColor ?? Colors.transparent;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cell Background Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            enableAlpha: true,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            pickerAreaHeightPercent: 0.7,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentCell.backgroundColor = pickerColor;
              });
              widget.controller.notifyListeners();
              Navigator.pop(ctx);
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Container(
      height: size.height * (isMobile ? 0.90 : 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Header
          _buildHeader(context),

          // 2. Table Visual Grid (Scrollable) - Enhanced
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.grid_on, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Visual Table Grid',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap cell to edit',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildTableGrid(theme),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade300,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 3. Editor Panel - Enhanced
          Expanded(
            flex: 5,
            child: Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cell Info Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cell [${_selectedRow + 1}, ${_selectedCol + 1}]',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Navigation Arrows
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: _selectedCol > 0
                              ? () => _selectCell(_selectedRow, _selectedCol - 1)
                              : null,
                          tooltip: 'Previous cell',
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: _selectedCol < widget.element.columns - 1
                              ? () => _selectCell(_selectedRow, _selectedCol + 1)
                              : null,
                          tooltip: 'Next cell',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  // Text Input
                  AppTextField(
                    controller: _textController,
                    label: 'Cell Content',
                    prefixIcon: Icons.edit,
                    onChanged: _updateCellContent,
                  ),

                  const SizedBox(height: 12),

                  // Quick Placeholders - POS-Ready
                  const Text('Quick Insert Placeholders:',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Invoice Data
                        _buildPlaceholderChip('Invoice #', 'invoice.invoice_no', Icons.receipt),
                        _buildPlaceholderChip('Date', 'invoice.date', Icons.calendar_today),
                        _buildPlaceholderChip('Grand Total', 'invoice.grand_total', Icons.attach_money),
                        _buildPlaceholderChip('Sub Total', 'invoice.sub_total', Icons.calculate),
                        
                        // Customer Data
                        _buildPlaceholderChip('Customer', 'customer.name', Icons.person),
                        _buildPlaceholderChip('Customer Phone', 'customer.phone', Icons.phone),
                        
                        // Business Data
                        _buildPlaceholderChip('Business', 'business.name', Icons.store),
                        _buildPlaceholderChip('Business Phone', 'business.phone', Icons.contact_phone),
                        
                        // Item Data (for tables)
                        _buildPlaceholderChip('Item Name', 'item.description', Icons.inventory),
                        _buildPlaceholderChip('Quantity', 'item.qty', Icons.numbers),
                        _buildPlaceholderChip('Rate', 'item.rate', Icons.price_check),
                        _buildPlaceholderChip('Item Total', 'item.row_total', Icons.shopping_cart),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Style Controls Section - Enhanced
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Cell Styling',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Alignment
                        Row(
                          children: [
                            const Text('Alignment: ',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            const SizedBox(width: 8),
                            ToggleButtons(
                              constraints:
                                  const BoxConstraints(minHeight: 36, minWidth: 40),
                              isSelected: [
                                _currentCell.textAlign == TextAlign.left,
                                _currentCell.textAlign == TextAlign.center,
                                _currentCell.textAlign == TextAlign.right,
                              ],
                              onPressed: (index) {
                                setState(() {
                                  if (index == 0)
                                    _currentCell.textAlign = TextAlign.left;
                                  if (index == 1)
                                    _currentCell.textAlign = TextAlign.center;
                                  if (index == 2)
                                    _currentCell.textAlign = TextAlign.right;
                                });
                                widget.controller.notifyListeners();
                              },
                              borderRadius: BorderRadius.circular(8),
                              selectedColor: theme.colorScheme.primary,
                              fillColor: theme.colorScheme.primaryContainer,
                              children: const [
                                Icon(Icons.format_align_left, size: 18),
                                Icon(Icons.format_align_center, size: 18),
                                Icon(Icons.format_align_right, size: 18),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Background Color
                        Row(
                          children: [
                            const Text('Background: ',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showColorPicker(),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _currentCell.backgroundColor ??
                                      Colors.white,
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _currentCell.backgroundColor == null
                                          ? Icons.format_color_reset
                                          : Icons.palette,
                                      size: 16,
                                      color: _currentCell.backgroundColor == null
                                          ? Colors.grey.shade600
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _currentCell.backgroundColor == null
                                          ? 'No Color'
                                          : 'Custom',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_currentCell.backgroundColor != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _currentCell.backgroundColor = null;
                                  });
                                  widget.controller.notifyListeners();
                                },
                                tooltip: 'Clear color',
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderChip(String label, String key, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        avatar: Icon(icon, size: 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        visualDensity: VisualDensity.compact,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
        onPressed: () => _insertPlaceholder(key),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.table_chart, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table Content Editor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Edit cells, add placeholders, customize styling',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Done',
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(90),
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          children: List.generate(widget.element.rows, (rowIdx) {
            return TableRow(
              decoration: rowIdx == 0 && widget.element.tableStyle.showHeader
                  ? BoxDecoration(color: Colors.grey.shade100)
                  : null,
              children: List.generate(widget.element.columns, (colIdx) {
                final isSelected = rowIdx == _selectedRow && colIdx == _selectedCol;
                final cell = widget.element.cells[rowIdx][colIdx];
                final isHeader = rowIdx == 0 && widget.element.tableStyle.showHeader;

                return GestureDetector(
                  onTap: () => _selectCell(rowIdx, colIdx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : (cell.backgroundColor ?? 
                             (isHeader ? Colors.grey.shade100 : Colors.white)),
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    padding: const EdgeInsets.all(6),
                    alignment: _getAlignment(cell.textAlign),
                    child: Text(
                      cell.placeholderKey != null
                          ? '{{${cell.placeholderKey}}}'
                          : (cell.content.isEmpty ? '—' : cell.content),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected || isHeader
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: cell.placeholderKey != null
                            ? theme.colorScheme.primary
                            : (isHeader ? Colors.grey.shade700 : Colors.black87),
                        fontStyle: cell.placeholderKey != null
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Alignment _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}

void _showColumnEditorDialog(BuildContext context, ItemTableElement element,
    InvoiceEditorController controller) {
  // Can be made responsive similarly if needed, for now focusing on Style Editor per request
  showDialog(
    context: context,
    builder: (context) => ItemTableColumnEditor(
      element: element,
      onSave: () => controller.notifyListeners(),
    ),
  );
}

void _showStyleEditorDialog(BuildContext context, ItemTableElement element,
    InvoiceEditorController controller) {
  final isMobile = ResponsiveUtils.isMobile(context);

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ItemTableStyleEditor(
          element: element,
          onSave: () => controller.notifyListeners(),
          isMobile: true,
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => ItemTableStyleEditor(
        element: element,
        onSave: () => controller.notifyListeners(),
        isMobile: false,
      ),
    );
  }
}

class ItemTableProperties extends StatelessWidget {
  final ItemTableElement element;
  final InvoiceEditorController controller;

  const ItemTableProperties({
    super.key,
    required this.element,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Column Configuration
        PropertySection(
          title: 'Columns',
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.view_column, size: 18),
                label: const Text('Edit Columns & Widths'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                ),
                onPressed: () {
                  _showColumnEditorDialog(context, element, controller);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Styling (Presets + Manual)
        PropertySection(title: 'Appearance', children: [
          DropdownButtonFormField<ItemTablePreset>(
            value: element.preset,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Quick Preset',
            ),
            items: ItemTablePreset.values.map((preset) {
              return DropdownMenuItem(
                value: preset,
                child: Text(preset.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                element.applyPreset(value);
                controller.notifyListeners();
              }
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.palette, size: 18),
              label: const Text('Customize Colors & Fonts'),
              onPressed: () {
                _showStyleEditorDialog(context, element, controller);
              },
            ),
          ),
        ]),

        const SizedBox(height: 16),

        // 3. Visibility Options
        PropertySection(title: 'Visibility', children: [
          SwitchListTile(
            title: const Text('Show Header', style: TextStyle(fontSize: 13)),
            value: element.showHeader,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              element.showHeader = value;
              controller.notifyListeners();
            },
          ),
          SwitchListTile(
            title: const Text('Show Footer (Totals)',
                style: TextStyle(fontSize: 13)),
            value: element.showFooter,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              element.showFooter = value;
              controller.notifyListeners();
            },
          ),
          SwitchListTile(
            title:
                const Text('Show Row Numbers', style: TextStyle(fontSize: 13)),
            value: element.showRowNumbers,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              element.showRowNumbers = value;
              controller.notifyListeners();
            },
          ),
          SwitchListTile(
            title: const Text('Alternate Row Colors',
                style: TextStyle(fontSize: 13)),
            value: element.alternateRowColors,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              element.alternateRowColors = value;
              controller.notifyListeners();
            },
          ),
        ]),

        const SizedBox(height: 16),

        // 4. Borders & Spacing
        PropertySection(
          title: 'Borders & Layout',
          children: [
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Vert. Borders',
                        style: TextStyle(fontSize: 11)),
                    value: element.showVerticalBorders,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      element.showVerticalBorders = value;
                      controller.notifyListeners();
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Horiz. Borders',
                        style: TextStyle(fontSize: 11)),
                    value: element.showHorizontalBorders,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      element.showHorizontalBorders = value;
                      controller.notifyListeners();
                    },
                  ),
                ),
              ],
            ),
            PropertyField(
              label: 'Row Height (${element.rowHeight.toStringAsFixed(0)})',
              child: Slider(
                value: element.rowHeight.clamp(20, 100),
                min: 20,
                max: 100,
                divisions: 80,
                onChanged: (value) {
                  element.rowHeight = value;
                  controller.notifyListeners();
                },
              ),
            ),
            PropertyField(
              label: 'Outer Border Radius',
              child: Slider(
                value: element.outerBorderRadius.clamp(0, 20),
                min: 0,
                max: 20,
                divisions: 20,
                onChanged: (value) {
                  element.outerBorderRadius = value;
                  controller.notifyListeners();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

  import 'package:flutter/material.dart';
import 'package:flutter_poster_maker/editor/editor_controller.dart';

import '../../models/template_element.dart';
import 'common_properties.dart';



class GroupProperties extends StatelessWidget {
 final GroupElement element;
 final   InvoiceEditorController controller;
  const GroupProperties({required this.element,required this.controller,super.key});

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Group',
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${element.children.length} elements',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...element.children.take(5).map((child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(_getTypeIcon(child.type), size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        child.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
              if (element.children.length > 5)
                Text(
                  '... and ${element.children.length - 5} more',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.workspaces_outline, size: 16),
            label: const Text('Ungroup'),
            onPressed: () => controller.ungroupSelected(),
          ),
        ),
      ],
    );
  }
  IconData _getTypeIcon(ElementType type) {
    switch (type) {
      case ElementType.text:
        return Icons.text_fields;
      case ElementType.image:
        return Icons.image;
      case ElementType.table:
        return Icons.table_chart;
      case ElementType.shape:
        return Icons.rectangle_outlined;
      case ElementType.qrCode:
        return Icons.qr_code;
      case ElementType.group:
        return Icons.folder;
      case ElementType.signature:
        return Icons.draw;
      case ElementType.background:
        return Icons.wallpaper;
      case ElementType.svg:
        return Icons.extension;
      case ElementType.productGrid:
        return Icons.grid_view;
      case ElementType.itemTable:
        return Icons.table_rows;
    }
  }


}

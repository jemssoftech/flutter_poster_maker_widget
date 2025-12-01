import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/font_controller.dart';

/// Fonts tab in assets panel
class FontsTab extends StatelessWidget {
  const FontsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return Column(
      children: [
        // Category filter
        _CategoryFilter(),

        // Font list
        Expanded(
          child: Obx(() {
            final fonts = fontController.filteredFonts;

            if (fonts.isEmpty) {
              return _EmptyFonts();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: fonts.length,
              itemBuilder: (context, index) {
                final font = fonts[index];
                return _FontItem(font: font);
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Obx(() => Row(
        children: FontCategory.values.map((category) {
          final isSelected =
              fontController.selectedCategory.value == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (_) => fontController.setCategory(category),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: const Color(0xFF0080FF).withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0080FF)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }
}

class _FontItem extends StatelessWidget {
  final GoogleFontFamily font;

  const _FontItem({required this.font});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => _selectFont(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      font.family,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The quick brown fox jumps...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        // In production, use GoogleFonts.getFont(font.family)
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  fontController.isFavorite(font.family)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 20,
                ),
                color: fontController.isFavorite(font.family)
                    ? Colors.red
                    : Colors.white38,
                onPressed: () => fontController.toggleFavorite(font.family),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectFont() {
    // TODO: Apply font to selected text layer or show font details
    Get.snackbar(
      'Font Selected',
      'Selected ${font.family}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2a2a2a),
      colorText: Colors.white,
    );
  }
}

class _EmptyFonts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.text_fields,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No fonts match your search',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
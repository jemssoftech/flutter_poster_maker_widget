import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/layers/text_layer.dart';
import '../../../presentation/controllers/layer_controller.dart';
import '../../../presentation/controllers/selection_controller.dart';
import '../../../presentation/controllers/font_controller.dart';
import '../shared/section_header.dart';
import '../shared/slider_input.dart';
import '../shared/color_picker.dart';

/// Text properties panel
class TextPropertiesPanel extends StatelessWidget {
  const TextPropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();
    final selectionController = Get.find<SelectionController>();

    return Obx(() {
      final primaryId = selectionController.primaryId;
      if (primaryId == null) {
        return const Center(
          child: Text(
            'Select a text layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      final layer = layerController.getLayerById(primaryId);
      if (layer is! TextLayer) {
        return const Center(
          child: Text(
            'Selected layer is not a text layer',
            style: TextStyle(color: Colors.white54),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content
            const SectionHeader(title: 'Content'),
            _TextContentField(layer: layer),
            const SizedBox(height: 24),

            // Typography
            const SectionHeader(title: 'Typography'),
            _FontFamilySelector(layer: layer),
            const SizedBox(height: 12),
            _FontWeightSelector(layer: layer),
            const SizedBox(height: 12),
            _FontSizeSlider(layer: layer),
            const SizedBox(height: 12),
            _LetterSpacingSlider(layer: layer),
            const SizedBox(height: 12),
            _LineHeightSlider(layer: layer),
            const SizedBox(height: 24),

            // Color
            const SectionHeader(title: 'Color'),
            _TextColorPicker(layer: layer),
            const SizedBox(height: 24),

            // Alignment
            const SectionHeader(title: 'Alignment'),
            _TextAlignmentButtons(layer: layer),
            const SizedBox(height: 24),

            // Style options
            const SectionHeader(title: 'Style'),
            _TextStyleOptions(layer: layer),
          ],
        ),
      );
    });
  }
}

class _TextContentField extends StatefulWidget {
  final TextLayer layer;

  const _TextContentField({required this.layer});

  @override
  State<_TextContentField> createState() => _TextContentFieldState();
}

class _TextContentFieldState extends State<_TextContentField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.layer.text);
  }

  @override
  void didUpdateWidget(_TextContentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layer.text != widget.layer.text) {
      _controller.text = widget.layer.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Enter text...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0080FF)),
        ),
      ),
      onChanged: (value) {
        final layerController = Get.find<LayerController>();
        layerController.updateLayer(widget.layer.id, (layer) {
          return (layer as TextLayer).copyWith(text: value);
        });
      },
    );
  }
}

class _FontFamilySelector extends StatelessWidget {
  final TextLayer layer;

  const _FontFamilySelector({required this.layer});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return GestureDetector(
      onTap: () => _showFontPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                layer.fontFamily,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2a2a2a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FontPickerSheet(layer: layer),
    );
  }
}

class _FontPickerSheet extends StatelessWidget {
  final TextLayer layer;

  const _FontPickerSheet({required this.layer});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();
    final layerController = Get.find<LayerController>();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Font',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final fonts = fontController.filteredFonts;
              return ListView.builder(
                itemCount: fonts.length,
                itemBuilder: (context, index) {
                  final font = fonts[index];
                  final isSelected = font.family == layer.fontFamily;

                  return ListTile(
                    title: Text(
                      font.family,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0080FF)
                            : Colors.white,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF0080FF))
                        : null,
                    onTap: () {
                      layerController.updateLayer(layer.id, (l) {
                        return (l as TextLayer).copyWith(fontFamily: font.family);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FontWeightSelector extends StatelessWidget {
  final TextLayer layer;

  const _FontWeightSelector({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    final weights = [
      (100, 'Thin'),
      (300, 'Light'),
      (400, 'Regular'),
      (500, 'Medium'),
      (600, 'Semi Bold'),
      (700, 'Bold'),
      (900, 'Black'),
    ];

    return DropdownButtonFormField<int>(
      value: layer.fontWeight,
      dropdownColor: const Color(0xFF2a2a2a),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      items: weights.map((w) {
        return DropdownMenuItem<int>(
          value: w.$1,
          child: Text(
            w.$2,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          layerController.updateLayer(layer.id, (l) {
            return (l as TextLayer).copyWith(fontWeight: value);
          });
        }
      },
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final TextLayer layer;

  const _FontSizeSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Size',
      value: layer.fontSize,
      min: 8,
      max: 200,
      divisions: 192,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as TextLayer).copyWith(fontSize: value);
        });
      },
    );
  }
}

class _LetterSpacingSlider extends StatelessWidget {
  final TextLayer layer;

  const _LetterSpacingSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Letter Spacing',
      value: layer.letterSpacing,
      min: -10,
      max: 50,
      divisions: 60,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as TextLayer).copyWith(letterSpacing: value);
        });
      },
    );
  }
}

class _LineHeightSlider extends StatelessWidget {
  final TextLayer layer;

  const _LineHeightSlider({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return SliderInput(
      label: 'Line Height',
      value: layer.paragraph.lineHeight,
      min: 0.5,
      max: 3.0,
      divisions: 25,
      onChanged: (value) {
        layerController.updateLayer(layer.id, (l) {
          return (l as TextLayer).copyWith(
            paragraph: l.paragraph.copyWith(lineHeight: value),
          );
        });
      },
    );
  }
}

class _TextColorPicker extends StatelessWidget {
  final TextLayer layer;

  const _TextColorPicker({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return ColorPickerButton(
      color: layer.color,
      onColorChanged: (color) {
        layerController.updateLayer(layer.id, (l) {
          return (l as TextLayer).copyWith(color: color);
        });
      },
    );
  }
}

class _TextAlignmentButtons extends StatelessWidget {
  final TextLayer layer;

  const _TextAlignmentButtons({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Row(
      children: [
        _AlignButton(
          icon: Icons.format_align_left,
          isSelected: layer.paragraph.alignment == TextAlignmentType.left,
          onTap: () => _setAlignment(layerController, TextAlignmentType.left),
        ),
        const SizedBox(width: 8),
        _AlignButton(
          icon: Icons.format_align_center,
          isSelected: layer.paragraph.alignment == TextAlignmentType.center,
          onTap: () => _setAlignment(layerController, TextAlignmentType.center),
        ),
        const SizedBox(width: 8),
        _AlignButton(
          icon: Icons.format_align_right,
          isSelected: layer.paragraph.alignment == TextAlignmentType.right,
          onTap: () => _setAlignment(layerController, TextAlignmentType.right),
        ),
        const SizedBox(width: 8),
        _AlignButton(
          icon: Icons.format_align_justify,
          isSelected: layer.paragraph.alignment == TextAlignmentType.justify,
          onTap: () => _setAlignment(layerController, TextAlignmentType.justify),
        ),
      ],
    );
  }

  void _setAlignment(LayerController controller, TextAlignmentType alignment) {
    controller.updateLayer(layer.id, (l) {
      return (l as TextLayer).copyWith(
        paragraph: l.paragraph.copyWith(alignment: alignment),
      );
    });
  }
}

class _AlignButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlignButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0080FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0080FF)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
        ),
      ),
    );
  }
}

class _TextStyleOptions extends StatelessWidget {
  final TextLayer layer;

  const _TextStyleOptions({required this.layer});

  @override
  Widget build(BuildContext context) {
    final layerController = Get.find<LayerController>();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StyleToggle(
          icon: Icons.format_bold,
          label: 'Bold',
          isSelected: layer.fontWeight >= 600,
          onTap: () {
            layerController.updateLayer(layer.id, (l) {
              final textLayer = l as TextLayer;
              return textLayer.copyWith(
                fontWeight: textLayer.fontWeight >= 600 ? 400 : 700,
              );
            });
          },
        ),
        _StyleToggle(
          icon: Icons.format_italic,
          label: 'Italic',
          isSelected: layer.fontStyle == 'italic',
          onTap: () {
            layerController.updateLayer(layer.id, (l) {
              final textLayer = l as TextLayer;
              return textLayer.copyWith(
                fontStyle: textLayer.fontStyle == 'italic' ? 'normal' : 'italic',
              );
            });
          },
        ),
        _StyleToggle(
          icon: Icons.format_underlined,
          label: 'Underline',
          isSelected: false, // TODO: implement underline
          onTap: () {},
        ),
        _StyleToggle(
          icon: Icons.text_fields,
          label: 'Uppercase',
          isSelected: layer.textTransform == TextTransform.uppercase,
          onTap: () {
            layerController.updateLayer(layer.id, (l) {
              final textLayer = l as TextLayer;
              return textLayer.copyWith(
                textTransform: textLayer.textTransform == TextTransform.uppercase
                    ? TextTransform.none
                    : TextTransform.uppercase,
              );
            });
          },
        ),
      ],
    );
  }
}

class _StyleToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleToggle({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0080FF).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0080FF)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
          ),
        ),
      ),
    );
  }
}
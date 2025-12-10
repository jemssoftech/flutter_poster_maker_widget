import 'package:flutter/material.dart';

import '../models/background.elements.model.dart';

class BackgroundPresetDialog extends StatefulWidget {
  final BackgroundElement element;
  final Function(BackgroundPreset) onSelect;

  const BackgroundPresetDialog({
    super.key,
    required this.element,
    required this.onSelect,
  });

  @override
  State<BackgroundPresetDialog> createState() => _BackgroundPresetDialogState();
}

class _BackgroundPresetDialogState extends State<BackgroundPresetDialog> {
  String _selectedCategory = 'all';

  List<BackgroundPreset> get _filteredPresets {
    if (_selectedCategory == 'all') {
      return BackgroundPresets.presets;
    }
    return BackgroundPresets.getByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['all', ...BackgroundPresets.categories];

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.collections, color: Colors.blue),
          SizedBox(width: 8),
          Text('Background Presets'),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 450,
        child: Column(
          children: [
            // Category tabs
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat == 'all' ? 'All' : cat.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Preset grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: _filteredPresets.length,
                itemBuilder: (context, index) {
                  final preset = _filteredPresets[index];
                  final isSelected = widget.element.presetId == preset.id;

                  return InkWell(
                    onTap: () {
                      widget.onSelect(preset);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              preset.thumbnailUrl ?? preset.url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                            // Name overlay
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black54],
                                  ),
                                ),
                                child: Text(
                                  preset.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Selected check
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
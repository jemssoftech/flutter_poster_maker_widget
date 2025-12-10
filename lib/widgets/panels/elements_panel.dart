// 📁 lib/widgets/panels/elements_panel.dart
// 📁 lib/widgets/panels/elements_panel.dart

// 📁 lib/widgets/panels/elements_panel.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../editor/editor_controller.dart';
import '../../models/element_models.dart';
import '../../services/elements_service.dart';

class ElementsPanel extends StatefulWidget {
  final InvoiceEditorController controller;

  const ElementsPanel({super.key, required this.controller});

  @override
  State<ElementsPanel> createState() => _ElementsPanelState();
}

class _ElementsPanelState extends State<ElementsPanel> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Floor Data
  List<ElementSection> _sections = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isSearchPress=false;

  // Static Categories
  final List<Map<String, dynamic>> _staticCategories = [
    {'id':2,'name': 'Basic Shapes', 'color': const Color(0xFF7B81EC), 'icon': Icons.category},
    {'id':3,'name': 'Lines', 'color': const Color(0xFF5BCC87), 'icon': Icons.linear_scale},
    {'id':4,'name': 'Illustrations', 'color': const Color(0xFFF5AB4A), 'icon': Icons.brush},
    {'id':5,'name': 'Icons', 'color': const Color(0xFFD680D2), 'icon': Icons.apps},
    // {'id':,'name': 'Images', 'color': const Color(0xFF0E2BEF), 'icon': Icons.image},
    // {'id':,'name': 'Image', 'color': const Color(0xFF6A7CF1), 'icon': Icons.grid_4x4},
    {'id':6,'name': 'Cutout', 'color': const Color(0xFF248EE4), 'icon': Icons.content_cut},
    {'id':8,'name': 'Patterns', 'color': const Color(0xFFE4526D), 'icon': Icons.pattern},
    // {'id':,'name': 'Charts', 'color': const Color(0xFF9CEC7C), 'icon': Icons.bar_chart},
  ];

  @override
  void initState() {
    super.initState();
    _loadFloorData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadFloorData();
    }
  }

  Future<void> _loadFloorData() async {
    if (_isLoading || _currentPage > _totalPages) return;

    setState(() => _isLoading = true);

    // Use fetchFloorElements here
    final response = await ElementsService.fetchFloorElements(_currentPage);

    if (mounted) {
      setState(() {
        _sections.addAll(response.items.cast<ElementSection>());
        _totalPages = response.totalPage;
        _currentPage++;
        _isLoading = false;
      });
    }
  }

  // --- NAVIGATION HELPERS ---

  // 1. Open Category (Closes current, opens new)
  void _openCategory(int index, String name) {
    Navigator.pop(context); // Close current panel
    showModalBottomSheet(
      context: widget.controller.canvasKey.currentContext ?? context, // Use valid context
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ElementsGridPanel(
        controller: widget.controller,
        title: name,
        categoryIndex: _staticCategories[index]['id'], // API Requirement: index + 1
      ),
    );
  }

  // 2. Open View All (Closes current, opens new)
  void _openViewAll(String sectionTitle) {
    Navigator.pop(context); // Close current panel
    showModalBottomSheet(
      context: widget.controller.canvasKey.currentContext ?? context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ElementsGridPanel(
        controller: widget.controller,
        title: sectionTitle,
        searchQuery: sectionTitle, // Pass title as search query
      ),
    );
  }

  // 3. Handle Search
  void _handleSearch(String query) {
    if (query.isEmpty) return;

    // Option A: Open new sheet for search results (Cleanest)
    // Option B: Show grid in current sheet (More complex state management)
    // Going with Option A as it matches the "Category/ViewAll" pattern

    Navigator.pop(context);
    showModalBottomSheet(
      context: widget.controller.canvasKey.currentContext ?? context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ElementsGridPanel(
        controller: widget.controller,
        title: 'Search: "$query"',
        searchQuery: query,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Elements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black),
              textInputAction: TextInputAction.search,
              onSubmitted: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search Elements',
                // prefixIcon: const Icon(Icons.netw, color: Colors.grey),
                suffixIcon:  IconButton(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  onPressed: () {
                    _handleSearch(_searchController.text);
                    // _searchController.clear();
                    // setState(() {}); // Refresh to hide suffix icon
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() {}), // Rebuild to show/hide clear btn
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static Categories
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _staticCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = _staticCategories[index];
                        return GestureDetector(
                          onTap: () => _openCategory(index, cat['name']),
                          child: _buildCategoryCard(cat),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sections.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _sections.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return _buildSection(_sections[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: category['color'],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(category['icon'], color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            category['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(ElementSection section) {
    // Filter out json stickers from display locally as well, just in case
    final validStickers = section.stickers
        .where((s) => s.type.toLowerCase() != 'json')
        .toList();

    if (validStickers.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _openViewAll(section.title),
                child: Row(
                  children: const [
                    Text('See all', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: validStickers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildStickerItem(validStickers[index]);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStickerItem(ElementSticker sticker) {
    bool isSvg=sticker.thumbUrl.endsWith('.svg');
    return GestureDetector(
      onTap: () {
        if (isSvg) {
          widget.controller.addSvgFromUrl(sticker.fileUrl);
          Navigator.pop(context);
        }else if(sticker.fileUrl.endsWith('.jpg')||sticker.fileUrl.endsWith('.png')||sticker.fileUrl.endsWith('.jpeg')){
          widget.controller.addImage(url: sticker.fileUrl);
          Navigator.pop(context);
        }else{
          widget.controller.addImage(url: sticker.thumbUrl);
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSvg?SvgPicture.network(
          sticker.thumbUrl,
          fit: BoxFit.contain,
          errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
        ):Image.network(
          sticker.thumbUrl,
          fit: BoxFit.contain,
          loadingBuilder: (ctx, child, loading) {
            if (loading == null) return child;
            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
          },
          errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}

class ElementsGridPanel extends StatefulWidget {
  final InvoiceEditorController controller;
  final String title;
  final String? searchQuery;
  final int? categoryIndex;

  const ElementsGridPanel({
    super.key,
    required this.controller,
    required this.title,
    this.searchQuery,
    this.categoryIndex,
  });

  @override
  State<ElementsGridPanel> createState() => _ElementsGridPanelState();
}

class _ElementsGridPanelState extends State<ElementsGridPanel> {
  final ScrollController _scrollController = ScrollController();
  final List<ElementSticker> _stickers = [];

  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading || _currentPage > _totalPages) return;

    log('_loadData ${_currentPage}');
    setState(() => _isLoading = true);

    try {
      final response = await ElementsService.searchElements(
        query: widget.searchQuery ?? '',
        categoryIndex: widget.categoryIndex,
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          _stickers.addAll(response.items.cast<ElementSticker>());
          _totalPages = response.totalPage;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Grid Load Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: (){

      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration:  BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance back button
                ],
              ),
            ),
            const Divider(height: 1),

            // Grid Content
            Expanded(
              child: _stickers.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _stickers.isEmpty
                  ? const Center(child: Text("No elements found"))
                  : GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 items per row
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _stickers.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _stickers.length) {
                    return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                  }
                  return _buildStickerItem(_stickers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerItem(ElementSticker sticker) {
    bool isSvg=sticker.thumbUrl.endsWith('.svg');
    return GestureDetector(
      onTap: () {
        if (isSvg) {
          widget.controller.addSvgFromUrl(sticker.fileUrl);
          Navigator.pop(context);
        }else if(sticker.fileUrl.endsWith('.jpg')||sticker.fileUrl.endsWith('.png')||sticker.fileUrl.endsWith('.jpeg')){
          widget.controller.addImage(url: sticker.fileUrl);
          Navigator.pop(context);
        }else{
          widget.controller.addImage(url: sticker.thumbUrl);
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: isSvg?
        SvgPicture.network(
          sticker.thumbUrl,
          fit: BoxFit.contain,
          errorBuilder: (c,ob,st) {
            log(sticker.thumbUrl);
            return const Icon(Icons.error_outline, size: 20, color: Colors.grey);
          },
        ):Image.network(
          sticker.thumbUrl,
          fit: BoxFit.contain,
          errorBuilder: (c,ob,st) {
            log(sticker.thumbUrl);
            return const Icon(Icons.error_outline, size: 20, color: Colors.grey);
          },
        ),
      ),
    );
  }
}
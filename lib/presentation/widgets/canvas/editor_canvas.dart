import 'dart:ui' show Size;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/canvas_controller.dart';
import '../../../presentation/controllers/poster_controller.dart';
import '../../../presentation/controllers/ui_controller.dart';
import 'canvas_viewport.dart';
import 'canvas_grid.dart';
import 'canvas_guides.dart';
import 'canvas_rulers.dart';

/// Main editor canvas widget
/// Orchestrates viewport, grid, guides, and other canvas elements
class EditorCanvas extends StatelessWidget {
  const EditorCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final canvasController = Get.find<CanvasController>();
    final posterController = Get.find<PosterController>();
    final uiController = Get.find<UIController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Update viewport size
        WidgetsBinding.instance.addPostFrameCallback((_) {
          canvasController.setViewportSize(
            Size(constraints.maxWidth, constraints.maxHeight),
          );

          // Initialize canvas if we have a document
          if (posterController.hasDocument) {
            final posterSize = posterController.canvasSize;
            canvasController.setCanvasSize(posterSize);
          }
        });

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: const Color(0xFF1a1a1a), // Dark background
          child: Stack(
            children: [
              // Main canvas viewport with pan/zoom
              const CanvasViewport(),

              // Grid overlay
              Obx(() => uiController.showGrid.value
                  ? const CanvasGrid()
                  : const SizedBox.shrink()),

              // Rulers
              Obx(() => uiController.showRulers.value
                  ? const CanvasRulers()
                  : const SizedBox.shrink()),

              // Snap guides
              Obx(() => uiController.showGuides.value
                  ? const CanvasGuides()
                  : const SizedBox.shrink()),

              // Zoom controls overlay (bottom-right)
              Positioned(
                right: 16,
                bottom: 16,
                child: _ZoomControls(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Zoom controls widget
class _ZoomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final canvasController = Get.find<CanvasController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom out
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: canvasController.zoomOut,
            tooltip: 'Zoom Out',
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          const SizedBox(width: 4),

          // Zoom percentage
          Obx(() => GestureDetector(
            onTap: canvasController.zoomTo100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${canvasController.zoomPercentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )),

          const SizedBox(width: 4),

          // Zoom in
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: canvasController.zoomIn,
            tooltip: 'Zoom In',
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.white24),
          const SizedBox(width: 8),

          // Fit to screen
          IconButton(
            icon: const Icon(Icons.fit_screen, color: Colors.white),
            onPressed: canvasController.zoomToFit,
            tooltip: 'Fit to Screen',
            iconSize: 20,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
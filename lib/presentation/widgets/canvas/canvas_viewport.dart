import 'dart:ui' show Offset;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../presentation/controllers/canvas_controller.dart';
import '../../../presentation/controllers/tool_controller.dart';
import 'poster_canvas.dart';

/// Canvas viewport with pan/zoom interaction
class CanvasViewport extends StatefulWidget {
  const CanvasViewport({super.key});

  @override
  State<CanvasViewport> createState() => _CanvasViewportState();
}

class _CanvasViewportState extends State<CanvasViewport> {
  final canvasController = Get.find<CanvasController>();
  final toolController = Get.find<ToolController>();

  Offset? _lastFocalPoint;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Stack(
          children: [
            // Main poster canvas
            Obx(() {
              final transform = canvasController.transformMatrix;
              return Transform(
                transform: transform,
                child: const PosterCanvas(),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Handle mouse wheel for zoom
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Ctrl/Cmd + scroll for zoom
      if (HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed) {
        final delta = event.scrollDelta.dy;
        final zoom = canvasController.zoom.value;
        final newZoom = zoom - (delta * 0.001);

        canvasController.setZoom(
          newZoom,
          focalPoint: event.localPosition,
        );
      }
      // Regular scroll for pan
      else {
        canvasController.pan(-event.scrollDelta);
      }
    }
  }

  /// Handle scale/pan start
  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint as Offset?;

    // Start panning if in pan mode
    if (toolController.isHandTool) {
      canvasController.startPan(details.focalPoint);
    }
  }

  /// Handle scale/pan update
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Handle zoom (pinch gesture or trackpad pinch)
    if (details.scale != 1.0) {
      canvasController.setZoom(
        canvasController.zoom.value * details.scale,
        focalPoint: details.focalPoint,
      );
    }
    // Handle pan
    else if (toolController.isHandTool || details.pointerCount > 1) {
      canvasController.updatePan(details.focalPoint);
    }

    _lastFocalPoint = details.focalPoint as Offset?;
  }

  /// Handle scale/pan end
  void _handleScaleEnd(ScaleEndDetails details) {
    if (canvasController.isPanning.value) {
      canvasController.endPan();
    }
    _lastFocalPoint = null;
  }
}
import 'dart:ui' show Offset, Size, Rect;

import 'package:flutter/material.dart' show Matrix4;
import 'package:get/get.dart';

import '../../core/constants/editor_constants.dart';

/// Controller for canvas viewport state (pan/zoom)
class CanvasController extends GetxController {
  // ==================== Reactive State ====================

  /// Current zoom level (1.0 = 100%)
  final RxDouble zoom = 1.0.obs;

  /// Pan offset in screen coordinates
  final Rx<Offset> panOffset = Offset.zero.obs;

  /// Whether currently panning
  final RxBool isPanning = false.obs;

  /// Viewport size (container size)
  final Rx<Size> viewportSize = const Size(0, 0).obs;

  /// Canvas size (actual poster size)
  final Rx<Size> _canvasSize = const Size(1080, 1920).obs;

  // ==================== Internal State ====================

  /// Pan start position
  Offset? _panStart;

  /// Initial offset when pan started
  Offset? _initialPanOffset;

  // ==================== Constants ====================

  /// Minimum zoom level
  static const double minZoom = EditorConstants.minZoom;

  /// Maximum zoom level
  static const double maxZoom = EditorConstants.maxZoom;

  /// Zoom step for buttons
  static const double zoomStep = EditorConstants.zoomStep;

  // ==================== Getters ====================

  /// Get canvas size
  Size get canvasSize => _canvasSize.value;

  /// Get current zoom percentage
  int get zoomPercentage => (zoom.value * 100).round();

  /// Get fit-to-view zoom level
  double get fitZoom {
    if (viewportSize.value.width == 0 || viewportSize.value.height == 0) {
      return 1.0;
    }

    final widthRatio = viewportSize.value.width / canvasSize.width;
    final heightRatio = viewportSize.value.height / canvasSize.height;

    // Use smaller ratio with some padding
    return (widthRatio < heightRatio ? widthRatio : heightRatio) * 0.9;
  }

  /// Get transformation matrix for canvas
  Matrix4 get transformMatrix {
    final matrix = Matrix4.identity();
    matrix.translate(panOffset.value.dx, panOffset.value.dy);
    matrix.scale(zoom.value, zoom.value);
    return matrix;
  }

  /// Get visible rect in canvas coordinates
  Rect get visibleRect {
    final scale = zoom.value;
    final topLeft = screenToCanvas(Offset.zero);
    final bottomRight = screenToCanvas(
      Offset(viewportSize.value.width, viewportSize.value.height),
    );
    return Rect.fromPoints(topLeft, bottomRight);
  }

  // ==================== Coordinate Conversion ====================

  /// Convert screen coordinates to canvas coordinates
  Offset screenToCanvas(Offset screenPoint) {
    return Offset(
      (screenPoint.dx - panOffset.value.dx) / zoom.value,
      (screenPoint.dy - panOffset.value.dy) / zoom.value,
    );
  }

  /// Convert canvas coordinates to screen coordinates
  Offset canvasToScreen(Offset canvasPoint) {
    return Offset(
      canvasPoint.dx * zoom.value + panOffset.value.dx,
      canvasPoint.dy * zoom.value + panOffset.value.dy,
    );
  }

  // ==================== Zoom Operations ====================

  /// Set zoom level
  void setZoom(double value, {Offset? focalPoint}) {
    final newZoom = value.clamp(minZoom, maxZoom);

    if (focalPoint != null) {
      // Zoom towards focal point
      final canvasPoint = screenToCanvas(focalPoint);
      zoom.value = newZoom;

      // Adjust pan to keep focal point in same place
      final newScreenPoint = canvasToScreen(canvasPoint);
      final delta = focalPoint - newScreenPoint;
      panOffset.value = panOffset.value + delta;
    } else {
      // Zoom towards center
      final center = Offset(
        viewportSize.value.width / 2,
        viewportSize.value.height / 2,
      );
      final canvasPoint = screenToCanvas(center);
      zoom.value = newZoom;

      final newScreenPoint = canvasToScreen(canvasPoint);
      final delta = center - newScreenPoint;
      panOffset.value = panOffset.value + delta;
    }
  }

  /// Zoom in by step
  void zoomIn({Offset? focalPoint}) {
    setZoom(zoom.value + zoomStep, focalPoint: focalPoint);
  }

  /// Zoom out by step
  void zoomOut({Offset? focalPoint}) {
    setZoom(zoom.value - zoomStep, focalPoint: focalPoint);
  }

  /// Zoom to 100%
  void zoomTo100() {
    setZoom(1.0);
    centerCanvas();
  }

  /// Zoom to fit canvas in viewport
  void zoomToFit() {
    setZoom(fitZoom);
    centerCanvas();
  }

  /// Zoom to fill viewport
  void zoomToFill() {
    if (viewportSize.value.width == 0 || viewportSize.value.height == 0) return;

    final widthRatio = viewportSize.value.width / canvasSize.width;
    final heightRatio = viewportSize.value.height / canvasSize.height;

    setZoom(widthRatio > heightRatio ? widthRatio : heightRatio);
    centerCanvas();
  }

  // ==================== Pan Operations ====================

  /// Start panning
  void startPan(Offset position) {
    _panStart = position;
    _initialPanOffset = panOffset.value;
    isPanning.value = true;
  }

  /// Update pan
  void updatePan(Offset position) {
    if (!isPanning.value || _panStart == null || _initialPanOffset == null) return;

    final delta = position - _panStart!;
    panOffset.value = _initialPanOffset! + delta;
  }

  /// End panning
  void endPan() {
    _panStart = null;
    _initialPanOffset = null;
    isPanning.value = false;
  }

  /// Pan by delta
  void pan(Offset delta) {
    panOffset.value = panOffset.value + delta;
  }

  /// Pan to specific position
  void panTo(Offset position) {
    panOffset.value = position;
  }

  /// Center canvas in viewport
  void centerCanvas() {
    if (viewportSize.value.width == 0 || viewportSize.value.height == 0) return;

    final scaledWidth = canvasSize.width * zoom.value;
    final scaledHeight = canvasSize.height * zoom.value;

    panOffset.value = Offset(
      (viewportSize.value.width - scaledWidth) / 2,
      (viewportSize.value.height - scaledHeight) / 2,
    );
  }

  // ==================== Setup ====================

  /// Set viewport size
  void setViewportSize(Size size) {
    viewportSize.value = size;
  }

  /// Set canvas size
  void setCanvasSize(Size size) {
    _canvasSize.value = size;
  }

  /// Initialize with viewport and canvas sizes
  void initialize(Size viewport, Size canvas) {
    viewportSize.value = viewport;
    _canvasSize.value = canvas;
    zoomToFit();
  }

  /// Reset to default state
  void reset() {
    zoom.value = 1.0;
    panOffset.value = Offset.zero;
    isPanning.value = false;
    _panStart = null;
    _initialPanOffset = null;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
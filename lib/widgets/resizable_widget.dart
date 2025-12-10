
// ============================================================================
// 📁 FILE: resizable_widget.dart (MOBILE-FIRST REFACTOR v3)
// 📍 PATH: /lib/widgets/common/resizable_widget.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../models/template_element.dart';
import '../models/background.elements.model.dart';

class ResizableWidget extends StatefulWidget {
  final TemplateElement element;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onSelect;
  final Function(Offset delta) onMove;
  final Function(Size newSize, double scaleX, double scaleY) onResize;
  final Function(double newRotation) onRotate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  final Function(String action)? onArrange; // 'front', 'back', 'forward', 'backward'
  final Widget child;
  final Function(String newText)? onTextChanged; // New callback for inline editing

  const ResizableWidget({
    super.key,
    required this.element,
    required this.isSelected,
    required this.isLocked,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
    required this.onRotate,
    required this.onEdit,
    required this.onDelete,
    this.onDuplicate,
    this.onArrange,
    required this.child,
    this.onTextChanged,
  });

  @override
  State<ResizableWidget> createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  // Standard touch target size (48x48 - Material Design Guidelines)
  static const double _minTouchTargetSize = 48.0;
  static const double _handleSizeDesktop = 30.0;
  static const double _handleSizeMobile = 48.0;
  static const double _minElementSize = 20.0;
  static const double _maxElementSize = 2000.0;

  // Get responsive handle size based on screen width
  double get _handleSize {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600 ? _handleSizeMobile : _handleSizeDesktop;
  }

  // Get whether this is a mobile device (screen width < 600px)
  bool get _isMobile {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600;
  }

  // Drag state
  bool _isDragging = false;

  List<bool> _isSideHandleActive = <bool>[]; // Track each side handle individually
  bool _isScaleHandleActive = false;
  bool _isRotateHandleActive = false;


  // Double-tap tracking for text editing
  int? _lastTapTime;
  // Scale state (for corner handle)
  Offset? _scaleStartPoint;
  Size? _initialSize;
  Size? _lastSize; // Track last size for delta calculation
  Offset? _initialPosition; // Track initial position for side handles

  // Pinch-to-scale state (for gesture on element)
  Size? _pinchInitialSize;
  Offset? _pinchInitialFocalPoint;
  bool _isPinching = false;
  Size? _pinchLastSize; // Track last size for delta calculation
  double? _pinchLastScale; // Track last scale value

  // Rotate state
  Offset? _rotateCenter;
  double? _initialAngle;
  double? _initialRotation;
  @override
  void initState() {
    super.initState();
    _isSideHandleActive = List.filled(4, false); // top, bottom, left, right
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleDoubleTap() {
    // DISABLED: Inline editing causes 10x scaling bug
    // Instead, open a popup modal for text editing
    if (widget.element is TextElement && !widget.isLocked) {
      _showTextEditDialog();
    }
  }

  void _showTextEditDialog() {
    final textElement = widget.element as TextElement;
    final controller = TextEditingController(text: textElement.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Text'),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            maxLines: 5,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter text...',
              border: OutlineInputBorder(),
            ),
            style: TextStyle(
              // fontSize: textElement.fontSize,
              fontFamily: textElement.fontFamily,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onTextChanged != null) {
                widget.onTextChanged!(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentWidth = widget.element.size.width;
    final contentHeight = widget.element.size.height;
    // Calculate the total space needed to include handle areas
    final totalWidth = contentWidth + _handleSize;
    final totalHeight = contentHeight + _handleSize;

    return Transform.rotate(
      angle: widget.element.rotation * (math.pi / 180),
      alignment: Alignment.center,
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main content area
            Positioned(
              left: _handleSize / 2,
              top: _handleSize / 2,
              child: GestureDetector(
                onTap: () {
                  // Handle double-tap detection for inline editing
                  final now = DateTime.now().millisecondsSinceEpoch;
                  if (_lastTapTime != null && (now - _lastTapTime!) < 500 && widget.element is TextElement) {
                    // Double tap detected on text element
                    _handleDoubleTap();
                    _lastTapTime = null;
                  } else {
                    _lastTapTime = now;
                    // Support Shift+Click for multi-selection
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      // Toggle this element in selection
                      widget.onSelect(); // This will be handled by controller with addToSelection logic
                    } else {
                      widget.onSelect();
                    }
                  }
                },
                // Use onScale callbacks to support both drag and pinch-to-scale
                onScaleStart: widget.isLocked ? null : _onPinchScaleStart,
                onScaleUpdate: widget.isLocked ? null : _onPinchScaleUpdate,
                onScaleEnd: widget.isLocked ? null : _onPinchScaleEnd,
                child: MouseRegion(
                  cursor: widget.isLocked ? SystemMouseCursors.forbidden : SystemMouseCursors.move,
                  child: CustomPaint(
                    foregroundPainter: widget.isSelected
                        ? _DashedBorderPainter(
                      color: widget.isLocked ? Colors.orange : Colors.blue,
                      strokeWidth: _isMobile ? 1.0 : 2.0,
                      dashPattern: [5, 5],
                    )
                        : null,
                    child: SizedBox(
                      // FIX: CRITICAL - Use SizedBox for EXACT size, no decoration padding
                      width: contentWidth,
                      height: contentHeight,
                      // FIX: NO Container, NO ClipRect, NO Decoration that adds space
                      // Content must fill exactly to the dashed border
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),

            // Action Handles (only when selected and not locked)
            // Using BigTouchTarget wrapper for all handles
            if (widget.isSelected && !widget.isLocked) ...[
              // Top-Left: Three-dot menu (positioned at top-left corner of content)
              Positioned(
                left: _handleSize / 2 - 24, // Centered in 48px touch area
                top: _handleSize / 2 - 24,  // Centered in 48px touch area
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  child: _ThreeDotMenuButton(
                    element: widget.element,
                    onEdit: widget.element is TextElement ? _handleDoubleTap : widget.onEdit,
                    onDelete: widget.onDelete,
                    onDuplicate: widget.onDuplicate,
                    onArrange: widget.onArrange,
                  ),
                ),
              ),

              // Top-Right: Rotate Handle (positioned at top-right corner of content)
              Positioned(
                left: _handleSize / 2 + contentWidth - 12,
                top: _handleSize / 2 - 24, // Centered in 48px touch area
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isRotateHandleActive = active),
                  child: _RotateHandle(
                    onRotateStart: _onRotateStart,
                    onRotateUpdate: _onRotateUpdate,
                    onRotateEnd: _onRotateEnd,
                  ),
                ),
              ),

              // Bottom-Right: Scale Handle (positioned at bottom-right corner of content)
              Positioned(
                left: _handleSize / 2 + contentWidth - 12,
                top: _handleSize / 2 + contentHeight - 12,
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isScaleHandleActive = active),
                  child: _ScaleHandle(
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                  ),
                ),
              ),

              // NEW: Side Handles (Top, Bottom, Left, Right)
              // Top Center Handle
              Positioned(
                left: _handleSize / 2 + contentWidth / 2 - 12, // Center horizontally
                top: _handleSize / 2 - 24, // Centered in 48px touch area
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isSideHandleActive[0] = active),
                  child: _SideHandle(
                    direction: _HandleDirection.top,
                    onScaleStart: _onSideScaleStart,
                    onScaleUpdate: _onSideScaleUpdate,
                    onScaleEnd: _onSideScaleEnd,
                    isMobile: _isMobile,
                  ),
                ),
              ),

              // Bottom Center Handle
              Positioned(
                left: _handleSize / 2 + contentWidth / 2 - 12, // Center horizontally
                top: _handleSize / 2 + contentHeight - 12, // Centered in 48px touch area
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isSideHandleActive[1] = active),
                  child: _SideHandle(
                    direction: _HandleDirection.bottom,
                    onScaleStart: _onSideScaleStart,
                    onScaleUpdate: _onSideScaleUpdate,
                    onScaleEnd: _onSideScaleEnd,
                    isMobile: _isMobile,
                  ),
                ),
              ),

              // Left Center Handle
              Positioned(
                left: _handleSize / 2 - 24, // Centered in 48px touch area
                top: _handleSize / 2 + contentHeight / 2 - 12, // Center vertically
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isSideHandleActive[2] = active),
                  child: _SideHandle(
                    direction: _HandleDirection.left,
                    onScaleStart: _onSideScaleStart,
                    onScaleUpdate: _onSideScaleUpdate,
                    onScaleEnd: _onSideScaleEnd,
                    isMobile: _isMobile,
                  ),
                ),
              ),

              // Right Center Handle
              Positioned(
                left: _handleSize / 2 + contentWidth - 12, // Centered in 48px touch area
                top: _handleSize / 2 + contentHeight / 2 - 12, // Center vertically
                child: _BigTouchTarget(
                  size: _minTouchTargetSize,
                  onPressed: (active) => setState(() => _isSideHandleActive[3] = active),
                  child: _SideHandle(
                    direction: _HandleDirection.right,
                    onScaleStart: _onSideScaleStart,
                    onScaleUpdate: _onSideScaleUpdate,
                    onScaleEnd: _onSideScaleEnd,
                    isMobile: _isMobile,
                  ),
                ),
              ),
            ],

            // Lock Icon (when locked and selected)
            if (widget.isLocked && widget.isSelected)
              Positioned(
                left: _handleSize / 2 + contentWidth - _handleSize,
                top: _handleSize / 2,
                child: Container(
                  width: _handleSize,
                  height: _handleSize,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== PINCH-TO-SCALE & DRAG (MOVE) ====================

  void _onPinchScaleStart(ScaleStartDetails details) {
    _pinchInitialFocalPoint = details.focalPoint;
    _pinchInitialSize = widget.element.size;
    _pinchLastSize = widget.element.size; // Initialize for delta tracking
    _pinchLastScale = 1.0; // Initialize scale tracking
    _isDragging = false;
    _isPinching = false;
  }

  void _onPinchScaleUpdate(ScaleUpdateDetails details) {
    // Determine if this is a pinch gesture or a drag gesture
    // Scale close to 1.0 (0.95 to 1.05) = likely dragging
    // Scale outside this range = pinching
    final scaleDelta = (details.scale - 1.0).abs();

    if (scaleDelta > 0.05) {
      // This is a pinch gesture (two-finger scale)
      _isPinching = true;
      _isDragging = false;

      if (_pinchInitialSize != null && _pinchLastSize != null && _pinchLastScale != null && widget.isSelected) {
        // Calculate new size based on scale factor
        double newWidth = (_pinchInitialSize!.width * details.scale)
            .clamp(_minElementSize, _maxElementSize);
        double newHeight = (_pinchInitialSize!.height * details.scale)
            .clamp(_minElementSize, _maxElementSize);

        // Calculate INCREMENTAL (delta) scale factors relative to last frame
        // This prevents exponential growth
        double deltaScaleX = newWidth / _pinchLastSize!.width;
        double deltaScaleY = newHeight / _pinchLastSize!.height;

        // Update tracking for next frame
        _pinchLastSize = Size(newWidth, newHeight);
        _pinchLastScale = details.scale;

        // If this is a TextElement with autoSize disabled, proportionally adjust the fontSize
        if (widget.element is TextElement) {
          final textElement = widget.element as TextElement;
          if (!textElement.autoSize) {
            // Calculate proportional font size change based on the larger scale factor to ensure text fits
            final scaleChange = math.max(deltaScaleX, deltaScaleY);
            final newFontSize = textElement.fontSize * scaleChange;
            textElement.fontSize = newFontSize.clamp(8.0, 200.0); // Limit min/max font size
          }
        }

        // Apply resize with delta scale
        widget.onResize(Size(newWidth, newHeight), deltaScaleX, deltaScaleY);
      }
    } else {
      // This is a drag gesture (single-finger move)
      if (!_isPinching) {
        // Only start dragging if we haven't detected pinching
        if (!_isDragging && _pinchInitialFocalPoint != null) {
          final distance = (details.focalPoint - _pinchInitialFocalPoint!).distance;
          if (distance > 6.0) {
            _isDragging = true;
          }
        }

        if (_isDragging) {
          // Apply rotation-adjusted movement
          final angle = widget.element.rotation * (math.pi / 180);
          final cos = math.cos(angle);
          final sin = math.sin(angle);
          final adjustedDelta = Offset(
            details.focalPointDelta.dx * cos + details.focalPointDelta.dy * sin,
            -details.focalPointDelta.dx * sin + details.focalPointDelta.dy * cos,
          );
          widget.onMove(adjustedDelta);
        }
      }
    }
  }

  void _onPinchScaleEnd(ScaleEndDetails details) {
    _pinchInitialFocalPoint = null;
    _pinchInitialSize = null;
    _pinchLastSize = null; // Reset delta tracking
    _pinchLastScale = null;
    _isDragging = false;
    _isPinching = false;
  }

  // ==================== SCALE ====================

  void _onScaleStart(DragStartDetails details) {
    _scaleStartPoint = details.globalPosition;
    _initialSize = widget.element.size;
    _lastSize = widget.element.size; // Initialize last size for delta tracking
    setState(() {
      _isScaleHandleActive = true;
    });
  }

  void _onScaleUpdate(DragUpdateDetails details) {
    if (_scaleStartPoint == null || _initialSize == null || _lastSize == null) return;

    final delta = details.globalPosition - _scaleStartPoint!;

    // Rotate delta based on element rotation for correct scaling direction
    final angle = -widget.element.rotation * (math.pi / 180);
    final cos = math.cos(angle);
    final sin = math.sin(angle);

    final rotatedDelta = Offset(
      delta.dx * cos - delta.dy * sin,
      delta.dx * sin + delta.dy * cos,
    );

    // Calculate new size
    double newWidth = (_initialSize!.width + rotatedDelta.dx).clamp(_minElementSize, _maxElementSize);
    double newHeight = (_initialSize!.height + rotatedDelta.dy).clamp(_minElementSize, _maxElementSize);

    // Calculate INCREMENTAL (delta) scale factors relative to last frame
    // This prevents exponential growth - we only scale by the change since last update
    double deltaScaleX = newWidth / _lastSize!.width;
    double deltaScaleY = newHeight / _lastSize!.height;

    // Update last size for next frame
    _lastSize = Size(newWidth, newHeight);

    // If this is a TextElement with autoSize disabled, proportionally adjust the fontSize
    if (widget.element is TextElement) {
      final textElement = widget.element as TextElement;
      if (!textElement.autoSize) {
        // Calculate proportional font size change based on the larger scale factor to ensure text fits
        final scaleChange = math.max(deltaScaleX, deltaScaleY);
        final newFontSize = textElement.fontSize * scaleChange;
        textElement.fontSize = newFontSize.clamp(8.0, 200.0); // Limit min/max font size
      }
    }

    widget.onResize(Size(newWidth, newHeight), deltaScaleX, deltaScaleY);
  }

  void _onScaleEnd(DragEndDetails details) {
    _scaleStartPoint = null;
    _initialSize = null;
    _lastSize = null; // Reset last size
    setState(() {
      _isScaleHandleActive = false;
    });
  }

  // ==================== SIDE HANDLES (Top, Bottom, Left, Right) ====================

  void _onSideScaleStart(DragStartDetails details, _HandleDirection direction) {
    _scaleStartPoint = details.globalPosition;
    _initialSize = widget.element.size;
    _lastSize = widget.element.size;
    _initialPosition = widget.element.position;
  }

  void _onSideScaleUpdate(DragUpdateDetails details, _HandleDirection direction) {
    if (_scaleStartPoint == null || _initialSize == null || _lastSize == null || _initialPosition == null) return;

    final delta = details.globalPosition - _scaleStartPoint!;

    // Rotate delta based on element rotation for correct scaling direction
    final angle = -widget.element.rotation * (math.pi / 180);
    final cos = math.cos(angle);
    final sin = math.sin(angle);

    final rotatedDelta = Offset(
      delta.dx * cos - delta.dy * sin,
      delta.dx * sin + delta.dy * cos,
    );

    double newWidth = _initialSize!.width;
    double newHeight = _initialSize!.height;
    Offset positionDelta = Offset.zero;

    // Calculate new size and position based on handle direction
    switch (direction) {
      case _HandleDirection.top:
      // Only change height, adjust Y position
        newHeight = (_initialSize!.height - rotatedDelta.dy).clamp(_minElementSize, _maxElementSize);
        final heightChange = newHeight - _initialSize!.height;
        positionDelta = Offset(0, -heightChange);
        break;

      case _HandleDirection.bottom:
      // Only change height, no position change
        newHeight = (_initialSize!.height + rotatedDelta.dy).clamp(_minElementSize, _maxElementSize);
        break;

      case _HandleDirection.left:
      // Only change width, adjust X position
        newWidth = (_initialSize!.width - rotatedDelta.dx).clamp(_minElementSize, _maxElementSize);
        final widthChange = newWidth - _initialSize!.width;
        positionDelta = Offset(-widthChange, 0);
        break;

      case _HandleDirection.right:
      // Only change width, no position change
        newWidth = (_initialSize!.width + rotatedDelta.dx).clamp(_minElementSize, _maxElementSize);
        break;
    }

    // Calculate INCREMENTAL (delta) scale factors relative to last frame
    double deltaScaleX = newWidth / _lastSize!.width;
    double deltaScaleY = newHeight / _lastSize!.height;

    // Update last size for next frame
    _lastSize = Size(newWidth, newHeight);

    // If this is a TextElement with autoSize disabled, proportionally adjust the fontSize
    if (widget.element is TextElement) {
      final textElement = widget.element as TextElement;
      if (!textElement.autoSize) {
        // Calculate proportional font size change based on the larger scale factor to ensure text fits
        final scaleChange = math.max(deltaScaleX, deltaScaleY);
        final newFontSize = textElement.fontSize * scaleChange;
        textElement.fontSize = newFontSize.clamp(8.0, 200.0); // Limit min/max font size
      }
    }

    // Apply position change if needed (for top/left handles)
    if (positionDelta != Offset.zero) {
      widget.element.position = _initialPosition! + positionDelta;
    }

    widget.onResize(Size(newWidth, newHeight), deltaScaleX, deltaScaleY);
  }

  void _onSideScaleEnd(DragEndDetails details) {
    _scaleStartPoint = null;
    _initialSize = null;
    _lastSize = null;
    _initialPosition = null;
  }

  // ==================== ROTATE ====================

  void _onRotateStart(DragStartDetails details) {
    // Get the center of the widget in global coordinates
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final size = box.size;
      _rotateCenter = box.localToGlobal(Offset(size.width / 2, size.height / 2));
    }

    if (_rotateCenter != null) {
      // Calculate initial angle from center to touch point
      final offset = details.globalPosition - _rotateCenter!;
      _initialAngle = math.atan2(offset.dy, offset.dx);
      _initialRotation = widget.element.rotation;
    }
  }

  void _onRotateUpdate(DragUpdateDetails details) {
    if (_rotateCenter == null || _initialAngle == null || _initialRotation == null) return;

    // Calculate current angle from center to touch point
    final offset = details.globalPosition - _rotateCenter!;
    final currentAngle = math.atan2(offset.dy, offset.dx);

    // Calculate rotation delta in degrees
    double angleDelta = (currentAngle - _initialAngle!) * (180 / math.pi);

    // Calculate new rotation
    double newRotation = _initialRotation! + angleDelta;

    // Normalize to -180 to 180
    while (newRotation > 180) newRotation -= 360;
    while (newRotation < -180) newRotation += 360;

    widget.onRotate(newRotation);
  }

  void _onRotateEnd(DragEndDetails details) {
    _rotateCenter = null;
    _initialAngle = null;
    _initialRotation = null;
  }
}

/// Big Touch Target Wrapper
/// Provides a large touch area (48x48) around a smaller visual widget
class _BigTouchTarget extends StatefulWidget {
  final Widget child;
  final double size;
  final Function(bool active)? onPressed;

  const _BigTouchTarget({
    required this.child,
    this.size = 48.0,
    this.onPressed,
  });

  @override
  State<_BigTouchTarget> createState() => _BigTouchTargetState();
}

class _BigTouchTargetState extends State<_BigTouchTarget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.blue.withOpacity(0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_isPressed) {
      _isPressed = true;
      widget.onPressed?.call(true);
      _controller.forward();
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      widget.onPressed?.call(false);
      _controller.reverse();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_isPressed) {
      _isPressed = false;
      widget.onPressed?.call(false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }



}

/// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Scale Handle Widget
class _ScaleHandle extends StatelessWidget {
  final Function(DragStartDetails) onScaleStart;
  final Function(DragUpdateDetails) onScaleUpdate;
  final Function(DragEndDetails) onScaleEnd;

  const _ScaleHandle({
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Drag to resize',
      child: GestureDetector(
        onPanStart: onScaleStart,
        onPanUpdate: onScaleUpdate,
        onPanEnd: onScaleEnd,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeDownRight,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.open_in_full,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Rotate Handle Widget
class _RotateHandle extends StatelessWidget {
  final Function(DragStartDetails) onRotateStart;
  final Function(DragUpdateDetails) onRotateUpdate;
  final Function(DragEndDetails) onRotateEnd;

  const _RotateHandle({
    required this.onRotateStart,
    required this.onRotateUpdate,
    required this.onRotateEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Drag to rotate',
      child: GestureDetector(
        onPanStart: onRotateStart,
        onPanUpdate: onRotateUpdate,
        onPanEnd: onRotateEnd,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.rotate_right,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-Dot Menu Button Widget
class _ThreeDotMenuButton extends StatelessWidget {
  final TemplateElement element;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  final Function(String action)? onArrange;

  const _ThreeDotMenuButton({
    required this.element,
    required this.onEdit,
    required this.onDelete,
    this.onDuplicate,
    this.onArrange,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: false,
      child: PopupMenuButton<String>(
        tooltip: 'More actions',
        offset: const Offset(0, 35),
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.more_horiz,
            size: 16,
            color: Colors.white,
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
              break;
            case 'duplicate':
              onDuplicate?.call();
              break;
            case 'delete':
              onDelete();
              break;
            case 'front':
            case 'back':
            case 'forward':
            case 'backward':
              onArrange?.call(value);
              break;
          }
        },
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[];

          // Edit option (conditional based on element type)
          if (element is TextElement) {
            items.add(
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Edit Text'),
                  ],
                ),
              ),
            );
          } else if (element is ImageElement) {
            items.add(
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.image, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Replace Image'),
                  ],
                ),
              ),
            );
          } else {
            items.add(
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Edit Properties'),
                  ],
                ),
              ),
            );
          }

          // Duplicate option
          if (onDuplicate != null) {
            items.add(
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.content_copy, size: 18),
                    SizedBox(width: 12),
                    Text('Duplicate'),
                  ],
                ),
              ),
            );
          }

          // Arrange submenu
          if (onArrange != null) {
            items.add(const PopupMenuDivider());
            items.add(
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Arrange',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
            items.addAll([
              const PopupMenuItem(
                value: 'front',
                child: Row(
                  children: [
                    Icon(Icons.flip_to_front, size: 18),
                    SizedBox(width: 12),
                    Text('Bring to Front'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'forward',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 18),
                    SizedBox(width: 12),
                    Text('Bring Forward'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'backward',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 18),
                    SizedBox(width: 12),
                    Text('Send Backward'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'back',
                child: Row(
                  children: [
                    Icon(Icons.flip_to_back, size: 18),
                    SizedBox(width: 12),
                    Text('Send to Back'),
                  ],
                ),
              ),
            ]);
          }

          // Delete option (always at the end)
          items.add(const PopupMenuDivider());
          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          );

          return items;
        },
      ),
    );
  }
}

/// Dashed Border Painter for selected elements
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw a rectangle around the element
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw the dashed path
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      bool draw = true;
      int dashIndex = 0;

      while (distance < metric.length) {
        final double length = dashPattern[dashIndex % dashPattern.length];

        if (draw) {
          final extractPath = metric.extractPath(
            distance,
            distance + length > metric.length ? metric.length : distance + length,
          );
          canvas.drawPath(extractPath, paint);
        }

        distance += length;
        draw = !draw;
        dashIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashPattern != dashPattern;
  }
}

// ==================== SIDE HANDLE WIDGET ====================

enum _HandleDirection { top, bottom, left, right }

class _SideHandle extends StatelessWidget {
  final _HandleDirection direction;
  final Function(DragStartDetails, _HandleDirection) onScaleStart;
  final Function(DragUpdateDetails, _HandleDirection) onScaleUpdate;
  final Function(DragEndDetails) onScaleEnd;
  final bool isMobile;

  const _SideHandle({
    required this.direction,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    // Smaller size for mobile, slightly larger for desktop
    double handleH = isMobile ? 50.0 : 70.0;
    double handleW= isMobile ? 16.0 : 18.0;
    double iconSize = isMobile ? 8.0 : 10.0;

    // Determine cursor and tooltip based on direction
    SystemMouseCursor cursor;
    String tooltip;
    IconData icon;

    switch (direction) {
      case _HandleDirection.top:
        handleH= isMobile ? 16.0 : 18.0;
        handleW = isMobile ? 50.0 : 70.0;

        cursor = SystemMouseCursors.resizeUp;
        tooltip = 'Drag to resize height';
        icon = Icons.drag_handle;
      case _HandleDirection.bottom:
        handleH= isMobile ? 16.0 : 18.0;
        handleW = isMobile ? 50.0 : 70.0;
        cursor = SystemMouseCursors.resizeUpDown;
        tooltip = 'Drag to resize height';
        icon = Icons.drag_handle;
        break;
      case _HandleDirection.left:
      case _HandleDirection.right:
        cursor = SystemMouseCursors.resizeLeftRight;
        tooltip = 'Drag to resize width';
        icon = Icons.drag_handle;
        break;
    }

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onPanStart: (details) => onScaleStart(details, direction),
        onPanUpdate: (details) => onScaleUpdate(details, direction),
        onPanEnd: onScaleEnd,
        child: MouseRegion(
          cursor: cursor,
          child: Container(
            width: handleW,
            height: handleH,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(handleW / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
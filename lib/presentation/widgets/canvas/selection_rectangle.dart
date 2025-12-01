import 'package:flutter/material.dart';

/// Selection rectangle drawn during drag selection
class SelectionRectangle extends StatelessWidget {
  final Rect? rect;

  const SelectionRectangle({
    super.key,
    this.rect,
  });

  @override
  Widget build(BuildContext context) {
    if (rect == null) return const SizedBox.shrink();

    return Positioned(
      left: rect!.left,
      top: rect!.top,
      width: rect!.width,
      height: rect!.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(
            color: Colors.blue.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
    );
  }
}
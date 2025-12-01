import 'package:flutter/material.dart';

import '../../../data/models/poster_background.dart';

/// Renders the poster background
class CanvasBackground extends StatelessWidget {
  final PosterBackground background;

  const CanvasBackground({
    super.key,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: background.toBoxDecoration(),
      ),
    );
  }
}
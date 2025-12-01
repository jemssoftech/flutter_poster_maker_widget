import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../../data/models/effects/layer_effects.dart';

/// Wraps a layer with its effects (shadow, blur, border)
class LayerEffectsWrapper extends StatelessWidget {
  final LayerEffects effects;
  final Widget child;

  const LayerEffectsWrapper({
    super.key,
    required this.effects,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;

    // Apply blur
    if (effects.blur?.enabled == true) {
      result = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: effects.blur!.sigmaX,
          sigmaY: effects.blur!.sigmaY,
        ),
        child: result,
      );
    }

    // Apply shadow and border via Container
    if (effects.shadow?.enabled == true || effects.border?.enabled == true) {
      result = Container(
        decoration: BoxDecoration(
          boxShadow: effects.shadow?.enabled == true
              ? [effects.shadow!.toBoxShadow()!]
              : null,
          border: effects.border?.toBorder(),
        ),
        child: result,
      );
    }

    return result;
  }
}
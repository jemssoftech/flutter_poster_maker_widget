import 'package:get/get.dart';

import '../../core/types/typedefs.dart';
import '../../data/models/layers/layer_base.dart';

/// Service for clipboard operations (copy/paste)
class ClipboardService extends GetxService {
  /// Clipboard content
  final Rx<List<JsonMap>> _clipboard = Rx<List<JsonMap>>([]);

  /// Whether clipboard has content
  bool get hasContent => _clipboard.value.isNotEmpty;

  /// Number of items in clipboard
  int get itemCount => _clipboard.value.length;

  /// Copy layers to clipboard
  void copy(List<LayerBase> layers) {
    if (layers.isEmpty) return;

    _clipboard.value = layers.map((layer) => layer.toJson()).toList();
  }

  /// Get clipboard content as JSON
  List<JsonMap> getContent() {
    return List<JsonMap>.from(_clipboard.value);
  }

  /// Clear clipboard
  void clear() {
    _clipboard.value = [];
  }

  /// Check if clipboard has layers
  bool get hasLayers => _clipboard.value.isNotEmpty;
}
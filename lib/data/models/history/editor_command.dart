import '../../../core/types/typedefs.dart';

/// Base class for undo/redo commands
abstract class EditorCommand {
  /// Command name for display
  final String name;

  /// Timestamp when command was created
  final DateTime timestamp;

  /// Whether this command can be merged with previous
  final bool canMerge;

  EditorCommand({
    required this.name,
    DateTime? timestamp,
    this.canMerge = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Execute the command (redo)
  void execute();

  /// Undo the command
  void undo();

  /// Check if this command can merge with another
  bool canMergeWith(EditorCommand other) => false;

  /// Merge with another command (returns merged command)
  EditorCommand? mergeWith(EditorCommand other) => null;

  @override
  String toString() => 'EditorCommand($name)';
}

/// Command for layer property changes
class LayerPropertyCommand extends EditorCommand {
  final String layerId;
  final String propertyName;
  final dynamic oldValue;
  final dynamic newValue;
  final void Function(String layerId, String property, dynamic value) applyChange;

  LayerPropertyCommand({
    required this.layerId,
    required this.propertyName,
    required this.oldValue,
    required this.newValue,
    required this.applyChange,
    super.canMerge = true,
  }) : super(name: 'Change $propertyName');

  @override
  void execute() {
    applyChange(layerId, propertyName, newValue);
  }

  @override
  void undo() {
    applyChange(layerId, propertyName, oldValue);
  }

  @override
  bool canMergeWith(EditorCommand other) {
    if (!canMerge) return false;
    if (other is! LayerPropertyCommand) return false;
    if (other.layerId != layerId) return false;
    if (other.propertyName != propertyName) return false;

    // Only merge if within 500ms
    final timeDiff = other.timestamp.difference(timestamp).inMilliseconds;
    return timeDiff.abs() < 500;
  }

  @override
  EditorCommand? mergeWith(EditorCommand other) {
    if (!canMergeWith(other)) return null;

    final otherCmd = other as LayerPropertyCommand;
    return LayerPropertyCommand(
      layerId: layerId,
      propertyName: propertyName,
      oldValue: oldValue, // Keep original old value
      newValue: otherCmd.newValue, // Use latest new value
      applyChange: applyChange,
      canMerge: true,
    );
  }
}

/// Command for adding a layer
class AddLayerCommand extends EditorCommand {
  final JsonMap layerJson;
  final int index;
  final void Function(JsonMap json, int index) addLayer;
  final void Function(String layerId) removeLayer;
  String? _layerId;

  AddLayerCommand({
    required this.layerJson,
    required this.index,
    required this.addLayer,
    required this.removeLayer,
  }) : super(name: 'Add Layer') {
    _layerId = layerJson['id'] as String?;
  }

  @override
  void execute() {
    addLayer(layerJson, index);
  }

  @override
  void undo() {
    if (_layerId != null) {
      removeLayer(_layerId!);
    }
  }
}

/// Command for removing a layer
class RemoveLayerCommand extends EditorCommand {
  final String layerId;
  final JsonMap layerJson;
  final int index;
  final void Function(String layerId) removeLayer;
  final void Function(JsonMap json, int index) addLayer;

  RemoveLayerCommand({
    required this.layerId,
    required this.layerJson,
    required this.index,
    required this.removeLayer,
    required this.addLayer,
  }) : super(name: 'Remove Layer');

  @override
  void execute() {
    removeLayer(layerId);
  }

  @override
  void undo() {
    addLayer(layerJson, index);
  }
}

/// Command for reordering layers
class ReorderLayerCommand extends EditorCommand {
  final int oldIndex;
  final int newIndex;
  final void Function(int from, int to) reorderLayer;

  ReorderLayerCommand({
    required this.oldIndex,
    required this.newIndex,
    required this.reorderLayer,
  }) : super(name: 'Reorder Layer');

  @override
  void execute() {
    reorderLayer(oldIndex, newIndex);
  }

  @override
  void undo() {
    reorderLayer(newIndex, oldIndex);
  }
}

/// Command for transform changes
class TransformCommand extends EditorCommand {
  final String layerId;
  final JsonMap oldTransform;
  final JsonMap newTransform;
  final void Function(String layerId, JsonMap transform) applyTransform;

  TransformCommand({
    required this.layerId,
    required this.oldTransform,
    required this.newTransform,
    required this.applyTransform,
  }) : super(name: 'Transform');

  @override
  void execute() {
    applyTransform(layerId, newTransform);
  }

  @override
  void undo() {
    applyTransform(layerId, oldTransform);
  }
}

/// Command for batch operations (multiple commands as one)
class BatchCommand extends EditorCommand {
  final List<EditorCommand> commands;

  BatchCommand({
    required String name,
    required this.commands,
  }) : super(name: name);

  @override
  void execute() {
    for (final command in commands) {
      command.execute();
    }
  }

  @override
  void undo() {
    // Undo in reverse order
    for (int i = commands.length - 1; i >= 0; i--) {
      commands[i].undo();
    }
  }
}
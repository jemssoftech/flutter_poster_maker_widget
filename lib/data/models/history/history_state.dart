import 'editor_command.dart';

/// State of the undo/redo history
class HistoryState {
  /// Stack of undo commands
  final List<EditorCommand> undoStack;

  /// Stack of redo commands
  final List<EditorCommand> redoStack;

  /// Maximum history size
  final int maxSize;

  /// Currently recording batch command
  final String? batchName;

  /// Commands being batched
  final List<EditorCommand> batchCommands;

  const HistoryState({
    this.undoStack = const [],
    this.redoStack = const [],
    this.maxSize = 50,
    this.batchName,
    this.batchCommands = const [],
  });

  /// Empty history
  static const HistoryState empty = HistoryState();

  /// Check if can undo
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if can redo
  bool get canRedo => redoStack.isNotEmpty;

  /// Get undo command name
  String? get undoActionName => undoStack.isNotEmpty ? undoStack.last.name : null;

  /// Get redo command name
  String? get redoActionName => redoStack.isNotEmpty ? redoStack.last.name : null;

  /// Get history length
  int get length => undoStack.length;

  /// Check if currently batching
  bool get isBatching => batchName != null;

  /// Push a new command
  HistoryState push(EditorCommand command) {
    // If batching, add to batch
    if (isBatching) {
      return copyWith(
        batchCommands: [...batchCommands, command],
      );
    }

    // Try to merge with last command
    if (undoStack.isNotEmpty && command.canMerge) {
      final lastCommand = undoStack.last;
      final merged = command.mergeWith(lastCommand);
      if (merged != null) {
        return copyWith(
          undoStack: [...undoStack.sublist(0, undoStack.length - 1), merged],
          redoStack: [], // Clear redo on new action
        );
      }
    }

    // Add new command
    var newUndoStack = [...undoStack, command];

    // Trim if exceeds max size
    if (newUndoStack.length > maxSize) {
      newUndoStack = newUndoStack.sublist(newUndoStack.length - maxSize);
    }

    return copyWith(
      undoStack: newUndoStack,
      redoStack: [], // Clear redo on new action
    );
  }

  /// Undo last command
  HistoryState undo() {
    if (!canUndo) return this;

    final command = undoStack.last;
    command.undo();

    return copyWith(
      undoStack: undoStack.sublist(0, undoStack.length - 1),
      redoStack: [...redoStack, command],
    );
  }

  /// Redo last undone command
  HistoryState redo() {
    if (!canRedo) return this;

    final command = redoStack.last;
    command.execute();

    return copyWith(
      undoStack: [...undoStack, command],
      redoStack: redoStack.sublist(0, redoStack.length - 1),
    );
  }

  /// Clear all history
  HistoryState clear() {
    return const HistoryState();
  }

  /// Begin batch recording
  HistoryState beginBatch(String name) {
    return copyWith(
      batchName: name,
      batchCommands: [],
    );
  }

  /// End batch recording and create single command
  HistoryState endBatch() {
    if (!isBatching || batchCommands.isEmpty) {
      return copyWith(
        batchName: null,
        batchCommands: [],
      );
    }

    final batchCommand = BatchCommand(
      name: batchName!,
      commands: batchCommands,
    );

    return copyWith(
      batchName: null,
      batchCommands: [],
    ).push(batchCommand);
  }

  /// Cancel batch recording
  HistoryState cancelBatch() {
    // Undo all batched commands
    for (int i = batchCommands.length - 1; i >= 0; i--) {
      batchCommands[i].undo();
    }

    return copyWith(
      batchName: null,
      batchCommands: [],
    );
  }

  /// Create copy with modifications
  HistoryState copyWith({
    List<EditorCommand>? undoStack,
    List<EditorCommand>? redoStack,
    int? maxSize,
    String? batchName,
    List<EditorCommand>? batchCommands,
    bool clearBatchName = false,
  }) {
    return HistoryState(
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      maxSize: maxSize ?? this.maxSize,
      batchName: clearBatchName ? null : (batchName ?? this.batchName),
      batchCommands: batchCommands ?? this.batchCommands,
    );
  }

  @override
  String toString() => 'HistoryState(undo: ${undoStack.length}, redo: ${redoStack.length})';
}
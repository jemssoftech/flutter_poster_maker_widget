import 'package:get/get.dart';

import '../../core/types/typedefs.dart';
import '../../data/models/history/editor_command.dart';
import '../../data/models/history/history_state.dart';

/// Service for managing undo/redo functionality
class UndoRedoService extends GetxService {
  /// Maximum history size
  final int maxHistorySize;

  UndoRedoService({this.maxHistorySize = 50});

  /// Current history state
  final Rx<HistoryState> _state = Rx<HistoryState>(const HistoryState());

  /// Get current state
  HistoryState get state => _state.value;

  /// Whether can undo
  bool get canUndo => _state.value.canUndo;

  /// Whether can redo
  bool get canRedo => _state.value.canRedo;

  /// Get undo action name
  String? get undoActionName => _state.value.undoActionName;

  /// Get redo action name
  String? get redoActionName => _state.value.redoActionName;

  /// Get history length
  int get historyLength => _state.value.length;

  /// Whether currently batching commands
  bool get isBatching => _state.value.isBatching;

  /// Push a command to history
  void push(EditorCommand command) {
    // Execute the command first
    command.execute();

    // Add to history
    _state.value = _state.value.push(command);
  }

  /// Push without executing (for commands that were already executed)
  void pushExecuted(EditorCommand command) {
    _state.value = _state.value.push(command);
  }

  /// Undo last command
  bool undo() {
    if (!canUndo) return false;
    _state.value = _state.value.undo();
    return true;
  }

  /// Redo last undone command
  bool redo() {
    if (!canRedo) return false;
    _state.value = _state.value.redo();
    return true;
  }

  /// Clear all history
  void clear() {
    _state.value = const HistoryState();
  }

  /// Begin batch recording
  void beginBatch(String name) {
    _state.value = _state.value.beginBatch(name);
  }

  /// End batch recording
  void endBatch() {
    _state.value = _state.value.endBatch();
  }

  /// Cancel batch recording and undo all batched commands
  void cancelBatch() {
    _state.value = _state.value.cancelBatch();
  }

  /// Execute multiple commands as a single undo step
  void executeAsBatch(String name, List<EditorCommand> commands) {
    if (commands.isEmpty) return;

    // Execute all commands
    for (final command in commands) {
      command.execute();
    }

    // Create batch command and add to history
    final batchCommand = BatchCommand(name: name, commands: commands);
    _state.value = _state.value.push(batchCommand);
  }

  @override
  void onClose() {
    clear();
    super.onClose();
  }
}
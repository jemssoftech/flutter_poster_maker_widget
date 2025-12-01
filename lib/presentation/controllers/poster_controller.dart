import 'dart:ui' show Size;

import 'package:get/get.dart';

import '../../core/types/typedefs.dart';
import '../../core/errors/editor_exception.dart';
import '../../data/models/poster_document.dart';
import '../../data/models/poster_canvas.dart';
import '../../data/models/poster_background.dart';
import '../../data/models/poster_settings.dart';
import '../../data/repositories/poster_repository.dart';

/// Main controller for poster document state
class PosterController extends GetxController {
  final PosterRepository _repository;

  PosterController({required PosterRepository repository})
      : _repository = repository;

  // ==================== Reactive State ====================

  /// Current document
  final Rx<PosterDocument?> _document = Rx<PosterDocument?>(null);

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Saving state
  final RxBool isSaving = false.obs;

  /// Document has unsaved changes
  final RxBool isDirty = false.obs;

  /// Current error
  final Rx<EditorException?> error = Rx<EditorException?>(null);

  /// Auto-save enabled
  final RxBool autoSaveEnabled = true.obs;

  // ==================== Getters ====================

  /// Get current document
  PosterDocument? get document => _document.value;

  /// Check if document is loaded
  bool get hasDocument => _document.value != null;

  /// Get document ID
  String? get documentId => _document.value?.id;

  /// Get document name
  String get documentName => _document.value?.name ?? 'Untitled';

  /// Get canvas size (uses Flutter's Size from dart:ui)
  Size get canvasSize {
    if (_document.value == null) {
      return const Size(1080, 1920);
    }
    return Size(
      _document.value!.poster.width,
      _document.value!.poster.height,
    );
  }

  /// Get canvas configuration
  PosterCanvas get canvas => _document.value?.poster ?? const PosterCanvas();

  /// Get background
  PosterBackground get background => canvas.background;

  /// Get settings
  PosterSettings get settings => _document.value?.settings ?? const PosterSettings();

  // ==================== Document Operations ====================

  /// Create new document
  void createNew({
    String? name,
    double width = 1080,
    double height = 1920,
  }) {
    _document.value = PosterDocument.create(
      name: name,
      width: width,
      height: height,
    );
    isDirty.value = false;
    error.value = null;
  }

  /// Load document from JSON string
  Future<bool> loadFromJson(String jsonString) async {
    isLoading.value = true;
    error.value = null;

    try {
      final doc = await _repository.loadFromJson(jsonString);
      _document.value = doc;
      isDirty.value = false;
      return true;
    } on EditorException catch (e) {
      error.value = e;
      return false;
    } catch (e) {
      error.value = JsonParseException(message: 'Failed to load: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Save document to JSON string
  Future<String?> saveToJson({bool pretty = true}) async {
    if (!hasDocument) return null;

    isSaving.value = true;
    error.value = null;

    try {
      final json = await _repository.saveToJson(
        _document.value!,
        pretty: pretty,
      );
      isDirty.value = false;
      return json;
    } on EditorException catch (e) {
      error.value = e;
      return null;
    } catch (e) {
      error.value = JsonParseException(message: 'Failed to save: $e');
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  // ==================== Document Modification ====================

  /// Update document with a modifier function
  void updateDocument(PosterDocument Function(PosterDocument) modifier) {
    if (!hasDocument) return;

    _document.value = modifier(_document.value!);
    _markDirty();
  }

  /// Update canvas configuration
  void updateCanvas(PosterCanvas canvas) {
    updateDocument((doc) => doc.copyWith(poster: canvas));
  }

  /// Update background
  void updateBackground(PosterBackground background) {
    updateDocument((doc) => doc.copyWith(
      poster: doc.poster.copyWith(background: background),
    ));
  }

  /// Update canvas dimensions
  void updateDimensions(double width, double height) {
    updateDocument((doc) => doc.copyWith(
      poster: doc.poster.copyWith(width: width, height: height),
    ));
  }

  /// Update settings
  void updateSettings(PosterSettings settings) {
    updateDocument((doc) => doc.copyWith(settings: settings));
  }

  /// Rename document
  void rename(String name) {
    updateDocument((doc) => doc.copyWith(
      metadata: doc.metadata.copyWith(name: name),
    ));
  }

  // ==================== Internal ====================

  /// Mark document as dirty (has unsaved changes)
  void _markDirty() {
    isDirty.value = true;
    // Touch document to update modified timestamp
    if (hasDocument) {
      _document.value = _document.value!.touch();
    }
  }

  /// Clear current error
  void clearError() {
    error.value = null;
  }

  /// Reset controller state
  void reset() {
    _document.value = null;
    isLoading.value = false;
    isSaving.value = false;
    isDirty.value = false;
    error.value = null;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
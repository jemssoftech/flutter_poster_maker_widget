/// Flutter Poster Editor - A production-ready poster editing widget
library poster_editor;

// ==================== Core ====================
export 'core/constants/editor_constants.dart';
export 'core/errors/editor_exception.dart';
export 'core/extensions/color_extension.dart';
export 'core/extensions/string_extension.dart';
export 'core/utils/id_generator.dart';
export 'core/utils/json_utils.dart';
export 'core/types/typedefs.dart';

// ==================== Models - Document ====================
export 'data/models/poster_document.dart';
export 'data/models/poster_metadata.dart';
export 'data/models/poster_canvas.dart';
export 'data/models/poster_background.dart';
export 'data/models/poster_settings.dart';
export 'data/models/gradient_stop.dart';

// ==================== Models - Layers ====================
export 'data/models/layers/layer_base.dart';
export 'data/models/layers/image_layer.dart';
export 'data/models/layers/text_layer.dart';
export 'data/models/layers/svg_layer.dart';
export 'data/models/layers/shape_layer.dart';
export 'data/models/layers/layer_factory.dart';

// ==================== Models - Transform ====================
export 'data/models/transform/layer_transform.dart';
export 'data/models/transform/transform_origin.dart';

// ==================== Models - Effects ====================
export 'data/models/effects/layer_effects.dart';
export 'data/models/effects/shadow_effect.dart';
export 'data/models/effects/blur_effect.dart';
export 'data/models/effects/border_effect.dart';

// ==================== Models - Shapes ====================
export 'data/models/shapes/shape_type.dart';
export 'data/models/shapes/shape_fill.dart';
export 'data/models/shapes/shape_stroke.dart';
export 'data/models/shapes/corner_radius.dart';

// ==================== Models - Text ====================
export 'data/models/text/text_style_model.dart';
export 'data/models/text/paragraph_style.dart';
export 'data/models/text/rich_text_span.dart';
export 'data/models/text/text_background.dart';

// ==================== Models - SVG ====================
export 'data/models/svg/svg_element.dart';
export 'data/models/svg/svg_element_override.dart';

// ==================== Models - Assets ====================
export 'data/models/assets/asset_base.dart';
export 'data/models/assets/image_asset.dart';
export 'data/models/assets/font_asset.dart';
export 'data/models/assets/svg_asset.dart';
export 'data/models/assets/asset_manifest.dart';

// ==================== Models - Selection ====================
export 'data/models/selection/selection_state.dart';
export 'data/models/selection/multi_selection.dart';

// ==================== Models - History ====================
export 'data/models/history/editor_command.dart';
export 'data/models/history/history_state.dart';

// ==================== Models - Export ====================
export 'data/models/export/export_config.dart';

// ==================== Repositories ====================
export 'data/repositories/poster_repository.dart';
export 'data/repositories/asset_repository.dart';

// ==================== Domain Services ====================
export 'domain/services/undo_redo_service.dart';
export 'domain/services/alignment_service.dart';
export 'domain/services/transform_service.dart';
export 'domain/services/clipboard_service.dart';

// ==================== Services ====================
export 'services/json/json_serializer.dart';
export 'services/json/schema_validator.dart';

// ==================== Controllers ====================
export 'presentation/controllers/poster_controller.dart';
export 'presentation/controllers/layer_controller.dart';
export 'presentation/controllers/selection_controller.dart';
export 'presentation/controllers/transform_controller.dart';
export 'presentation/controllers/canvas_controller.dart';
export 'presentation/controllers/tool_controller.dart';
export 'presentation/controllers/ui_controller.dart';
export 'presentation/controllers/assets_controller.dart';
export 'presentation/controllers/font_controller.dart';
export 'presentation/controllers/svg_controller.dart';
export 'presentation/controllers/history_controller.dart';
export 'presentation/controllers/export_controller.dart';

// ==================== Bindings ====================
export 'presentation/bindings/editor_binding.dart';
export 'presentation/bindings/initial_binding.dart';
// ==================== Canvas Widgets ====================
export 'presentation/widgets/canvas/editor_canvas.dart';
export 'presentation/widgets/canvas/canvas_viewport.dart';
export 'presentation/widgets/canvas/canvas_background.dart';
export 'presentation/widgets/canvas/canvas_grid.dart';

export 'presentation/widgets/canvas/canvas_rulers.dart';
export 'presentation/widgets/canvas/selection_rectangle.dart';

// ==================== Layer Widgets ====================
export 'presentation/widgets/layers/layer_renderer.dart';
export 'presentation/widgets/layers/image_layer_widget.dart';
export 'presentation/widgets/layers/text_layer_widget.dart';
export 'presentation/widgets/layers/svg_layer_widget.dart';
export 'presentation/widgets/layers/shape_layer_widget.dart';
export 'presentation/widgets/layers/layer_effects_wrapper.dart';

// ==================== Transform Widgets ====================
export 'presentation/widgets/transform/transform_box.dart';
export 'presentation/widgets/transform/resize_handle.dart';
export 'presentation/widgets/transform/rotate_handle.dart';

// ==================== Shared Widgets ====================
export 'presentation/widgets/shared/loading_indicator.dart';
export 'presentation/widgets/shared/checkerboard_pattern.dart';
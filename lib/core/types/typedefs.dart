import 'dart:ui' show Offset, Size;
import 'package:flutter/material.dart' show Matrix4, Color;

/// Common type definitions used across the editor

/// JSON map type
typedef JsonMap = Map<String, dynamic>;

/// Callback with single parameter
typedef ValueCallback<T> = void Function(T value);

/// Callback with two parameters
typedef ValueCallback2<T1, T2> = void Function(T1 value1, T2 value2);

/// Async callback
typedef AsyncVoidCallback = Future<void> Function();

/// Async callback with parameter
typedef AsyncValueCallback<T> = Future<void> Function(T value);

/// Error callback
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// Layer update function
typedef LayerUpdater<T> = T Function(T layer);

/// Offset transformer
typedef OffsetTransformer = Offset Function(Offset offset);

/// Size transformer
typedef SizeTransformer = Size Function(Size size);

/// Validator function
typedef Validator<T> = String? Function(T? value);

/// JSON encoder function
typedef JsonEncoderFunc<T> = JsonMap Function(T value);

/// JSON decoder function
typedef JsonDecoderFunc<T> = T Function(JsonMap json);

/// Predicate function
typedef Predicate<T> = bool Function(T value);

/// Comparator function
typedef ItemComparator<T> = int Function(T a, T b);

/// Transform builder
typedef TransformBuilder = Matrix4 Function(Matrix4 matrix);
// 📁 lib/models/element_models.dart

import '../editor/editor_controller.dart';

class ElementSection {
  final String id;
  final String title;
  final List<ElementSticker> stickers;

  ElementSection({required this.id, required this.title, required this.stickers});

  factory ElementSection.fromJson(Map<String, dynamic> json) {
    return ElementSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      stickers: (json['stickers'] as List?)
          ?.map((e) => ElementSticker.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class ElementSticker {
  final String id;
  final String name;
  final String thumbUrl;
  final String fileUrl;
  final String type; // 'svg' or 'json'
  final double width;
  final double height;

  ElementSticker({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.fileUrl,
    required this.type,
    required this.width,
    required this.height,
  });

  // Fotor assets usually reside on this CDN
  static const String _baseUrl = 'https://pub-static.fotor.com';

  factory ElementSticker.fromJson(Map<String, dynamic> json) {
    String thumb = json['thumb'] ?? '';
    String url = json['url'] ?? '';

    // Prepend base URL if path is relative
    if (!thumb.startsWith('http') && thumb.isNotEmpty) {
      thumb = '$_baseUrl$thumb';
    }
    if (!url.startsWith('http') && url.isNotEmpty) {
      url = '$_baseUrl$url';
    }

    return ElementSticker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbUrl: thumb,
      fileUrl: url,
      type: json['stickerType'] ?? 'svg',
      width: (json['width'] ?? 100).toDouble(),
      height: (json['height'] ?? 100).toDouble(),
    );
  }
}



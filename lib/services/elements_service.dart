// 📁 lib/services/elements_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/element_models.dart';

class ElementsApiResponse {
  final List<dynamic> items; // Can be ElementSection or ElementSticker
  final int totalPage;
  final bool hasNextPage;

  ElementsApiResponse({
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });
}

class ElementsService {
  static const String _baseUrlFloor = 'https://www.fotor.com/api/app/sticker/floor-page';
  static const String _baseUrlSearch = 'https://www.fotor.com/api/app/sticker/v2/search';

  static const haeder={
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "Referer": "https://www.fotor.com/"
  };
  /// 1. Fetch Floor Page (Sections)
  static Future<ElementsApiResponse> fetchFloorElements(int page) async {
    try {
      final url = Uri.parse('$_baseUrlFloor?pageNo=$page&pageSize=12&stickerCount=6&favorDesc=true');
      final response = await http.get(url,headers: haeder);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final dataBlock = json['data'];

        if (dataBlock == null) return _emptyResponse();

        final List<dynamic> rawSections = dataBlock['data'] ?? [];

        // Filter logic is inside Section mapping usually, but floor API returns sections
        final List<ElementSection> sections = rawSections
            .map((floor) => ElementSection.fromJson(floor))
            .toList();

        return ElementsApiResponse(
          items: sections,
          totalPage: dataBlock['totalPage'] ?? 1,
          hasNextPage: dataBlock['hasNextPage'] ?? false,
        );
      }
    } catch (e) {
      print('Error fetching floor elements: $e');
    }
    return _emptyResponse();
  }

  /// 2. Universal Search API (For Categories, View All, Search Bar)
  /// Filter out 'json' types here!
  static Future<ElementsApiResponse> searchElements({
    String query = '',
    int? categoryIndex,
    int page = 1,
  }) async {
    try {
      // Construct URL parameters
      final queryParams = {
        'pageNo': page.toString(),
        'pageSize': '30',
        'search': query,
        'category': categoryIndex?.toString() ?? '',
        'status': '',
        'groupId': '',
        'favorDesc': 'true',
        'floorId': '0',
        'analytic': '',
      };

      final url = Uri.parse(_baseUrlSearch).replace(queryParameters: queryParams);
      final response = await http.get(url,headers: haeder);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final dataBlock = json['data'];

        if (dataBlock == null) return _emptyResponse();

        final List<dynamic> rawStickers = dataBlock['data'] ?? [];

        // ✅ FILTERING LOGIC: Remove stickers where stickerType is 'json'
        final List<ElementSticker> stickers = rawStickers
            .where((s) => (s['stickerType'] ?? '').toString().toLowerCase() != 'json')
            .map((s) => ElementSticker.fromJson(s))
            .toList();

        return ElementsApiResponse(
          items: stickers,
          totalPage: dataBlock['totalPage'] ?? 1,
          hasNextPage: dataBlock['hasNextPage'] ?? false,
        );
      }
    } catch (e) {
      print('Error searching elements: $e');
    }
    return _emptyResponse();
  }

  static ElementsApiResponse _emptyResponse() {
    return ElementsApiResponse(items: [], totalPage: 0, hasNextPage: false);
  }
}
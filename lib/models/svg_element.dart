// ============================================================================
// 📁 FILE: lib/models/svg_element.dart
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'template_element.dart';

/// SVG Preset Category
class SvgCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<SvgPreset> presets;

  const SvgCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.presets = const [],
  });

  factory SvgCategory.fromJson(Map<String, dynamic> json) {
    return SvgCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: _parseIcon(json['icon']),
      presets: (json['presets'] as List<dynamic>?)
          ?.map((p) => SvgPreset.fromJson(p))
          .toList() ?? [],
    );
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'emoji': return Icons.emoji_emotions;
      case 'shapes': return Icons.category;
      case 'arrows': return Icons.arrow_forward;
      case 'icons': return Icons.apps;
      case 'decorations': return Icons.auto_awesome;
      case 'business': return Icons.business_center;
      case 'social': return Icons.share;
      case 'weather': return Icons.wb_sunny;
      default: return Icons.extension;
    }
  }
}

/// SVG Preset Item
class SvgPreset {
  final String id;
  final String name;
  final String svgString;
  final String? thumbnailUrl;
  final List<String> tags;
  final Map<String, Color> defaultColors;

  const SvgPreset({
    required this.id,
    required this.name,
    required this.svgString,
    this.thumbnailUrl,
    this.tags = const [],
    this.defaultColors = const {},
  });

  factory SvgPreset.fromJson(Map<String, dynamic> json) {
    return SvgPreset(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      svgString: json['svgString'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      defaultColors: (json['defaultColors'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Color(v as int)),
      ) ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'svgString': svgString,
    'thumbnailUrl': thumbnailUrl,
    'tags': tags,
    'defaultColors': defaultColors.map((k, v) => MapEntry(k, v.value)),
  };
}

/// Static SVG Presets Library (Will be replaced by API)
class SvgPresetsLibrary {
  // ==================== EMOJI CATEGORY ====================
  static const List<SvgPreset> emojiPresets = [
    // Smileys
    SvgPreset(
      id: 'emoji_smile',
      name: 'Smile',
      tags: ['emoji', 'happy', 'face'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <circle cx="35" cy="40" r="6" fill="#333"/>
  <circle cx="65" cy="40" r="6" fill="#333"/>
  <path d="M 30 60 Q 50 80 70 60" stroke="#333" stroke-width="4" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_heart_eyes',
      name: 'Heart Eyes',
      tags: ['emoji', 'love', 'face'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <path d="M 25 40 L 35 30 L 45 40 L 35 50 Z" fill="#E74C3C"/>
  <path d="M 55 40 L 65 30 L 75 40 L 65 50 Z" fill="#E74C3C"/>
  <path d="M 30 65 Q 50 85 70 65" stroke="#333" stroke-width="4" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_wink',
      name: 'Wink',
      tags: ['emoji', 'wink', 'face'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <circle cx="35" cy="40" r="6" fill="#333"/>
  <path d="M 58 40 L 72 40" stroke="#333" stroke-width="4" stroke-linecap="round"/>
  <path d="M 30 60 Q 50 80 70 60" stroke="#333" stroke-width="4" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_cool',
      name: 'Cool',
      tags: ['emoji', 'cool', 'sunglasses'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <rect x="20" y="32" width="25" height="16" rx="3" fill="#333"/>
  <rect x="55" y="32" width="25" height="16" rx="3" fill="#333"/>
  <line x1="45" y1="40" x2="55" y2="40" stroke="#333" stroke-width="3"/>
  <path d="M 30 65 Q 50 80 70 65" stroke="#333" stroke-width="4" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_star',
      name: 'Star Eyes',
      tags: ['emoji', 'star', 'excited'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <polygon points="35,30 38,40 48,40 40,46 43,56 35,50 27,56 30,46 22,40 32,40" fill="#F39C12"/>
  <polygon points="65,30 68,40 78,40 70,46 73,56 65,50 57,56 60,46 52,40 62,40" fill="#F39C12"/>
  <ellipse cx="50" cy="70" rx="15" ry="10" fill="#333"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_thinking',
      name: 'Thinking',
      tags: ['emoji', 'thinking', 'hmm'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#FFD93D" stroke="#E8B830" stroke-width="2"/>
  <circle cx="35" cy="40" r="5" fill="#333"/>
  <circle cx="65" cy="40" r="5" fill="#333"/>
  <path d="M 28 30 Q 35 25 42 30" stroke="#333" stroke-width="3" fill="none"/>
  <ellipse cx="55" cy="68" rx="12" ry="6" fill="#333"/>
  <circle cx="80" cy="70" r="8" fill="#C9A227"/>
</svg>''',
    ),
    // Hearts
    SvgPreset(
      id: 'emoji_red_heart',
      name: 'Red Heart',
      tags: ['emoji', 'heart', 'love'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 88 C 20 60 5 40 20 25 C 35 10 50 25 50 25 C 50 25 65 10 80 25 C 95 40 80 60 50 88 Z" fill="#E74C3C" stroke="#C0392B" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_pink_heart',
      name: 'Pink Heart',
      tags: ['emoji', 'heart', 'love'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 88 C 20 60 5 40 20 25 C 35 10 50 25 50 25 C 50 25 65 10 80 25 C 95 40 80 60 50 88 Z" fill="#FF69B4" stroke="#FF1493" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_sparkle_heart',
      name: 'Sparkle Heart',
      tags: ['emoji', 'heart', 'sparkle'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 85 C 20 55 8 38 22 24 C 36 10 50 24 50 24 C 50 24 64 10 78 24 C 92 38 80 55 50 85 Z" fill="#E74C3C"/>
  <circle cx="35" cy="35" r="4" fill="white" opacity="0.8"/>
  <circle cx="28" cy="42" r="2" fill="white" opacity="0.6"/>
  <polygon points="75,15 77,20 82,20 78,24 80,29 75,26 70,29 72,24 68,20 73,20" fill="#FFD700"/>
  <polygon points="20,65 21,68 24,68 22,70 23,73 20,71 17,73 18,70 16,68 19,68" fill="#FFD700"/>
</svg>''',
    ),
    // Thumbs
    SvgPreset(
      id: 'emoji_thumbs_up',
      name: 'Thumbs Up',
      tags: ['emoji', 'like', 'thumbs'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 35 90 L 35 50 L 25 50 L 25 90 Z" fill="#F4D03F"/>
  <path d="M 40 50 L 40 30 Q 40 20 50 20 L 55 20 Q 60 20 60 28 L 60 45 L 80 45 Q 90 45 88 60 L 85 85 Q 83 95 73 95 L 40 95 L 40 50 Z" fill="#F4D03F" stroke="#D4AC0D" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_clap',
      name: 'Clapping',
      tags: ['emoji', 'clap', 'applause'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <ellipse cx="35" cy="60" rx="20" ry="25" fill="#F4D03F" transform="rotate(-20 35 60)"/>
  <ellipse cx="65" cy="60" rx="20" ry="25" fill="#F4D03F" transform="rotate(20 65 60)"/>
  <line x1="25" y1="25" x2="20" y2="15" stroke="#FFD700" stroke-width="3"/>
  <line x1="50" y1="20" x2="50" y2="8" stroke="#FFD700" stroke-width="3"/>
  <line x1="75" y1="25" x2="80" y2="15" stroke="#FFD700" stroke-width="3"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_fire',
      name: 'Fire',
      tags: ['emoji', 'fire', 'hot'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 5 Q 75 30 70 55 Q 85 45 80 70 Q 85 95 50 95 Q 15 95 20 70 Q 15 45 30 55 Q 25 30 50 5 Z" fill="#E74C3C"/>
  <path d="M 50 25 Q 65 45 60 65 Q 70 60 65 80 Q 65 95 50 95 Q 35 95 35 80 Q 30 60 40 65 Q 35 45 50 25 Z" fill="#F39C12"/>
  <path d="M 50 50 Q 58 65 55 80 Q 55 95 50 95 Q 45 95 45 80 Q 42 65 50 50 Z" fill="#F1C40F"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_rocket',
      name: 'Rocket',
      tags: ['emoji', 'rocket', 'launch'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 5 Q 70 20 70 50 L 70 70 L 50 85 L 30 70 L 30 50 Q 30 20 50 5 Z" fill="#BDC3C7"/>
  <circle cx="50" cy="40" r="10" fill="#3498DB"/>
  <path d="M 30 55 L 15 70 L 25 75 L 30 65 Z" fill="#E74C3C"/>
  <path d="M 70 55 L 85 70 L 75 75 L 70 65 Z" fill="#E74C3C"/>
  <path d="M 40 85 L 35 100 L 50 90 L 65 100 L 60 85 Z" fill="#F39C12"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_star_gold',
      name: 'Gold Star',
      tags: ['emoji', 'star', 'gold'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 61,35 95,35 68,55 79,90 50,70 21,90 32,55 5,35 39,35" fill="#F1C40F" stroke="#D4AC0D" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_check',
      name: 'Check Mark',
      tags: ['emoji', 'check', 'done'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#2ECC71"/>
  <path d="M 25 50 L 42 67 L 75 34" stroke="white" stroke-width="10" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_cross',
      name: 'Cross Mark',
      tags: ['emoji', 'cross', 'no'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="#E74C3C"/>
  <path d="M 30 30 L 70 70 M 70 30 L 30 70" stroke="white" stroke-width="10" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'emoji_100',
      name: '100 Points',
      tags: ['emoji', '100', 'perfect'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <text x="50" y="55" font-size="40" font-weight="bold" fill="#E74C3C" text-anchor="middle">💯</text>
  <line x1="10" y1="75" x2="90" y2="75" stroke="#E74C3C" stroke-width="4"/>
  <line x1="10" y1="82" x2="90" y2="82" stroke="#E74C3C" stroke-width="4"/>
</svg>''',
    ),
  ];

  // ==================== SHAPES CATEGORY ====================
  static const List<SvgPreset> shapePresets = [
    // Basic Shapes
    SvgPreset(
      id: 'shape_circle',
      name: 'Circle',
      tags: ['shape', 'circle', 'round'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="45" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_square',
      name: 'Square',
      tags: ['shape', 'square', 'box'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="5" width="90" height="90" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_rounded_rect',
      name: 'Rounded Rectangle',
      tags: ['shape', 'rectangle', 'rounded'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="5" y="15" width="90" height="70" rx="15" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_triangle',
      name: 'Triangle',
      tags: ['shape', 'triangle'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 95,95 5,95" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_diamond',
      name: 'Diamond',
      tags: ['shape', 'diamond', 'rhombus'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 95,50 50,95 5,50" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_pentagon',
      name: 'Pentagon',
      tags: ['shape', 'pentagon'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 97,38 79,95 21,95 3,38" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_hexagon',
      name: 'Hexagon',
      tags: ['shape', 'hexagon'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 93,27 93,73 50,95 7,73 7,27" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_octagon',
      name: 'Octagon',
      tags: ['shape', 'octagon', 'stop'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="30,5 70,5 95,30 95,70 70,95 30,95 5,70 5,30" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_star_5',
      name: '5-Point Star',
      tags: ['shape', 'star'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 61,35 95,35 68,55 79,90 50,70 21,90 32,55 5,35 39,35" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_star_6',
      name: '6-Point Star',
      tags: ['shape', 'star', 'david'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 61,35 95,35 68,50 95,65 61,65 50,95 39,65 5,65 32,50 5,35 39,35" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_heart',
      name: 'Heart',
      tags: ['shape', 'heart', 'love'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 88 C 20 60 5 40 20 25 C 35 10 50 25 50 25 C 50 25 65 10 80 25 C 95 40 80 60 50 88 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_cloud',
      name: 'Cloud',
      tags: ['shape', 'cloud', 'weather'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 25 70 Q 5 70 10 55 Q 5 40 25 40 Q 30 20 50 25 Q 70 15 80 35 Q 100 35 95 55 Q 100 70 80 70 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_cross',
      name: 'Cross',
      tags: ['shape', 'cross', 'plus'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 35 5 L 65 5 L 65 35 L 95 35 L 95 65 L 65 65 L 65 95 L 35 95 L 35 65 L 5 65 L 5 35 L 35 35 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_arrow_right',
      name: 'Arrow Right',
      tags: ['shape', 'arrow', 'direction'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 5 35 L 55 35 L 55 15 L 95 50 L 55 85 L 55 65 L 5 65 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_arrow_up',
      name: 'Arrow Up',
      tags: ['shape', 'arrow', 'direction'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 35 95 L 35 45 L 15 45 L 50 5 L 85 45 L 65 45 L 65 95 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_chevron_right',
      name: 'Chevron Right',
      tags: ['shape', 'chevron', 'arrow'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 25 5 L 75 50 L 25 95" stroke="currentColor" stroke-width="12" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_badge',
      name: 'Badge',
      tags: ['shape', 'badge', 'ribbon'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="40" r="35" fill="currentColor"/>
  <path d="M 25 60 L 25 95 L 50 80 L 75 95 L 75 60" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_burst',
      name: 'Starburst',
      tags: ['shape', 'burst', 'explosion'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <polygon points="50,5 56,30 80,15 65,38 95,40 70,50 95,60 65,62 80,85 56,70 50,95 44,70 20,85 35,62 5,60 30,50 5,40 35,38 20,15 44,30" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_callout',
      name: 'Speech Bubble',
      tags: ['shape', 'callout', 'speech'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 10 10 L 90 10 Q 95 10 95 15 L 95 55 Q 95 60 90 60 L 35 60 L 20 80 L 25 60 L 10 60 Q 5 60 5 55 L 5 15 Q 5 10 10 10 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'shape_ribbon',
      name: 'Ribbon Banner',
      tags: ['shape', 'ribbon', 'banner'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 0 30 L 15 30 L 15 45 L 0 40 Z" fill="currentStroke"/>
  <path d="M 100 30 L 85 30 L 85 45 L 100 40 Z" fill="currentStroke"/>
  <path d="M 10 25 L 90 25 L 90 55 L 10 55 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
  ];

  // ==================== ARROWS CATEGORY ====================
  static const List<SvgPreset> arrowPresets = [
    SvgPreset(
      id: 'arrow_simple_right',
      name: 'Simple Right',
      tags: ['arrow', 'right', 'simple'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 10 50 L 70 50 M 55 35 L 70 50 L 55 65" stroke="currentColor" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_simple_left',
      name: 'Simple Left',
      tags: ['arrow', 'left', 'simple'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 90 50 L 30 50 M 45 35 L 30 50 L 45 65" stroke="currentColor" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_simple_up',
      name: 'Simple Up',
      tags: ['arrow', 'up', 'simple'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 90 L 50 30 M 35 45 L 50 30 L 65 45" stroke="currentColor" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_simple_down',
      name: 'Simple Down',
      tags: ['arrow', 'down', 'simple'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 10 L 50 70 M 35 55 L 50 70 L 65 55" stroke="currentColor" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_double',
      name: 'Double Arrow',
      tags: ['arrow', 'double', 'both'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 20 50 L 80 50 M 30 40 L 20 50 L 30 60 M 70 40 L 80 50 L 70 60" stroke="currentColor" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_curved',
      name: 'Curved Arrow',
      tags: ['arrow', 'curved', 'bend'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 20 70 Q 20 20 70 20 M 55 10 L 70 20 L 55 30" stroke="currentColor" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_circular',
      name: 'Circular Arrow',
      tags: ['arrow', 'circular', 'refresh'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 75 30 A 30 30 0 1 1 30 35 M 75 30 L 85 20 M 75 30 L 85 40" stroke="currentColor" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'arrow_undo',
      name: 'Undo Arrow',
      tags: ['arrow', 'undo', 'back'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 30 40 L 15 50 L 30 60 M 15 50 Q 50 50 50 75 L 80 75" stroke="currentColor" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
    ),
  ];

  // ==================== ICONS CATEGORY ====================
  static const List<SvgPreset> iconPresets = [
    SvgPreset(
      id: 'icon_home',
      name: 'Home',
      tags: ['icon', 'home', 'house'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 10 L 90 45 L 80 45 L 80 90 L 60 90 L 60 65 L 40 65 L 40 90 L 20 90 L 20 45 L 10 45 Z" fill="currentColor" stroke="currentStroke" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_settings',
      name: 'Settings',
      tags: ['icon', 'settings', 'gear'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 15 L 58 25 L 72 20 L 72 35 L 85 42 L 78 55 L 85 68 L 72 72 L 68 88 L 50 82 L 32 88 L 28 72 L 15 68 L 22 55 L 15 42 L 28 35 L 28 20 L 42 25 Z" fill="currentColor"/>
  <circle cx="50" cy="52" r="15" fill="white"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_user',
      name: 'User',
      tags: ['icon', 'user', 'person'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="30" r="20" fill="currentColor"/>
  <path d="M 15 95 Q 15 60 50 60 Q 85 60 85 95 Z" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_mail',
      name: 'Mail',
      tags: ['icon', 'mail', 'email'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="25" width="80" height="55" rx="5" fill="currentColor"/>
  <path d="M 10 30 L 50 55 L 90 30" stroke="white" stroke-width="4" fill="none"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_phone',
      name: 'Phone',
      tags: ['icon', 'phone', 'call'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 25 10 L 40 10 L 45 30 L 35 40 Q 45 60 60 70 L 70 55 L 90 60 L 90 80 Q 90 95 70 95 Q 20 90 10 35 Q 10 15 25 10 Z" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_location',
      name: 'Location',
      tags: ['icon', 'location', 'pin'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 95 Q 15 55 15 35 Q 15 10 50 10 Q 85 10 85 35 Q 85 55 50 95 Z" fill="currentColor"/>
  <circle cx="50" cy="35" r="12" fill="white"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_search',
      name: 'Search',
      tags: ['icon', 'search', 'magnify'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="42" cy="42" r="28" stroke="currentColor" stroke-width="8" fill="none"/>
  <line x1="62" y1="62" x2="88" y2="88" stroke="currentColor" stroke-width="10" stroke-linecap="round"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_calendar',
      name: 'Calendar',
      tags: ['icon', 'calendar', 'date'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="20" width="80" height="70" rx="5" fill="currentColor"/>
  <rect x="10" y="20" width="80" height="20" fill="currentStroke"/>
  <line x1="30" y1="10" x2="30" y2="30" stroke="currentColor" stroke-width="6" stroke-linecap="round"/>
  <line x1="70" y1="10" x2="70" y2="30" stroke="currentColor" stroke-width="6" stroke-linecap="round"/>
  <rect x="22" y="50" width="12" height="10" fill="white"/>
  <rect x="44" y="50" width="12" height="10" fill="white"/>
  <rect x="66" y="50" width="12" height="10" fill="white"/>
  <rect x="22" y="68" width="12" height="10" fill="white"/>
  <rect x="44" y="68" width="12" height="10" fill="white"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_clock',
      name: 'Clock',
      tags: ['icon', 'clock', 'time'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <circle cx="50" cy="50" r="42" stroke="currentColor" stroke-width="6" fill="none"/>
  <line x1="50" y1="50" x2="50" y2="25" stroke="currentColor" stroke-width="6" stroke-linecap="round"/>
  <line x1="50" y1="50" x2="70" y2="60" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
  <circle cx="50" cy="50" r="4" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'icon_cart',
      name: 'Shopping Cart',
      tags: ['icon', 'cart', 'shopping'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 10 15 L 25 15 L 35 60 L 80 60 L 90 25 L 30 25" stroke="currentColor" stroke-width="6" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="40" cy="78" r="8" fill="currentColor"/>
  <circle cx="72" cy="78" r="8" fill="currentColor"/>
</svg>''',
    ),
  ];

  // ==================== DECORATIONS CATEGORY ====================
  static const List<SvgPreset> decorationPresets = [
    SvgPreset(
      id: 'deco_flourish_1',
      name: 'Flourish 1',
      tags: ['decoration', 'flourish', 'ornament'],
      svgString: '''
<svg viewBox="0 0 200 50" xmlns="http://www.w3.org/2000/svg">
  <path d="M 10 25 Q 30 5 50 25 T 90 25 T 130 25 T 170 25 T 190 25" stroke="currentColor" stroke-width="3" fill="none"/>
  <circle cx="100" cy="25" r="8" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'deco_divider_1',
      name: 'Divider Line',
      tags: ['decoration', 'divider', 'line'],
      svgString: '''
<svg viewBox="0 0 200 20" xmlns="http://www.w3.org/2000/svg">
  <line x1="10" y1="10" x2="80" y2="10" stroke="currentColor" stroke-width="2"/>
  <circle cx="100" cy="10" r="5" fill="currentColor"/>
  <line x1="120" y1="10" x2="190" y2="10" stroke="currentColor" stroke-width="2"/>
</svg>''',
    ),
    SvgPreset(
      id: 'deco_corner_1',
      name: 'Corner Ornament',
      tags: ['decoration', 'corner', 'ornament'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 5 5 L 5 40 Q 5 5 40 5 Z" fill="currentColor"/>
  <path d="M 15 15 Q 15 35 35 35 Q 15 35 15 55" stroke="currentColor" stroke-width="2" fill="none"/>
</svg>''',
    ),
    SvgPreset(
      id: 'deco_frame_1',
      name: 'Decorative Frame',
      tags: ['decoration', 'frame', 'border'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <rect x="10" y="10" width="80" height="80" stroke="currentColor" stroke-width="3" fill="none"/>
  <circle cx="10" cy="10" r="5" fill="currentColor"/>
  <circle cx="90" cy="10" r="5" fill="currentColor"/>
  <circle cx="10" cy="90" r="5" fill="currentColor"/>
  <circle cx="90" cy="90" r="5" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'deco_sparkle',
      name: 'Sparkles',
      tags: ['decoration', 'sparkle', 'star'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 10 L 52 25 L 67 25 L 55 35 L 60 50 L 50 40 L 40 50 L 45 35 L 33 25 L 48 25 Z" fill="currentColor"/>
  <path d="M 25 50 L 26 58 L 34 58 L 28 63 L 31 71 L 25 66 L 19 71 L 22 63 L 16 58 L 24 58 Z" fill="currentColor"/>
  <path d="M 75 55 L 76 63 L 84 63 L 78 68 L 81 76 L 75 71 L 69 76 L 72 68 L 66 63 L 74 63 Z" fill="currentColor"/>
</svg>''',
    ),
    SvgPreset(
      id: 'deco_swirl',
      name: 'Swirl',
      tags: ['decoration', 'swirl', 'curl'],
      svgString: '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <path d="M 50 50 Q 50 20 70 20 Q 90 20 90 40 Q 90 60 70 60 Q 50 60 50 80 Q 50 95 30 95 Q 10 95 10 75" stroke="currentColor" stroke-width="4" fill="none" stroke-linecap="round"/>
</svg>''',
    ),
  ];

  // All categories
  static List<SvgCategory> get categories => [
    SvgCategory(id: 'emoji', name: 'Emoji', icon: Icons.emoji_emotions, presets: emojiPresets),
    SvgCategory(id: 'shapes', name: 'Shapes', icon: Icons.category, presets: shapePresets),
    SvgCategory(id: 'arrows', name: 'Arrows', icon: Icons.arrow_forward, presets: arrowPresets),
    SvgCategory(id: 'icons', name: 'Icons', icon: Icons.apps, presets: iconPresets),
    SvgCategory(id: 'decorations', name: 'Decorations', icon: Icons.auto_awesome, presets: decorationPresets),
  ];

  static List<SvgPreset> get allPresets {
    return categories.expand((c) => c.presets).toList();
  }

  static SvgPreset? getPresetById(String id) {
    try {
      return allPresets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<SvgPreset> searchPresets(String query) {
    final q = query.toLowerCase();
    return allPresets.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}

/// SVG Element
class SvgElement extends TemplateElement {
  String svgString;
  String? presetId;

  // Colors (for customizable SVGs)
  Color primaryColor;
  Color secondaryColor;
  Color strokeColor;
  double strokeWidth;

  // Filters
  double brightness;
  double contrast;
  double saturation;
  double blur;

  // Shadow
  bool hasShadow;
  Color shadowColor;
  double shadowBlur;
  Offset shadowOffset;

  // Transform
  bool flipHorizontal;
  bool flipVertical;
  
  // Multi-color support
  bool preserveOriginalColors;
  Color? colorOverlay;
  
  // Detect if SVG contains multiple colors (like emojis)
  bool get isMultiColor {
    final fillMatches = RegExp('fill\s*=\s*["\'](?!(?:none|currentColor))([^"\']+)["\']',
    caseSensitive: false,
    ).allMatches(svgString);

    final strokeMatches = RegExp('stroke\s*=\s*["\'](?!(?:none|currentColor))([^"\']+)["\']',
    caseSensitive: false,
    ).allMatches(svgString);

    final colors = <String>{};

    for (final match in fillMatches) {
    colors.add(match.group(1)!.toLowerCase());
    }

    for (final match in strokeMatches) {
    colors.add(match.group(1)!.toLowerCase());
    }

    return colors.length > 2;
  }

  SvgElement({
    required super.id,
    required super.name,
    required super.position,
    required super.size,
    super.rotation,
    super.opacity,
    super.isLocked,
    super.isVisible,
    super.zIndex,
    required this.svgString,
    this.presetId,
    this.primaryColor = const Color(0xFF3498DB),
    this.secondaryColor = const Color(0xFF2980B9),
    this.strokeColor = const Color(0xFF2C3E50),
    this.strokeWidth = 2,
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.blur = 0,
    this.hasShadow = false,
    this.shadowColor = const Color(0x40000000),
    this.shadowBlur = 4,
    this.shadowOffset = const Offset(2, 2),
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.colorOverlay,
    this.preserveOriginalColors = false,
  }) : super(type: ElementType.svg);

  /// Get processed SVG string with colors applied
  String get processedSvgString {
    String processed = svgString;

    // If preserving original colors (for multi-color SVGs like emojis), return as-is
    if (preserveOriginalColors) {
      return processed;
    }

    // Replace color placeholders
    processed = processed.replaceAll('currentColor', _colorToHex(primaryColor));
    processed = processed.replaceAll('currentStroke', _colorToHex(strokeColor));
    processed = processed.replaceAll('secondaryColor', _colorToHex(secondaryColor));

    // Update stroke-width if present
    processed = processed.replaceAllMapped(
      RegExp(r'stroke-width="[^"]*"'),
          (match) => 'stroke-width="$strokeWidth"',
    );

    return processed;
  }

  String _colorToHex(Color color) {
    // Ensure the hex string is always 8 characters (AARRGGBB), then skip alpha (first 2)
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  factory SvgElement.fromPreset(SvgPreset preset, {
    required String id,
    Offset? position,
    Size? size,
  }) {
    return SvgElement(
      id: id,
      name: preset.name,
      position: position ?? const Offset(100, 100),
      size: size ?? const Size(100, 100),
      svgString: preset.svgString,
      presetId: preset.id,
      primaryColor: preset.defaultColors['primary'] ?? const Color(0xFF3498DB),
      secondaryColor: preset.defaultColors['secondary'] ?? const Color(0xFF2980B9),
      strokeColor: preset.defaultColors['stroke'] ?? const Color(0xFF2C3E50),
    );
  }

  factory SvgElement.fromJson(Map<String, dynamic> json) {
    return SvgElement(
      id: json['id'],
      name: json['name'] ?? 'SVG Element',
      position: Offset(
        (json['position']?['x'] ?? 0).toDouble(),
        (json['position']?['y'] ?? 0).toDouble(),
      ),
      size: Size(
        (json['size']?['width'] ?? 100).toDouble(),
        (json['size']['height'] ?? 100).toDouble(),
      ),
      rotation: (json['rotation'] ?? 0).toDouble(),
      opacity: (json['opacity'] ?? 1).toDouble(),
      isLocked: json['isLocked'] ?? false,
      isVisible: json['isVisible'] ?? true,
      zIndex: json['zIndex'] ?? 0,
      svgString: json['svgString'] ?? '',
      presetId: json['presetId'],
      primaryColor: Color(json['primaryColor'] ?? 0xFF3498DB),
      secondaryColor: Color(json['secondaryColor'] ?? 0xFF2980B9),
      strokeColor: Color(json['strokeColor'] ?? 0xFF2C3E50),
      strokeWidth: (json['strokeWidth'] ?? 2).toDouble(),
      brightness: (json['brightness'] ?? 0).toDouble(),
      contrast: (json['contrast'] ?? 0).toDouble(),
      saturation: (json['saturation'] ?? 0).toDouble(),
      blur: (json['blur'] ?? 0).toDouble(),
      hasShadow: json['hasShadow'] ?? false,
      shadowColor: Color(json['shadowColor'] ?? 0x40000000),
      shadowBlur: (json['shadowBlur'] ?? 4).toDouble(),
      shadowOffset: Offset(
        (json['shadowOffsetX'] ?? 2).toDouble(),
        (json['shadowOffsetY'] ?? 2).toDouble(),
      ),
      flipHorizontal: json['flipHorizontal'] ?? false,
      flipVertical: json['flipVertical'] ?? false,
      preserveOriginalColors: json['preserveOriginalColors'] ?? false,
      colorOverlay: json['colorOverlay'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': 'svg',
    'position': {'x': position.dx, 'y': position.dy},
    'size': {'width': size.width, 'height': size.height},
    'rotation': rotation,
    'opacity': opacity,
    'isLocked': isLocked,
    'isVisible': isVisible,
    'zIndex': zIndex,
    'svgString': svgString,
    'presetId': presetId,
    'primaryColor': primaryColor.value,
    'secondaryColor': secondaryColor.value,
    'strokeColor': strokeColor.value,
    'strokeWidth': strokeWidth,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'blur': blur,
    'hasShadow': hasShadow,
    'shadowColor': shadowColor.value,
    'shadowBlur': shadowBlur,
    'shadowOffsetX': shadowOffset.dx,
    'shadowOffsetY': shadowOffset.dy,
    'flipHorizontal': flipHorizontal,
    'flipVertical': flipVertical,
    'preserveOriginalColors': preserveOriginalColors,
    'colorOverlay': colorOverlay,
  };

  @override
  SvgElement clone() => SvgElement(
    id: '${id}_copy',
    name: '$name Copy',
    position: position + const Offset(20, 20),
    size: size,
    rotation: rotation,
    opacity: opacity,
    isLocked: false,
    isVisible: isVisible,
    zIndex: zIndex,
    svgString: svgString,
    presetId: presetId,
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    brightness: brightness,
    contrast: contrast,
    saturation: saturation,
    blur: blur,
    hasShadow: hasShadow,
    shadowColor: shadowColor,
    shadowBlur: shadowBlur,
    shadowOffset: shadowOffset,
    flipHorizontal: flipHorizontal,
    flipVertical: flipVertical,
    preserveOriginalColors: preserveOriginalColors,
    colorOverlay: colorOverlay,
  );
}
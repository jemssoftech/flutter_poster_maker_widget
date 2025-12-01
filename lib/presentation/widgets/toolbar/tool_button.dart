import 'package:flutter/material.dart';

/// Tool button for the bottom toolbar
class ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? shortcut;
  final bool isSelected;
  final VoidCallback? onPressed;

  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    this.shortcut,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: shortcut != null ? '$label ($shortcut)' : label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0080FF).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF0080FF) : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF0080FF) : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
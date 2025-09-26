// lib/presentation/widgets/control_tile.dart
import 'package:flutter/material.dart';

class ControlTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const ControlTile({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: isActive ? color.withOpacity(0.9) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ // <-- Hapus semua kode GridView di sini!
            Icon(
              icon,
              size: 40,
              color: isActive ? Colors.white : color.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              isActive ? "ON" : "OFF",
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
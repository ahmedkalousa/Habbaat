
import 'package:flutter/material.dart';

class ContactIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ContactIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: color.withOpacity(0.12),
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 26),
        onPressed: onTap,
        splashRadius: 26,
      ),
    );
  }
}
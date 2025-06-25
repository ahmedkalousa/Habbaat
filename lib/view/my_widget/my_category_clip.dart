import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const CategoryChip({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, textDirection: TextDirection.rtl),
      backgroundColor: primaryColor,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';

class MyUnitTypeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Function() onTap;
  const MyUnitTypeTile({super.key, required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: selected ? primaryColor.withOpacity(0.15) : Colors.white,
        elevation: selected ? 4 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, color: selected ? primaryColor : Colors.grey, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: selected ?primaryColor : Colors.black,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (selected)
                Icon(Icons.check_circle, color: primaryColor)
            ],
          ),
        ),
      ),
    );
  }

  }

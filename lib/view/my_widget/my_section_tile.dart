import 'package:flutter/material.dart';

class MySectionTile extends StatelessWidget {
  final String title ;
  const MySectionTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
      );
  }

}

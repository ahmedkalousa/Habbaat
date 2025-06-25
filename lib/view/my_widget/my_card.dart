import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';

class MyCard extends StatelessWidget {
    final String text;
    final IconData iconData;
    final Function() onTap;

  const MyCard({super.key, required this.text, required this.iconData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return   
    GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
                          color: primaryColor,

            ),
            padding: EdgeInsets.all(12),
            child: Icon(
                    iconData,
                    size: 25,
                    color: Colors.white,
                    ),
                  ),
          SizedBox(height: 8,),
          Text(text , style: TextStyle(fontSize: 12),)
                  ]),
    );
  }
}
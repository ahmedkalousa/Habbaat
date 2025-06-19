import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';

class MySocialMediaIcon extends StatelessWidget {
  final Function() onTap;
  final IconData  iconData;
  const MySocialMediaIcon({super.key, required this.onTap, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.13),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(iconData,
                  color: primaryColor,
                  size: 22,
                ),
              ),
            );
  }
}
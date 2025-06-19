import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MySpaceCard extends StatelessWidget {
  final String imgPath ;
  final String title  ;
  final String subtitle ;
  final Function() onTap;
  const MySpaceCard({super.key, required this.imgPath, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Card(
          color: Colors.white,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 7,
                  child: CachedNetworkImage(
                    imageUrl: imgPath,
                    cacheKey: imgPath,
                    width: double.infinity, 
                    height: 120.h,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 300),
                    fadeOutDuration: Duration(milliseconds: 300),
                    maxWidthDiskCache: 600,
                    maxHeightDiskCache: 240,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 120.h,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 120.h,
                      color: Colors.grey[300],
                      child: Icon(Icons.error, size: 32.sp, color: Colors.red),
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: ListTile(
                    title: Text(title, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 16.sp)),
                    subtitle: Text(subtitle, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 13.sp)),
                    isThreeLine: true,
                  ),
                ),
              ],
          ),
        ),
      ),
  );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyMiniCard extends StatelessWidget {
  final String imagePath ;
  final String title ;
  final String subtitle ;
  final Function() onTap;
  const  MyMiniCard({super.key, required this.imagePath, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imagePath,
                cacheKey: imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 300),
                fadeOutDuration: Duration(milliseconds: 300),
                maxWidthDiskCache: 400,
                maxHeightDiskCache: 300,
                useOldImageOnUrlChange: true,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                            textDirection: TextDirection.rtl,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
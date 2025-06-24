import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  
import 'package:shimmer/shimmer.dart';

class HomePageSkeleton extends StatelessWidget {
  Widget shimmerBox({double? width, double? height, EdgeInsetsGeometry? margin}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة رئيسية وهمية
              shimmerBox(width: double.infinity, height: 200.h),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: shimmerBox(height: 48.h, width: double.infinity),
              ),
              // تصنيفات القاعات الوهمية
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) => shimmerBox(width: 80.w, height: 80.h)),
                ),
              ),
              // المساحات الشائعة الوهمية
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: List.generate(4, (index) => shimmerBox(height: 80.h, width: double.infinity, margin: EdgeInsets.symmetric(vertical: 8.h))),
                ),
              ),
              // جديد هذا الأسبوع الوهمية
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.w,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 8.h,
                  ),
                  itemBuilder: (context, index) => shimmerBox(margin: EdgeInsets.symmetric(vertical: 8.h)),
                ),
              ),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}
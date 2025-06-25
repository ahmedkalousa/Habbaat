import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_widget/my_map_widget.dart';
import 'package:work_spaces/view/my_widget/my_state_card.dart';

class InitiativePage extends StatefulWidget {
  static const String id = '/InitiativePage';

  const InitiativePage({super.key});

  @override
  State<InitiativePage> createState() => _InitiativePageState();
}

class _InitiativePageState extends State<InitiativePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    if (spacesProvider.spaces.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.space_dashboard, size: 80.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'لا توجد مساحات لعرضها',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final random = Random();
    final space = spacesProvider.spaces[random.nextInt(spacesProvider.spaces.length)];

    final coverImage = space.images.isNotEmpty
        ? baseUrlImage + space.images.first.imageUrl
        : 'https://via.placeholder.com/400x300';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.h,
            backgroundColor: const Color(0xFFF7F8FA),
            elevation: 0,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: Colors.white),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: coverImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withOpacity(0.8),
                            primaryColor1.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withOpacity(0.8),
                            primaryColor1.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header with gradient
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColor.withOpacity(0.1),
                                  primaryColor1.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        Icons.lightbulb,
                                        color: primaryColor,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        space.name,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        value: space.rating.toString(),
                                        label: 'التقييم',
                                        icon: Icons.star_rounded,
                                        color: Colors.amber.shade400,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: StatCard(
                                        value: space.governorate,
                                        label: 'المحافظة',
                                        icon: Icons.map_rounded,
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: StatCard(
                                        value: space.spaceUnits.length.toString(),
                                        label: 'الوحدات',
                                        icon: Icons.business_rounded,
                                        color: Colors.green.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(2.r),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'عن المساحة',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  child: Text(
                                    space.bio,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 15.sp,
                                      height: 1.7,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                // Map section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade100, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.map, size: 22),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'موقع المساحة',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(space.location),
                                      SizedBox(height: 12.h),
                                      MyMapWidget(
                                        latitude: space.latitude ??31.5145,
                                        longitude: space.longitude ?? 34.4453,
                                        spaceName: space.name,
                                        spaceLocation: space.location,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                // Units gallery section
                             ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 180.h,
                  child: space.spaceUnits.isEmpty
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 48.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'لا توجد وحدات لعرضها',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: space.spaceUnits.length,
                          itemBuilder: (context, index) {
                            final unit = space.spaceUnits[index];
                            final unitImage = unit.imageUrl.isNotEmpty
                                ? baseUrlImage + unit.imageUrl
                                : 'https://via.placeholder.com/200x150';

                            return 
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => UnitDetailsPage(),
                                    settings: RouteSettings(
                                      arguments: {'unitId': unit.id},
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 200.w,
                                margin: EdgeInsetsDirectional.only(end: 16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: unitImage,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: primaryColor,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(12.w),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                unit.name,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                unit.unitCategoryName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 80.h),
              ],
            ),
          )
        ],
      ),
    );
  }
}




import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_wedgit/my_map_widget.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/model/space_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:readmore/readmore.dart';
import 'package:work_spaces/view/my_wedgit/my_state_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SpaceDetailsPage extends StatefulWidget {
  static const id = '/SpaceDetailsPage';
  const SpaceDetailsPage({super.key});

  @override
  State<SpaceDetailsPage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpaceDetailsPage>  with TickerProviderStateMixin{
 late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool showBackButton = true;
  late ScrollController _scrollController;
  int _currentImageIndex = 0;

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
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 60 && showBackButton) {
        setState(() => showBackButton = false);
      } else if (_scrollController.offset <= 60 && !showBackButton) {
        setState(() => showBackButton = true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? spaceId = args != null && args['spaceId'] != null ? args['spaceId'] as int : null;
    
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    
    if (spaceId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'معرف المساحة غير صالح',
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
    
    // البحث عن المساحة بواسطة ID
    final space = spacesProvider.spaces.where((s) => s.id == spaceId).firstOrNull;
    
    if (space == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.space_dashboard, size: 80.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text(
                'لم يتم العثور على المساحة المطلوبة',
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

    final coverImage = space.images.isNotEmpty
        ? baseUrlImage + space.images.first.imageUrl
        : 'https://via.placeholder.com/400x300';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 320.h,
              backgroundColor: const Color(0xFFF7F8FA),
              elevation: 0,
              pinned: false,
              floating: true,
              snap: true,
              stretch: true,
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: Colors.white),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (space.images.length > 1)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 350.h,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: true,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 4),
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          pauseAutoPlayOnTouch: true,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                        ),
                        items: space.images.map((img) {
                          final imgUrl = baseUrlImage + img.imageUrl;
                          return Builder(
                            builder: (BuildContext context) {
                              return CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                              );
                            },
                          );
                        }).toList(),
                      )
                    else
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
                    if (space.images.length > 1)
                      Positioned(
                        bottom: 18,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(space.images.length, (index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              width: _currentImageIndex == index ? 16 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentImageIndex == index ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: _currentImageIndex == index
                                    ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                                    : [],
                              ),
                            );
                          }),
                        ),
                      ),
                    if (showBackButton)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
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
                                        child: Center(
                                          child: Icon(
                                            Icons.lightbulb,
                                            color: primaryColor,
                                            size: 24.sp,
                                          ),
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
                                  if (space.startTime != null && space.endTime != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 16.h),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.access_time_filled, color: primaryColor, size: 22.sp),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  'أوقات العمل',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${_formatTime(space.startTime!)} - ${_formatTime(space.endTime!)}',
                                              textDirection: TextDirection.ltr,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if(space.paymentMethods.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child:  
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                           Icon(Icons.payments, color: primaryColor, size: 22.sp),
                                           SizedBox(width: 8.w),
                                           Expanded(
                                            child: Text(
                                              'طرق الدفع المتاحة',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Row(
                                            children: space.paymentMethods.map((method) {
                                              IconData icon;
                                              Color color;
                                              switch (method.trim()) {
                                                case 'كاش':
                                                  icon = Icons.attach_money_rounded;
                                                  color = Colors.green;
                                                  break;
                                              
                                                case 'بنكي':
                                                  icon = Icons.credit_card_rounded;
                                                  color = Colors.blue;
                                                  break;
                                                default:
                                                  icon = Icons.payment;
                                                  color = Colors.grey;
                                              }
                                              return Padding(
                                                padding: EdgeInsets.only(right: 12.w),
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: color.withOpacity(0.12),
                                                      radius: 20.r,
                                                      child: Icon(icon, color: color, size: 22.sp),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      
                                        ],
                                      ),
                                      
                                    ),
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
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ReadMoreText(
                                          space.bio,
                                          trimLines: 2,
                                          trimMode: TrimMode.Line,
                                          trimCollapsedText: 'عرض المزيد',
                                          trimExpandedText: 'عرض أقل',
                                          moreStyle: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15.sp,
                                            height: 1.7,
                                          ),
                                          lessStyle: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15.sp,
                                            height: 1.7,
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 15.sp,
                                            height: 1.7,
                                          ),
                                          textAlign: TextAlign.start,
                                          locale: const Locale('ar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if(space.features.isNotEmpty)
                                  Column(
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
                                            'مميزات المساحة',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 16.h),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(14.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(FontAwesomeIcons.check, color: Colors.green, size: 22.sp),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: space.features.map((feature) => Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                                    child: Text(
                                                      feature,
                                                      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                                    ),
                                                  )).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                        SizedBox(height: 8.h),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on_outlined, size: 16.sp,),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                              child: Text(
                                                space.location,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
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
                                  // قسم معلومات التواصل
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: primaryColor.withOpacity(0.18)),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                          children: [
                                          
                                            GestureDetector(
                                              onTap: () async {
                                                final Uri phoneUri = Uri(scheme: 'tel', path: space.contactNumber);
                                                if (await canLaunchUrl(phoneUri)) {
                                                  await launchUrl(phoneUri);
                                                }
                                              },
                                              child: Text(
                                                space.contactNumber,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.blue.shade700,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],),
                                          
                                          SizedBox(height: 12.h),
                                          // أيقونات التواصل
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: _buildContactIcons(space, context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          
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
                  SizedBox(height: 20.h),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
    // دالة مساعدة لتنسيق الوقت
  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final String minute = parts[1];
        String period = 'AM';

        if (hour >= 12) {
          period = 'PM';
        }
        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }
        return '$hour:$minute $period';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  List<Widget> _buildContactIcons(Space space, BuildContext context) {
    final List<Widget> icons = [];
    final Map<String, Map<String, dynamic>> iconMapping = {
      'facebook': {'icon': FontAwesomeIcons.facebook, 'color': Colors.blue[800]!},
      'instagram': {'icon': FontAwesomeIcons.instagram, 'color': Colors.pink},
      'twitter': {'icon': FontAwesomeIcons.twitter, 'color': Colors.lightBlue},
      'tiktok': {'icon': FontAwesomeIcons.tiktok, 'color': Colors.black},
    };
    // social links
    for (final link in space.socialLinks) {
      final platform = link.platform.toLowerCase();
      if (iconMapping.containsKey(platform)) {
        final iconData = iconMapping[platform]!;
        icons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () async {
                print('تم الضغط على أيقونة $platform: ${link.url}');
                final url = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
                print(url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('لا يمكن فتح الرابط: ${link.url}')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconData['color'].withOpacity(0.13),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(iconData['icon'], color: iconData['color'], size: 22),
              ),
            ),
          ),
        );
      }
    }
    // whatsapp
    if (space.whatsAppNumber != null && space.whatsAppNumber!.isNotEmpty) {
      final String phone = space.whatsAppNumber!.replaceAll('+', '').replaceAll(' ', '');
      icons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () async {
              print('تم الضغط على أيقونة واتساب: $phone');
              final Uri url = Uri.parse('https://wa.me/$phone');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('لا يمكن فتح الواتساب')),
                );
              }
            },
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
              child: Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 22),
            ),
          ),
        ),
      );
    }
    return icons;
  }

}
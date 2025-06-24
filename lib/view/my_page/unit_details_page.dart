import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/model/space_model.dart' hide BookingOption, SpaceUnit;
import 'package:work_spaces/model/space_units_model.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';

class UnitDetailsPage extends StatefulWidget {
  static const id = '/HallDetailsPage';
  const UnitDetailsPage({super.key});

  @override
  State<UnitDetailsPage> createState() => _UnitDetailsPageState();
}

class _UnitDetailsPageState extends State<UnitDetailsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool showBackButton = true;
  late ScrollController _scrollController;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
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
    final int? unitId = args?['unitId'] as int?;

    if (unitId == null) {
      return _buildErrorScaffold('رقم الوحدة غير صالح');
    }

    final unit = Provider.of<SpaceUnitsProvider>(context, listen: false)
        .units
        .where((u) => u.id == unitId)
        .firstOrNull;

    if (unit == null) {
      return _buildErrorScaffold('لم يتم العثور على الوحدة المطلوبة');
    }

    final space = Provider.of<SpacesProvider>(context, listen: false)
        .spaces
        .where((s) => s.id == unit.spaceId)
        .firstOrNull;

    final coverImage = (unit.imageUrl != null && unit.imageUrl!.isNotEmpty)
        ? (unit.imageUrl!.startsWith('http') ? unit.imageUrl! : baseUrlImage + unit.imageUrl!)
        : 'https://via.placeholder.com/400x300';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context, coverImage),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildAnimatedContent(unit, space),
                SizedBox(height: 20.h),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              message,
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

  SliverAppBar _buildSliverAppBar(BuildContext context, String coverImage) {
    return SliverAppBar(
      expandedHeight: 320.h,
      backgroundColor: const Color(0xFFF7F8FA),
      elevation: 0,
      pinned: true,
      floating: false,
      stretch: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: coverImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade300),
              errorWidget: (context, url, error) =>
                  Image.asset('images/app_icon.png', fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
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
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(SpaceUnit unit, Space? space) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 16.h),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUnitHeader(unit),
              if (space != null) _buildSpaceInfo(space),
              _buildSection(
                icon: Icons.info_outline,
                title: 'عن الوحدة',
                content: Text(
                  unit.description,
                  style: TextStyle(fontSize: 15.sp, height: 1.7, color: Colors.grey.shade700),
                ),
              ),
              _buildSection(
                icon: Icons.rule,
                title: 'خيارات الحجز',
                content: _buildBookingOptions(unit.bookingOptions),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitHeader(SpaceUnit unit) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.1), primaryColor1.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.business, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.name,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  unit.unitCategoryName,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceInfo(Space space) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          children: [
            _infoRow(
              Icons.location_city, 
              space.name, 
              isTitle: true ,
              onTap: () => Navigator.pushNamed(
                context,
                SpaceDetailsPage.id,
                arguments: {'spaceId': space.id},
              ),
            ),
            SizedBox(height: 12.h),
            _infoRow(Icons.location_on_outlined, space.location),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool isTitle = false, Function()? onTap}) {
    return Row(
      children: [
        Icon(icon, size: isTitle ? 20.sp : 18.sp, color: Colors.grey.shade600),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              text,
              style: TextStyle(
                fontSize: isTitle ? 18.sp : 15.sp,
                fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
                color: isTitle ? Colors.black87 : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget content}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(right: 34.w),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOptions(List<BookingOption> options) {
    if (options.isEmpty) {
      return Text('لا توجد خيارات حجز متاحة حالياً', style: TextStyle(fontSize: 14.sp));
    }
    return Column(
      children: options.map((opt) => _bookingOptionCard(opt)).toList(),
    );
  }

  Widget _bookingOptionCard(BookingOption opt) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            opt.duration, 
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            '${opt.price} ',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          Text(
           opt.currency,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
         
        ],
      ),
    );
  }
}
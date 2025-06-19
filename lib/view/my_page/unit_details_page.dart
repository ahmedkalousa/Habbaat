import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/model/space_units_model.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:work_spaces/util/constant.dart';



class UnitDetailsPage extends StatelessWidget {

  static const id = '/HallDetailsPage';
  const UnitDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final int? unitId = args != null && args['unitId'] != null ? args['unitId'] as int : null;

    return Consumer<SpaceUnitsProvider>(
      builder: (context, provider, child) {
         var spaceUnits = provider.units;
        if (unitId == null) {
          return const Center(child: Text('رقم الوحدة غير صالح'));
        }
        SpaceUnit? unit;
        try {
          unit = spaceUnits.firstWhere((u) => u.id == unitId) as SpaceUnit? ;
          // print(unit?.imageUrl);
        } catch (e) {
          unit = null;
        }
        if (unit == null) {
          return const Center(child: Text('لم يتم العثور على الوحدة المطلوبة'));
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              unit.unitCategoryName,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // صورة الوحدة
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                      child: (unit.imageUrl != null && unit.imageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: (unit.imageUrl!.startsWith('http') || unit.imageUrl!.startsWith('https'))
                                  ? unit.imageUrl!
                                  : baseUrlImage + unit.imageUrl!,
                              cacheKey: (unit.imageUrl!.startsWith('http') || unit.imageUrl!.startsWith('https'))
                                  ? unit.imageUrl!
                                  : baseUrlImage + unit.imageUrl!,
                              height: 220.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 300),
                              fadeOutDuration: Duration(milliseconds: 300),
                              maxWidthDiskCache: 800,
                              maxHeightDiskCache: 440,
                              placeholder: (context, url) => Container(
                                height: 220.h,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 220.h,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Image.asset('images/1.jpeg', height: 220.h, width: double.infinity, fit: BoxFit.cover),
                              ),
                            )
                          : Image.asset('images/1.jpeg', height: 220.h, width: double.infinity, fit: BoxFit.cover),
                    ),
                    // معلومات الوحدة الرئيسية
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(Icons.location_city, color: Colors.blueGrey, size: 22),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Consumer<SpacesProvider>(
                                    builder: (context, spacesProvider, _) {
                                      final spaces = spacesProvider.spaces;
                                      final space = spaces.where((s) => s.id == unit!.spaceId).toList();
                                      final spaceName = space.isNotEmpty ? space.first.name : 'اسم المساحة';
                                         print('unit.spaceId: ${unit?.spaceId}');
                                         print('spaces: ${spaceName}');
                                      return Text(spaceName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child:  Icon(Icons.location_on, color: Colors.blueGrey, size: 22),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Consumer<SpacesProvider>(
                                    builder: (context, spacesProvider, _) {
                                      final spaces = spacesProvider.spaces;
                                      final space = spaces.where((s) => s.id == unit!.spaceId).toList();
                                      final location = space.isNotEmpty ? space.first.location : '---';
                                      return Text(location, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            ],
                        ),
                      ),
                    ),
                    // وصف الوحدة
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade100, width: 1),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 22),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                unit.description,
                                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, height: 1.5),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // خيارات الحجز
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('خيارات الحجز:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, )),
                          SizedBox(height: 8.h),
                          unit.bookingOptions.isNotEmpty
                              ? Table(
                                  border: TableBorder.all(color: Colors.grey.shade300),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(1),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(color: Colors.grey.shade200),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          child: Center(child: Text('الخيار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp))),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          child: Center(child: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp))),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          child: Center(child: Text('العملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp))),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          child: Center(child: Text('الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp))),
                                        ),
                                      ],
                                    ),
                                    ...unit.bookingOptions.asMap().entries.map((entry) {
                                      final opt = entry.value;
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Center(child: Text(opt.duration, style: TextStyle(fontSize: 14.sp))),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Center(child: Text('${opt.price}', style: TextStyle(fontSize: 14.sp))),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Center(child: Text(opt.currency, style: TextStyle(fontSize: 14.sp))),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.credit_card, color: Colors.blue, size: 22.sp),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.paid, color: Colors.green, size: 22.sp),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                )
                              : Text('لا يوجد خيارات حجز', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
   
      },
    );
  }
}
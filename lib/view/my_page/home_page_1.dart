import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/home_page_skeleton.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_widget/my_card.dart';
import 'package:work_spaces/view/my_widget/my_mini_card.dart';
import 'package:work_spaces/view/my_widget/my_section_tile.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:work_spaces/view/my_page/search_results_page.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  static const String id = '/HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';
  TextEditingController _searchController = TextEditingController();
  bool _isConnected = true; // متغير لتتبع حالة الاتصال
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // فحص الاتصال عند بدء الصفحة
    _setupConnectivityListener(); // إعداد مراقب الاتصال
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // إلغاء المراقب عند إغلاق الصفحة
    super.dispose();
  }

  // إعداد مراقب تغييرات الاتصال
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      
      // إظهار رسالة للمستخدم عند تغيير حالة الاتصال
      if (!_isConnected) {
        showFriendlyErrorSnackBar('لا يوجد اتصال فعلي بالإنترنت');
      }
    });
  }

  // دالة فحص وجود إنترنت فعلي
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  // دالة فحص الاتصال بالإنترنت
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool connected = connectivityResult != ConnectivityResult.none;
    if (connected) {
      connected = await hasInternetConnection();
    }
    setState(() {
      _isConnected = connected;
    });
  }

  void _goToSearchPage(BuildContext context, List spaces) {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final filteredSpaces = spaces.where((space) {
      final name = space.name.toLowerCase();
      final governorate = space.governorate.toLowerCase();
      return name.contains(query.toLowerCase()) || governorate.contains(query.toLowerCase());
    }).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsPage(
          results: filteredSpaces,
          query: query,
          allSpaces: spaces,
        ),
      ),
    );
    setState(() {
      _searchController.clear();
    });
  }

  Future<void> _refreshData(BuildContext context) async {
    await _checkConnectivity();
    if (!_isConnected) {
      showFriendlyErrorSnackBar('لا يوجد اتصال فعلي بالإنترنت');
      return;
    }
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    final unitsProvider = Provider.of<SpaceUnitsProvider>(context, listen: false);
    try {
      await spacesProvider.fetchSpacesAndUnits(forceRefresh: true);
      await unitsProvider.fetchSpacesAndUnits(forceRefresh: true);
      // تحديث القوائم العشوائية
      spacesProvider.updateRandomData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12.w),
              Expanded(child: Text('تم تحديث البيانات بنجاح', style: TextStyle(color: Colors.white))),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: Duration(seconds: 3),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        ),
      );
    } catch (e) {
      showFriendlyErrorSnackBar('حدث خطأ أثناء تحديث البيانات');
    }
  }
  // دالة callback للتحديث مع فحص الاتصال
  Future<void> _conditionalRefresh() async {
    if (_isConnected) {
      await _refreshData(context);
    } else {
      showFriendlyErrorSnackBar('لا يوجد اتصال فعلي بالإنترنت');
    }
  }

  // دالة لعرض رسالة خطأ ودية وجميلة
  void showFriendlyErrorSnackBar(String? error) {
    String message;
    Color color = Colors.red;
    IconData icon = Icons.error_outline;
    if (error == null) {
      message = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      color = Colors.red;
      icon = Icons.error_outline;
    } else if (error.contains('لا يوجد اتصال فعلي بالإنترنت')) {
      message = 'يبدو أنك غير متصل بالإنترنت. يرجى التحقق من الاتصال.';
      color = Colors.orange;
      icon = Icons.wifi_off;
    } else if (error.contains('تم عرض بيانات قديمة')) {
      message = 'تم عرض بيانات قديمة بسبب عدم توفر اتصال بالسيرفر أو الإنترنت.';
      color = Colors.amber;
      icon = Icons.history;
    } else if (error.contains('حدث خطأ أثناء الاتصال بالسيرفر')) {
      message = 'حدث خطأ أثناء الاتصال بالخادم. يرجى المحاولة لاحقاً.';
      color = Colors.redAccent;
      icon = Icons.cloud_off;
    } else {
      message = error;
      color = Colors.red;
      icon = Icons.error_outline;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: Duration(seconds: 3),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return Consumer<SpacesProvider>(
      builder: ( context, provider, child) {  
          if (provider.loading && !provider.isInitialized) {
            return HomePageSkeleton();
          }
          if (provider.spaces.isEmpty && provider.isInitialized) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          }
          if (provider.error != null && provider.spaces.isEmpty) {
            String message;
              message = 'لا توجد بيانات متاحة حالياً. تأكد من اتصالك بالإنترنت وحاول مرة أخرى.';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 48),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => _refreshData(context),
                    icon: Icon(Icons.refresh),
                    label: Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            );
          }
          // فلترة المساحات حسب البحث
          provider.spaces.where((space) {
            final name = space.name.toLowerCase();
            final governorate = space.governorate.toLowerCase();
            final query = searchText.toLowerCase();
            return name.contains(query) || governorate.contains(query);
          }).toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              body: LiquidPullToRefresh(
                height: 100.h,
                onRefresh: _conditionalRefresh,
                color: primaryColor,
                backgroundColor: Colors.white,
                animSpeedFactor: 2.0,
                showChildOpacityTransition: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.spaces.isEmpty || provider.spaces[0].images.isEmpty)
                        SizedBox(
                          height: 200.h,
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      else
                        Stack(
                          children: [
                            Image.asset(
                              "images/main_header_1.png", 
                            width: 1.sw, 
                            height: 200.h, 
                            fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.blue.withOpacity(0.8),
                                    Colors.blue.withOpacity(0.6),
                                    Colors.blue.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 110.h,
                              right: 12.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مرحباً بك!",
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                  SizedBox(height: 4.w),
                                  Text(
                                    "استكشف المساحات القريبة منك",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      Padding(
                        padding: EdgeInsets.all(16.h),
                        child: Material(
                          elevation: 1,
                          shadowColor: Colors.grey,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textDirection: TextDirection.rtl,
                                  decoration: InputDecoration(
                                    hintText: "ابحث عن مساحة أو محافظة",
                                    hintTextDirection: TextDirection.rtl,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
                                  ),
                                  onSubmitted: (_) => _goToSearchPage(context, provider.spaces),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.search, color: Colors.white, size: 24.sp),
                                  color: primaryColor,
                                  onPressed: () => _goToSearchPage(context, provider.spaces),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      MySectionTile(title:  "تصنيفات القاعات"),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              MyCard(
                                text: 'غرفة شخصية',
                                iconData: Icons.person,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    UnitsPage.id,
                                    arguments: {'unitCategoryName': 'غرفة شخصية'},
                                  );
                                },
                              ), 
                              MyCard(
                                text: 'مساحة تشاركية',
                                iconData: Icons.safety_divider,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    UnitsPage.id,
                                    arguments: {'unitCategoryName': 'مساحة تشاركية'},
                                  );
                                },
                              ),
                              MyCard(
                                text: 'قاعة تدريب',
                                iconData: Icons.co_present,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    UnitsPage.id,
                                    arguments: {'unitCategoryName': 'قاعة تدريب'},
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        MySectionTile(title: "المساحات المتاحة"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.randomSpaces.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 8.w,
                              childAspectRatio: 1.7,
                              mainAxisSpacing: 8.h),
                            itemBuilder: (context, index) {
                              return MyMiniCard(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    SpaceDetailsPage.id,
                                    arguments: {'spaceId': provider.randomSpaces[index].id},
                                  );
                                },
                                imagePath: baseUrlImage + provider.randomSpaces[index].images[0].imageUrl,
                                title: provider.randomSpaces[index].name,
                                subtitle: provider.randomSpaces[index].location,
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MySectionTile(title: "الوحدات المتاحة"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, UnitsPage.id);
                              },
                              child: Text("عرض المزيد", style: TextStyle(color: primaryColor, fontSize: 16.sp)),
                            ),
                          ],
                        ),
                        Consumer<SpaceUnitsProvider>(
                          builder: (context, value, child) {
                            if (value.loading && !value.isInitialized) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (value.units.isEmpty && value.isInitialized) {
                              return const Center(child: Text('لا توجد وحدات متاحة'));
                            }
                            if (value.error != null && value.units.isEmpty) {
                              return Center(child: Text('خطأ: ${value.error}'));
                            }
                            
                            if (provider.randomUnits.isEmpty) {
                              return const Center(child: Text('لا توجد وحدات متاحة'));
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: GridView.builder(
                                itemCount: provider.randomUnits.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.w,
                                  childAspectRatio: 0.8,
                                  mainAxisSpacing: 8.h,
                                ),
                                itemBuilder: (context, index) {
                                  String uniteSpaceLocation = provider.spaces.firstWhere(
                                    (space) => space.id == provider.randomUnits[index].spaceId,
                                    orElse: () => provider.spaces[0],
                                  ).governorate;
                                  return MyMiniCard(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        UnitDetailsPage.id,
                                        arguments: {'unitId': provider.randomUnits[index].id},
                                      );
                                    },
                                    imagePath: baseUrlImage + (provider.randomUnits[index].imageUrl ?? ''),
                                    title: provider.randomUnits[index].unitCategoryName,
                                    subtitle: uniteSpaceLocation,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        );
      }
    );
  }
}


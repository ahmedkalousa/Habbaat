import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_wedgit/my_card.dart';
import 'package:work_spaces/view/my_wedgit/my_mini_card.dart';
import 'package:work_spaces/view/my_wedgit/my_section_tile.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:work_spaces/view/my_page/search_results_page.dart';

class HomePage extends StatefulWidget {
  static const String id = '/HomePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';
  TextEditingController _searchController = TextEditingController();

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

  // دالة جديدة لتحديث البيانات يدوياً
  Future<void> _refreshData(BuildContext context) async {
    final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
    final unitsProvider = Provider.of<SpaceUnitsProvider>(context, listen: false);
    
    await spacesProvider.fetchSpacesAndUnits(forceRefresh: true);
    await unitsProvider.fetchSpacesAndUnits(forceRefresh: true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث البيانات بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<SpacesProvider>(
      builder: ( context, provider, child) {  
          if (provider.loading && !provider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.spaces.isEmpty && provider.isInitialized) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          }
          if (provider.error != null) {
            return Center(child: Text('خطأ: [31m${provider.error}[0m'));
          }
          // فلترة المساحات حسب البحث
          final filteredSpaces = provider.spaces.where((space) {
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
              body: RefreshIndicator(
                onRefresh: () async {
                  await _refreshData(context);
                },
                child: SingleChildScrollView(
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
                            CachedNetworkImage(
                              imageUrl: (provider.spaces[0].images.length > 1)
                                  ? baseUrlImage + provider.spaces[0].images[1].imageUrl
                                  : baseUrlImage + provider.spaces[0].images[0].imageUrl,
                              cacheKey: (provider.spaces[0].images.length > 1)
                                  ? baseUrlImage + provider.spaces[0].images[1].imageUrl
                                  : baseUrlImage + provider.spaces[0].images[0].imageUrl,
                              width: 1.sw,
                              height: 200.h,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 300),
                              fadeOutDuration: Duration(milliseconds: 300),
                              maxWidthDiskCache: 800,
                              maxHeightDiskCache: 400,
                              useOldImageOnUrlChange: true,
                              placeholder: (context, url) => Container(
                                width: 1.sw,
                                height: 200.h,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  width: 1.sw,
                                  height: 200.h,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.error, size: 50.sp, color: Colors.red),
                                );
                              },
                            ),
                            Container(
                              height: 200.h,
                              color: Colors.black.withOpacity(0.5),
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
                                  SizedBox(height: 4.h),
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
                        padding: EdgeInsets.all(16.w),
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
                                    contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                      // عند البحث، اعرض فقط المساحات الشائعة المطابقة للبحث
                      if (searchText.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MySectionTile(title: "المساحات الشائعة"),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: GridView.builder(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredSpaces.length < 4 ? filteredSpaces.length : 4,
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
                                        arguments: {'spaceId': filteredSpaces[index].id},
                                      );
                                    },
                                    imagePath: baseUrlImage + filteredSpaces[index].images[0].imageUrl,
                                    title: filteredSpaces[index].name,
                                    subtitle: filteredSpaces[index].governorate,
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      else ...[
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
                        MySectionTile(title: "المساحات الشائعة"),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: GridView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.spaces.length < 4 ? provider.spaces.length : 4,
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
                                    arguments: {'spaceId': provider.spaces[index].id},
                                  );
                                },
                                imagePath: baseUrlImage + provider.spaces[index].images[0].imageUrl,
                                title: provider.spaces[index].name,
                                subtitle: provider.spaces[index].location,
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MySectionTile(title: "جديد هذا الأسبوع"),
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
                            if (value.error != null) {
                              return Center(child: Text('خطأ: ${value.error}'));
                            }
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: GridView.builder(
                                itemCount: value.units.length < 4 ? value.units.length : 4,
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
                                    (space) => space.id == value.units[index].spaceId,
                                    orElse: () => provider.spaces[0],
                                  ).governorate;
                                  return MyMiniCard(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        UnitDetailsPage.id,
                                        arguments: {'unitId': value.units[index].id},
                                      );
                                    },
                                    imagePath: baseUrlImage + value.units[index].imageUrl!,
                                    title: value.units[index].unitCategoryName,
                                    subtitle: uniteSpaceLocation,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
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


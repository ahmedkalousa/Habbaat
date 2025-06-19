import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_wedgit/my_contact_icon.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/model/space_model.dart';
import 'package:work_spaces/view/my_wedgit/my_mini_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpaceDetailsPage extends StatefulWidget {
  static const id = '/SpaceDetailsPage';
  const SpaceDetailsPage({super.key});

  @override
  State<SpaceDetailsPage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpaceDetailsPage> {

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    Space? space;
    int? spaceId;

    if (routeArgs is Space) {
      space = routeArgs;
      spaceId = space.id;
    } else if (routeArgs is Map && routeArgs['spaceId'] != null) {
      spaceId = routeArgs['spaceId'] as int;
      final spaces = Provider.of<SpacesProvider>(context).spaces;
      try {
        space = spaces.firstWhere((s) => s.id == spaceId);
      } catch (_) {
        space = null;
      }
    }

    if (spaceId == null || space == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('لم يتم العثور على المساحة المطلوبة')),
      );
    }

    // 1. سلايد شو صور المساحة
    final List<String> images = space.images.isNotEmpty
        ? space.images.map((img) => baseUrlImage + img.imageUrl).toList()
        : ['images/1.jpeg'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // السلايد شو (يبقى كما هو)
              SizedBox(
                height: 240,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final img = images[index];
                    return ClipRRect(
                   
                      child: img.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: img,
                              cacheKey: img,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              fadeInDuration: Duration(milliseconds: 300),
                              fadeOutDuration: Duration(milliseconds: 300),
                              maxWidthDiskCache: 800,
                              maxHeightDiskCache: 480,
                              placeholder: (context, url) => Container(
                                width: double.infinity,
                                height: 240,
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: double.infinity,
                                height: 240,
                                color: Colors.grey[300],
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            )
                          : Image.asset(img, fit: BoxFit.cover, width: double.infinity),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.blue : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              // معلومات المساحة الرئيسية
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              space.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // تقييم النجوم
                          Row(
                            children: List.generate(5, (i) {
                              double rating = space!.rating;
                              if (i < rating.floor()) {
                                return const Icon(Icons.star, color: Colors.amber, size: 22);
                              } else if (i < rating && rating - i >= 0.5) {
                                return const Icon(Icons.star_half, color: Colors.amber, size: 22);
                              } else {
                                return const Icon(Icons.star_border, color: Colors.amber, size: 22);
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on, color: Colors.blueGrey, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              space.location,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.phone, color: Colors.green, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(space.contactNumber, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // وصف المساحة
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          space.bio,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.5),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // جهات التواصل
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // نص تواصل معنا
                      const Text(
                        'تواصل معنا:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ContactIcon(
                        icon: FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      ContactIcon(
                        icon: Icons.facebook,
                        color: Colors.blue[800]!,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              // قائمة الوحدات
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0 , vertical: 8.0),
                child: Text(
                  
                  'الوحدات المتوفرة:',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              if (space.spaceUnits.isEmpty)
                const Center(child: Text('لا توجد وحدات متاحة'))
              else
                GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: space.spaceUnits.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemBuilder: (context, index) {
                    final unit = space?.spaceUnits[index];
                    String? imageUrl;
                    try {
                      imageUrl = (unit as dynamic).imageUrl;
                    } catch (_) {
                      imageUrl = null;
                    }
                    return MyMiniCard(
                      imagePath: imageUrl != null && imageUrl.isNotEmpty
                          ? baseUrlImage + imageUrl
                          : 'images/1.jpeg',
                      title: unit!.name,
                      subtitle: space!.location,
                      onTap: () {
                        Navigator.pushNamed(context, UnitDetailsPage.id, arguments: {'unitId': unit.id});
                      },
                    );
                  },
                ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

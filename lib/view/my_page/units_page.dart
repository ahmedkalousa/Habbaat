import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_widget/my_mini_card.dart';
import 'package:work_spaces/model/space_model.dart';

class UnitsPage extends StatefulWidget {
   static const id= '/SingleRoom';
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  String? selectedLocation;
  String? selectedUnitCategory;
  String? selectedBookingOption;
  double? selectedRating;
  String searchText = '';
  String? filterUnitCategoryName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['unitCategoryName'] is String) {
      filterUnitCategoryName = args['unitCategoryName'] as String;
      selectedUnitCategory ??= filterUnitCategoryName;
    } else {
      filterUnitCategoryName = null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'القاعات',
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        body: Consumer<SpaceUnitsProvider>(
          builder: (context, provider, child) {
            final allUnits = provider.units;
            final spacesProvider = Provider.of<SpacesProvider>(context, listen: false);
            final allSpaces = spacesProvider.spaces;
            // استخراج القيم الفريدة للفلاتر من المساحات
            final locations = allSpaces.map((s) => s.governorate).toSet().toList();
            final unitCategories = allUnits
                .map((u) => u.unitCategoryName)
                .where((cat) => cat.trim().isNotEmpty)
                .map((cat) => cat.trim())
                .toSet()
                .toList();
            final bookingOptions = allUnits.expand((u) => u.bookingOptions.map((b) => b.duration)).toSet().toList();

            final filteredUnits = allUnits.where((unit) {
              Space? parentSpace;
              try {
                parentSpace = allSpaces.firstWhere((space) => space.id == unit.spaceId);
              } catch (e) {
                parentSpace = null;
              }
              final parentLocation = parentSpace != null ? parentSpace.governorate : null;
              final matchesLocation = selectedLocation == null || selectedLocation!.isEmpty || (parentLocation != null && parentLocation == selectedLocation);
              final matchesCategory = selectedUnitCategory == null
                  || (unit.unitCategoryName.trim() == selectedUnitCategory!.trim());
              final matchesBooking = selectedBookingOption == null || selectedBookingOption!.isEmpty || unit.bookingOptions.any((b) => b.duration == selectedBookingOption);
              final matchesRating = selectedRating == null || (unit.bookingOptions.isNotEmpty && unit.bookingOptions.any((b) => (b.price as num?)?.toDouble() == selectedRating));
              final matchesSearch = searchText.isEmpty ||
                (parentSpace != null && parentSpace.name.contains(searchText)) ||
                (unit.name.contains(searchText));
              return matchesLocation && matchesCategory && matchesBooking && matchesRating && matchesSearch;
            }).toList();
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (allUnits.isEmpty) {
              return const Center(child: Text('لا توجد بيانات متاحة'));
            }
            if (provider.error != null) {
              return Center(child: Text('خطأ: \u001b[31m[31m${provider.error}\u001b[0m'));
            }
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث عن مساحة...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                      SizedBox(height: 16,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // الموقع
                                  FilterChip(
                                    label: Text(selectedLocation ?? 'كل المواقع'),
                                    selected: selectedLocation != null,
                                    onSelected: (_) async {
                                      final result = await showModalBottomSheet<String>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        backgroundColor: Colors.white,
                                        builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 40,
                                                    height: 4,
                                                    margin: const EdgeInsets.only(bottom: 16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                const Text('اختر الموقع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                const SizedBox(height: 12),
                                                ListTile(
                                                  leading: const Icon(Icons.location_on, color: Colors.blue),
                                                  title: const Text('كل المواقع'),
                                                  onTap: () => Navigator.pop(context, null),
                                                ),
                                                ...locations.map((loc) => ListTile(
                                                  leading: const Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                                                  title: Text(loc),
                                                  onTap: () => Navigator.pop(context, loc),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      setState(() => selectedLocation = result);
                                    },
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: Colors.blue[100],
                                  ),
                                  SizedBox(width: 8),
                                  // نوع القاعة
                                  FilterChip(
                                    label: Text(selectedUnitCategory ?? 'كل الأنواع'),
                                    selected: selectedUnitCategory != null,
                                    onSelected: (_) async {
                                      final result = await showModalBottomSheet<String>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        backgroundColor: Colors.white,
                                        builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 40,
                                                    height: 4,
                                                    margin: const EdgeInsets.only(bottom: 16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                const Text('اختر نوع القاعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                const SizedBox(height: 12),
                                                ListTile(
                                                  leading: const Icon(Icons.category, color: Colors.teal),
                                                  title: const Text('كل الأنواع'),
                                                  onTap: () => Navigator.pop(context, null),
                                                ),
                                                ...unitCategories.map((cat) => ListTile(
                                                  leading: const Icon(Icons.category_outlined, color: Colors.teal),
                                                  title: Text(cat),
                                                  onTap: () => Navigator.pop(context, cat),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        selectedUnitCategory = result == null ? null : result;
                                      });
                                    },
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: Colors.teal[100],
                                  ),
                                  SizedBox(width: 8),
                                  // مدة الحجز
                                  FilterChip(
                                    label: Text(selectedBookingOption ?? 'كل المدد'),
                                    selected: selectedBookingOption != null,
                                    onSelected: (_) async {
                                      final result = await showModalBottomSheet<String>(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        backgroundColor: Colors.white,
                                        builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    width: 40,
                                                    height: 4,
                                                    margin: const EdgeInsets.only(bottom: 16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                const Text('اختر مدة الحجز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                const SizedBox(height: 12),
                                                ListTile(
                                                  leading: const Icon(Icons.access_time, color: Colors.deepOrange),
                                                  title: const Text('كل المدد'),
                                                  onTap: () => Navigator.pop(context, null),
                                                ),
                                                ...bookingOptions.map((opt) => ListTile(
                                                  leading: const Icon(Icons.access_time_outlined, color: Colors.deepOrange),
                                                  title: Text(opt),
                                                  onTap: () => Navigator.pop(context, opt),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      setState(() => selectedBookingOption = result);
                                    },
                                    backgroundColor: Colors.grey[100],
                                    selectedColor: Colors.deepOrange[100],
                                  ),
                                  // ... أضف المزيد من الفلاتر هنا إذا لزم الأمر
                                ],
                              ),
                            ),
                          ),
                          // زر مسح الفلاتر ثابت
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'مسح الفلاتر',
                            onPressed: () {
                              setState(() {
                                selectedLocation = null;
                                selectedUnitCategory = null;
                                selectedBookingOption = null;
                                selectedRating = null;
                                searchText = '';
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredUnits.isEmpty
                      ? const Center(child: Text('لا توجد قاعات متاحة'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredUnits.length,
                          itemBuilder: (context, index) {
                            final unit = filteredUnits[index];
                            final imagePath = (unit.imageUrl != null && unit.imageUrl!.isNotEmpty)
                                ? (unit.imageUrl!.startsWith('http')
                                    ? unit.imageUrl!
                                    : baseUrlImage + unit.imageUrl!)
                                : 'images/2.jpeg';
                            return MyMiniCard(
                              onTap: () {
                                 Navigator.pushNamed(
                                  context,
                                  UnitDetailsPage.id,
                                  arguments: {'unitId': unit.id},
                                );
                              },
                              imagePath: imagePath,
                              title: unit.name,
                              subtitle: unit.unitCategoryName,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_wedgit/my_mini_card.dart';
import 'package:work_spaces/view/my_wedgit/my_unit_type_tile.dart';

class SpacesPage extends StatefulWidget {
  static const id = '/HallsPage';
  const SpacesPage({super.key});

  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  // استخرج جميع أنواع تصنيفات الوحدات من SpaceUnitsProvider
  List<String> get allUnitTypes => Provider.of<SpaceUnitsProvider>(context, listen: false)
      .units
      .map((unit) => unit.unitCategoryName)
      .toSet()
      .toList();

 
  String searchQuery = '';
  String? selectedGovernorate;
  List<String> selectedUnitCategoryList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'المساحات',
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      ),
      body: Consumer<SpacesProvider>(
        builder: (context, provider, child) {
          provider.spaces
              .expand((space) => space.spaceUnits.map((unit) => unit.name))
              .toSet()
              .toList();

          // فلترة حسب البحث والمحافظة وتصنيفات الوحدات (متعدد)
          final filteredSpaces = provider.spaces.where((space) {
            final matchesSearch = searchQuery.isEmpty ||
                space.name.contains(searchQuery) ||
                space.location.contains(searchQuery);

            // فلترة حسب المنطقة فقط أو نوع الوحدة فقط أو كلاهما
            final filterByGovernorate = selectedGovernorate != null && selectedGovernorate!.isNotEmpty;
            final filterByUnitType = selectedUnitCategoryList.isNotEmpty;

            bool matchesGovernorate = true;
            bool matchesUnitCategory = true;

            if (filterByGovernorate && !filterByUnitType) {
              // فلترة حسب المنطقة فقط

              matchesGovernorate = space.governorate == selectedGovernorate;
            } else if (!filterByGovernorate && filterByUnitType) {
              // فلترة حسب نوع الوحدة فقط (من SpaceUnitsProvider)
              matchesUnitCategory = space.spaceUnits.any((unit) {
                final matchUnit = Provider.of<SpaceUnitsProvider>(context, listen: false)
                    .units
                    .where((u) => u.id == unit.id)
                    .toList();
                final unitCategoryName = matchUnit.isNotEmpty ? matchUnit.first.unitCategoryName : '';
                return selectedUnitCategoryList.contains(unitCategoryName);
              });
            } else if (filterByGovernorate && filterByUnitType) {
              // كلا الفلترين
              matchesGovernorate = space.governorate == selectedGovernorate;
              matchesUnitCategory = space.spaceUnits.any((unit) {
                final matchUnit = Provider.of<SpaceUnitsProvider>(context, listen: false)
                    .units
                    .where((u) => u.id == unit.id)
                    .toList();
                final unitCategoryName = matchUnit.isNotEmpty ? matchUnit.first.unitCategoryName : '';
                return selectedUnitCategoryList.contains(unitCategoryName);
              });
            }

            return matchesSearch && matchesGovernorate && matchesUnitCategory;
          }).toList();

          // تصميم البحث والفلاتر (Chips)
          final governorates = provider.spaces.map((s) => s.governorate).toSet().toList();
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0 , vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مساحة...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.filter_alt, size: 25,color: Colors.white),
                            tooltip: 'تصفية',
                            onPressed: () async {
                              // استخدم AwesomeDialog
                              List<String> tempUnit = List<String>.from(selectedUnitCategoryList);
                              String? tempGov = selectedGovernorate;
                              final unitTypes = allUnitTypes;
                              final unitTypeIcons = <String, IconData>{
                                // Customize icons for known types, fallback to default
                                'غرفة شخصية': Icons.person,
                                'مساحة تشاركية': Icons.groups,
                                'قاعة تدريب': Icons.meeting_room,
                              };
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        textDirection: TextDirection.rtl,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            textDirection: TextDirection.rtl,
                                            children: [
                                              Icon(Icons.filter_alt, color: primaryColor, size: 28),
                                              const SizedBox(width: 8),
                                              const Text('تصفية النتائج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                              Spacer(),
                                              IconButton(
                                                icon: Icon(Icons.close, color: Colors.grey[600]),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            ':أنواع الوحدات',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          ...unitTypes.map((type) => Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: MyUnitTypeTile(
                                              label: type,
                                              icon: unitTypeIcons[type] ?? Icons.category,
                                              selected: tempUnit.contains(type),
                                              onTap: () {
                                                if (tempUnit.contains(type)) {
                                                  tempUnit.remove(type);
                                                } else {
                                                  tempUnit.add(type);
                                                }
                                                (context as Element).markNeedsBuild();
                                              },
                                            ),
                                          )),
                                          const Divider(height: 24),
                                          const Text(':المنطقة', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Wrap(
                                            direction: Axis.horizontal,
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: governorates.map((gov) {
                                              return ChoiceChip(
                                                backgroundColor: Colors.white,
                                                selectedShadowColor: Colors.transparent,
                                                label: Text(gov),
                                                selected: tempGov == gov,
                                                selectedColor: primaryColor1,
                                                labelStyle: TextStyle(
                                                  color: tempGov == gov ? Colors.white : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                  
                                                 iconTheme: IconThemeData(
                                                  color: tempGov == gov ? Colors.white : Colors.black,),
                                                onSelected: (selected) {
                                                  tempGov = selected ? gov : null;
                                                  (context as Element).markNeedsBuild();
                                                },
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      selectedUnitCategoryList = [];
                                                      selectedGovernorate = null;
                                                    });
                                                  },
                                                  child: const Text('مسح الكل'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: primaryColor,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      selectedUnitCategoryList = tempUnit;
                                                      selectedGovernorate = tempGov;
                                                    });
                                                  },
                                                  child: const Text('تأكيد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  filteredSpaces.isEmpty
                      ? Center(child: Text('لا توجد نتائج'))
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.7,
                          ),
                          itemCount: filteredSpaces.length,
                          itemBuilder: (context, index) {
                            final space = filteredSpaces[index];
                            return MyMiniCard(
                              onTap: () {
                                Navigator.pushNamed( context,SpaceDetailsPage.id, arguments: space);
                              },
                              imagePath: baseUrlImage + space.images[0].imageUrl,
                              title: space.name,
                              subtitle: space.location,
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
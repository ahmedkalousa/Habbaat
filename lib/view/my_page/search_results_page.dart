import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_widget/my_mini_card.dart';

class SearchResultsPage extends StatefulWidget {
  final List results;
  final String query;
  final List allSpaces;
  const SearchResultsPage({Key? key, required this.results, required this.query, required this.allSpaces}) : super(key: key);

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _controller;
  late List filteredResults;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    filteredResults = widget.results;
  }

  void _search(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      filteredResults = widget.allSpaces.where((space) {
        final name = space.name.toLowerCase();
        final governorate = space.governorate.toLowerCase();
        return name.contains(query) || governorate.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('نتائج البحث'),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Material(
                elevation: 1,
                shadowColor: Colors.grey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: "ابحث عن مساحة أو موقع",
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        ),
                        onSubmitted: _search,
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
                        onPressed: () => _search(_controller.text),
                      ),
                    ),
                  
                  ],
                ),
              ),
            ),
            filteredResults.isEmpty
                ? Center(child: Text('لا يوجد نتائج', style: TextStyle(fontSize: 16.sp)))
                : Expanded(
                  child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            crossAxisSpacing: 8.w,
                            childAspectRatio: 1.7,
                            mainAxisSpacing: 8.h),
                      padding: EdgeInsets.all(16.w),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        final space = filteredResults[index];
                        return MyMiniCard(
                          imagePath:baseUrlImage + space.images[0].imageUrl ,
                         
                            title: space.name,
                            subtitle: space.governorate,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                SpaceDetailsPage.id,
                                arguments: {'spaceId': space.id},
                              );
                            },
                        );
                      },
                    ),
                ),
          ],
        ),
      ),
    );
  }
}

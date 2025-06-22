import 'package:flutter/material.dart';
import 'package:work_spaces/view/my_page/home_page_1.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/map_page.dart';
import 'package:work_spaces/view/my_page/list_page.dart';
import 'package:work_spaces/view/my_page/spaces_page.dart';

class mainHomePage extends StatefulWidget {
  static const id = '/mainHomePage';
  final int currentIndex;

  mainHomePage({super.key, this.currentIndex = 0});

  @override
  State<mainHomePage> createState() => _mainHomePageState();
}

class _mainHomePageState extends State<mainHomePage> {
  late int currentIndex;

  List<Widget> screensList = [
    const HomePage(),
    const SpacesPage(),
    const MapPage(),
    const ListPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                backgroundColor: primaryColor,
                type: BottomNavigationBarType.fixed,
                onTap: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                currentIndex: currentIndex,
                elevation: 0,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.7),
                selectedLabelStyle: 
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: 
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
                  BottomNavigationBarItem(icon: Icon(Icons.location_city), label: 'المساحات'),
                  BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'المبادرات'),
                  BottomNavigationBarItem(icon: Icon(Icons.list), label: 'القائمة'),
                ],
              ),
            ),
          ),
        ),
        body: screensList[currentIndex],
        extendBody: true,
      ),
    );
  }
}
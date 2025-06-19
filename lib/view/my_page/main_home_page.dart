
import 'package:flutter/material.dart';
import 'package:work_spaces/view/my_page/home_page_1.dart';
import 'package:work_spaces/util/constant.dart';
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BottomNavigationBar(
              backgroundColor: primaryColor,
              onTap: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              currentIndex: currentIndex,
              elevation: 0,
              selectedFontSize: 16,
              unselectedIconTheme: const IconThemeData(color: Colors.white),
              selectedItemColor: primaryColor1,
              unselectedItemColor: Colors.white,
              selectedLabelStyle: TextStyle(color: primaryColor1),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'المساحات'),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: 'القائمة'),
              ],
            ),
          ),
        ),
        body: screensList[currentIndex],
        extendBody: true,
      ),
    );
  }
}


// class mainHomePage extends StatefulWidget {
//   static const id = '/mainHomePage';
//   int currentIndex = 0;

//    mainHomePage({super.key , currentIndex});

//   @override
//   State<mainHomePage> createState() => _mainHomePageState();
// }

// class _mainHomePageState extends State<mainHomePage>
//     with SingleTickerProviderStateMixin {

//   List<Widget?> screensList = [
//     const HomePage(),
//     const SpacesPage(),
//     const ListPage()
//   ];


//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         bottomNavigationBar: Padding(
//         padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//           child: ClipRRect(
//              borderRadius: BorderRadius.circular(50),
//              child: BottomNavigationBar(  
//               backgroundColor: primaryColor,
//               onTap: (value) {
//                 setState(() {
//                   widget.currentIndex = value;
//                 });
//               },
//               currentIndex: widget.currentIndex,
//               elevation: 0,
//               selectedFontSize: 16,
//               unselectedIconTheme: IconThemeData(color: Colors.white),
//               selectedItemColor: primaryColor1,
//               unselectedItemColor: Colors.white,
//               selectedLabelStyle: TextStyle(color: primaryColor1),
//               unselectedLabelStyle:
//                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//              items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
//               BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'المساحات'),
//               BottomNavigationBarItem(icon: Icon(Icons.list), label: 'القائمة'),
//             ], ),
//           ),
//         ),
//         body: screensList[widget.currentIndex],
//         extendBody: true,
//       ),
//     );
//   }
// }

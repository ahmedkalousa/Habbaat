import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/main_home_page.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:work_spaces/view/my_page/map_page.dart';


class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF7F8FA);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (logo and name)
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/logo.png'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6, // أو أي نسبة تناسب التصميم
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DrawerItem(
                          icon: Icons.home,
                          label: 'الرئيسية',
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) {
                                return mainHomePage(currentIndex: 0,);
                              },
                            ));
                          },
                          color: primaryColor,
                        ),
                        _DrawerItem(
                          icon: Icons.location_city,
                          label: 'المساحات',
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (context) {
                                return mainHomePage(currentIndex: 1,);
                              },
                            ));
                          },
                          color: primaryColor,
                        ),
                        _DrawerItem(
                          icon: Icons.lightbulb,
                          label: 'المبادرات',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return mainHomePage(currentIndex: 2,);
                              },
                            ));
                          },
                          color: primaryColor,
                        ),
                        _DrawerItem(
                          icon: Icons.meeting_room,
                          label: 'القاعات',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return UnitsPage();
                              },
                            ));
                          },
                          color: primaryColor,
                        ),
                        
                        Spacer(),
                        Card(
                          color: primaryColor.withOpacity(0.6),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // احذف أي صف أو عمود أو Padding أو Row أو GestureDetector أو Text أو أي عنصر يعرض أو يتعامل مع بيانات تواصل (MySocialMediaIcon، روابط، إلخ)
                              ],
                            ),
                          ),
                        ),
                     ],
                    ),
                  ),
                ),
             ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        elevation: 3, // مقدار الظل
        shadowColor: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white, // لون الخلفية
        child: ListTile(
          leading: Icon(icon, color: color, size: 26),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          hoverColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.12),
          tileColor: Colors.transparent,
        ),
      ),
    );
  }
}

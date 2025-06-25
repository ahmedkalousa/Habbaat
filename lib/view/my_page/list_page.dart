import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:work_spaces/util/constant.dart';
import 'package:work_spaces/view/my_page/main_home_page.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:work_spaces/view/my_widget/my_social_media_icon.dart';


class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
    // دالة مساعدة لفتح الروابط الخارجية
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url) == false) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح الرابط: $urlString')),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الرابط: $urlString')),
        );
    }
  }

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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    MySocialMediaIcon(iconData: FontAwesomeIcons.whatsapp,onTap: () {
                                      _launchUrl('https://wa.me/+970566970710');
                                    }),
                                    MySocialMediaIcon(iconData: FontAwesomeIcons.facebook,onTap: () {
                                      _launchUrl('https://www.facebook.com/habbaatps');
                                    }),
                                    MySocialMediaIcon(iconData: FontAwesomeIcons.instagram,onTap: () {
                                      _launchUrl('https://www.instagram.com/habbaat_ps');
                                    }),
                                    MySocialMediaIcon(iconData: FontAwesomeIcons.tiktok,onTap: () {
                                      _launchUrl('https://www.tiktok.com/@habbaat_ps');
                                    }),
                                    MySocialMediaIcon(iconData: FontAwesomeIcons.twitter,onTap: () {
                                      _launchUrl('https://www.twitter.com/habbaat');
                                    }),
                                  ],
                                ),
                                SizedBox(height: 16,),
                                 InkWell(
                                  onTap: () => _launchUrl('https://www.habbaat.net'),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Text(' أو عبر الموقع:', style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ), ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'www.habbaat.net',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 6,),
                                      Icon(Icons.language, color: Colors.white, size: 22),
                    
                                    ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/view/my_page/home_page_1.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/view/my_page/favorite_page.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_page/splash_page.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_page/spaces_page.dart';
import 'package:work_spaces/view/my_page/main_home_page.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:work_spaces/model/local_database.dart';
import 'dart:async';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SpacesProvider spacesProvider;
  late final SpaceUnitsProvider unitsProvider;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    spacesProvider = SpacesProvider();
    unitsProvider = SpaceUnitsProvider();
    _initData();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) async {
      final isOnline = result != ConnectivityResult.none;
      if (_isOnline != isOnline) {
        _isOnline = isOnline;
        await _fetchAndCache(isOnline);
        if (isOnline) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث البيانات من السيرفر'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _initData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    _isOnline = isOnline;
    await _fetchAndCache(isOnline);
  }

  Future<void> _fetchAndCache(bool isOnline) async {
    await spacesProvider.fetchSpacesAndUnits(isOnline: isOnline, forceRefresh: true);
    await unitsProvider.fetchSpacesAndUnits(isOnline: isOnline, forceRefresh: true);
    if (isOnline) {
      await LocalDatabase.saveSpaces(spacesProvider.spaces);
      await LocalDatabase.saveUnits(unitsProvider.units);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => spacesProvider),
        ChangeNotifierProvider(create: (context) => unitsProvider),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const splashPage(),
          routes: {
            mainHomePage.id: (context) =>  mainHomePage(),
            HomePage.id: (context) => const HomePage(),
            SpacesPage.id: (context) => const SpacesPage(),
            FavoritePage.id: (context) => const FavoritePage(),
            UnitsPage.id: (context) => const UnitsPage(),
            UnitDetailsPage.id: (context) => UnitDetailsPage(),
            SpaceDetailsPage.id: (context) => const SpaceDetailsPage(),
          },
        ),
      ),
    );
  }
}

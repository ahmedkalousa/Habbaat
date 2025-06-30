import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_spaces/provider/space_units_provider.dart';
import 'package:work_spaces/view/my_page/home_page_1.dart';
import 'package:work_spaces/provider/my_provider.dart';
import 'package:work_spaces/view/my_page/favorite_page.dart';
import 'package:work_spaces/view/my_page/initiative_page.dart';
import 'package:work_spaces/view/my_page/space_details_page.dart';
import 'package:work_spaces/view/my_page/unit_details_page.dart';
import 'package:work_spaces/view/my_page/spaces_page.dart';
import 'package:work_spaces/view/my_page/main_home_page.dart';
import 'package:work_spaces/view/my_page/units_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:work_spaces/model/local_database.dart';
import 'dart:async';
import 'dart:math';
import 'package:work_spaces/util/connectivity_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpacesProvider()),
        ChangeNotifierProvider(create: (_) => SpaceUnitsProvider()),
      ],
      child: ConnectivityHandler(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SpacesProvider spacesProvider;
  late final SpaceUnitsProvider unitsProvider;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    spacesProvider = SpacesProvider();
    unitsProvider = SpaceUnitsProvider();
    _initData();
    _setupConnectivityListener();
  }

  Future<void> _initData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;
    await _fetchAndCache(isOnline);
  }

  Future<void> _fetchAndCache(bool isOnline) async {
    // 1. جلب كل البيانات من السيرفر أو الكاش
    await spacesProvider.fetchSpacesAndUnits(isOnline: isOnline, forceRefresh: true);
    await unitsProvider.fetchSpacesAndUnits(isOnline: isOnline, forceRefresh: true);

    // 2. فقط عند الاتصال بالإنترنت، نقوم بتحديث الكاش ببيانات عشوائية
    if (isOnline) {
      final allSpaces = spacesProvider.spaces;
      if (allSpaces.isNotEmpty) {
        // 1. اختر فقط المساحات التي لديها وحدات
        final spacesWithUnits = allSpaces.where((s) => s.spaceUnits.isNotEmpty).toList();
        // 2. خلط قائمة المساحات واختيار 6 منها (أو أقل إذا كان العدد أقل)
        final shuffledSpaces = List.of(spacesWithUnits)..shuffle();
        final spacesToCache = shuffledSpaces.take(min(6, shuffledSpaces.length)).toList();

        // 3. استخراج الوحدات التابعة للمساحات التي تم اختيارها فقط
        final spaceIdsToCache = spacesToCache.map((s) => s.id).toSet();
        final allUnitsForSelectedSpaces = unitsProvider.units
            .where((u) => spaceIdsToCache.contains(u.spaceId))
            .toList();

        // 4. احفظ كل الوحدات التابعة للمساحات المختارة (وليس فقط 6 وحدات)
        final unitsToCache = allUnitsForSelectedSpaces;

        // 5. حفظ المساحات والوحدات المختارة في قاعدة البيانات المحلية
        print('Caching ${spacesToCache.length} random spaces (with units) and ${unitsToCache.length} units.');
        await LocalDatabase.saveSpaces(spacesToCache);
        await LocalDatabase.saveUnits(unitsToCache);
        // 6. حفظ البيانات العشوائية للواجهة الرئيسية
        await spacesProvider.saveRandomDataToLocal();
      }
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) async {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline && _wasOffline) {
        // رجع النت بعد انقطاع
        await spacesProvider.fetchSpacesAndUnits(isOnline: true, forceRefresh: true);
        await unitsProvider.fetchSpacesAndUnits(isOnline: true, forceRefresh: true);
        // يمكنك هنا عرض Snackbar أو رسالة للمستخدم إذا أردت
      }
      _wasOffline = !isOnline;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
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
          home:  mainHomePage(),
          routes: {
            mainHomePage.id: (context) =>  mainHomePage(),
            HomePage.id: (context) => const HomePage(),
            SpacesPage.id: (context) => const SpacesPage(),
            FavoritePage.id: (context) => const FavoritePage(),
            UnitsPage.id: (context) => const UnitsPage(),
            UnitDetailsPage.id: (context) => UnitDetailsPage(),
            SpaceDetailsPage.id: (context) => const SpaceDetailsPage(),
            InitiativePage.id: (context) => const InitiativePage(),
          },
        ),
      ),
    );
  }
}

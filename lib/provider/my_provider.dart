import 'package:flutter/material.dart';
import 'package:work_spaces/controler/spaces_controller.dart';
import 'package:work_spaces/model/space_model.dart';
import 'package:work_spaces/model/local_database.dart';
import 'package:work_spaces/model/space_units_model.dart' as su;
import 'package:latlong2/latlong.dart';
import 'dart:io';

class SpacesProvider extends ChangeNotifier {
  List<int> favoriteList = [];

  bool isFavorite(int index) => favoriteList.contains(index);

  void toggleFavorite(int index) {
    if (isFavorite(index)) {
      favoriteList.remove(index);
    } else {
      favoriteList.add(index);
    }
    notifyListeners();
  }

  List<Space> _spaces = [];
  bool _loading = false;
  String? _error;
  bool _isInitialized = false;

  // متغيرات موقع المستخدم
  LatLng? _userLocation;
  bool _isUserLocationSet = false;
  bool _isGettingLocation = false;

  // متغيرات للمساحات والوحدات العشوائية
  List<Space> _randomSpaces = [];
  List<su.SpaceUnit> _randomUnits = [];

  // متغيرات للمساحات والوحدات العشوائية للعرض في الرئيسية
  List<Space> _randomSpacesForHome = [];
  List<su.SpaceUnit> _randomUnitsForHome = [];

  List<Space> get spaces => _spaces;
  bool get loading => _loading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Getters لموقع المستخدم
  LatLng? get userLocation => _userLocation;
  bool get isUserLocationSet => _isUserLocationSet;
  bool get isGettingLocation => _isGettingLocation;

  // Getters للمساحات والوحدات العشوائية
  List<Space> get randomSpaces => _randomSpaces;
  List<su.SpaceUnit> get randomUnits => _randomUnits;

  // Getters للمساحات والوحدات العشوائية للعرض في الرئيسية
  List<Space> get randomSpacesForHome => _randomSpacesForHome;
  List<su.SpaceUnit> get randomUnitsForHome => _randomUnitsForHome;

  // دالة تعيين موقع المستخدم
  void setUserLocation(LatLng location) {
    _userLocation = location;
    _isUserLocationSet = true;
    notifyListeners();
  }

  // دالة مسح موقع المستخدم
  void clearUserLocation() {
    _userLocation = null;
    _isUserLocationSet = false;
    notifyListeners();
  }

  // دالة تعيين حالة جلب الموقع
  void setGettingLocation(bool isGetting) {
    _isGettingLocation = isGetting;
    notifyListeners();
  }

  // دالة فحص وجود إنترنت فعلي
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> fetchSpacesAndUnits({bool isOnline = true, bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) {
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (isOnline) {
        // تحقق من وجود إنترنت فعلي قبل جلب البيانات
        if (!await hasInternetConnection()) {
          _error = 'لا يوجد اتصال فعلي بالإنترنت';
          _spaces = await LocalDatabase.getSpaces();
          _loading = false;
          // تحميل البيانات العشوائية من قاعدة البيانات المحلية
          await loadRandomDataFromLocal();
          notifyListeners();
          return;
        }
        print('fetchSpacesAndUnits called');
        _spaces = await fetchSpaces();
        await saveSpacesToLocal(_spaces);
        print('Fetched spaces: \x1b[32m\x1b[32m\x1b[32m\x1b[32m${_spaces.length}\x1b[0m');
      } else {
        _spaces = await LocalDatabase.getSpaces();
        // تحميل البيانات العشوائية من قاعدة البيانات المحلية
        await loadRandomDataFromLocal();
      }
      _isInitialized = true;
    } catch (e) {
      // في حال حدوث أي خطأ، جلب من اللوكال
      try {
        _spaces = await LocalDatabase.getSpaces();
        // تحميل البيانات العشوائية من قاعدة البيانات المحلية
        await loadRandomDataFromLocal();
        _error = 'تم عرض بيانات قديمة لعدم توفر اتصال بالسيرفر أو الإنترنت';
      } catch (e2) {
        _error = 'حدث خطأ أثناء الاتصال بالسيرفر أو الإنترنت: ${e.toString()}';
      }
    }
    _loading = false;
    // تحديث البيانات العشوائية فقط إذا لم يتم تحميلها من اللوكال
    if (_randomSpaces.isEmpty) {
    updateRandomData();
    }
    updateRandomSpacesAndUnitsForHome();
    notifyListeners();
  }

  Future<void> loadSpacesFromLocal() async {
    final all = await LocalDatabase.getSpaces();
    _spaces = all.length > 6 ? all.sublist(0, 6) : all;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSpacesToLocal(List<Space> spaces) async {
    final toSave = spaces.length > 6 ? spaces.sublist(0, 6) : spaces;
    await LocalDatabase.saveSpaces(toSave);
  }

  void reset() {
    _spaces = [];
    _loading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }

  // دالة للحصول على 6 مساحات عشوائية
  List<Space> getRandomSpaces({int count = 6}) {
    if (_spaces.isEmpty) return [];
    final List<Space> shuffledSpaces = List.from(_spaces);
    shuffledSpaces.shuffle();
    return shuffledSpaces.take(count).toList();
  }

  // دالة للحصول على 6 وحدات عشوائية
  List<su.SpaceUnit> getRandomUnits({int count = 6}) {
    if (_spaces.isEmpty) return [];
    List<su.SpaceUnit> allUnits = [];
    for (final space in _spaces) {
      // تحويل SpaceUnit من space_model.dart إلى su.SpaceUnit
      for (final unit in space.spaceUnits) {
        allUnits.add(su.SpaceUnit(
          id: unit.id,
          name: unit.name,
          description: unit.description,
          imageUrl: unit.imageUrl,
          spaceId: unit.spaceId,
          unitCategoryId: unit.unitCategoryId,
          unitCategoryName: unit.unitCategoryName,
          bookingOptions: unit.bookingOptions.map((bo) => su.BookingOption(
            id: bo.id,
            duration: bo.duration,
            price: bo.price,
            currency: bo.currency,
            spaceUnitId: bo.spaceUnitId,
          )).toList(),
        ));
      }
    }
    if (allUnits.isEmpty) return [];
    allUnits.shuffle();
    return allUnits.take(count).toList();
  }

  // دالة للحصول على مساحات مميزة (ذات تقييم عالي)
  List<Space> getFeaturedSpaces({int count = 6}) {
    if (_spaces.isEmpty) return [];
    final List<Space> sortedSpaces = List.from(_spaces);
    sortedSpaces.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedSpaces.take(count).toList();
  }

  // دالة للحصول على مساحات جديدة (آخر المساحات المضافة)
  List<Space> getNewSpaces({int count = 6}) {
    if (_spaces.isEmpty) return [];
    final List<Space> sortedSpaces = List.from(_spaces);
    sortedSpaces.sort((a, b) => b.id.compareTo(a.id));
    return sortedSpaces.take(count).toList();
  }

  // دالة لتحديث المساحات والوحدات العشوائية
  void updateRandomData() {
    _randomSpaces = getRandomSpaces();
    _randomUnits = getRandomUnits();
    // حفظ البيانات العشوائية في قاعدة البيانات المحلية
    saveRandomDataToLocal();
    notifyListeners();
  }

  // حفظ البيانات العشوائية في قاعدة البيانات المحلية
  Future<void> saveRandomDataToLocal() async {
    try {
      await LocalDatabase.saveRandomSpaces(_randomSpaces);
      await LocalDatabase.saveRandomUnits(_randomUnits);
      print('تم حفظ البيانات العشوائية في قاعدة البيانات المحلية');
    } catch (e) {
      print('خطأ في حفظ البيانات العشوائية: $e');
    }
  }

  // تحميل البيانات العشوائية من قاعدة البيانات المحلية
  Future<void> loadRandomDataFromLocal() async {
    try {
      _randomSpaces = await LocalDatabase.getRandomSpaces();
      _randomUnits = await LocalDatabase.getRandomUnits();
      notifyListeners();
      print('تم تحميل البيانات العشوائية من قاعدة البيانات المحلية');
    } catch (e) {
      print('خطأ في تحميل البيانات العشوائية: $e');
    }
  }

  // دالة لإرجاع فقط 4 مساحات (للرئيسية في وضع offline)
  List<Space> getFourSpacesForHome() {
    if (_spaces.isEmpty) return [];
    return _spaces.length > 4 ? _spaces.sublist(0, 4) : _spaces;
  }

  // دالة لإرجاع الوحدات المرتبطة بالمساحات المحلية + من ضمن الـ6 وحدات المحفوظة بدون تكرار
  List<su.SpaceUnit> getUnitsForLocalSpacesAndRandomUnits(List<su.SpaceUnit> allUnits) {
    final localSpaceIds = _spaces.map((s) => s.id).toSet();
    final Set<int> addedUnitIds = {};
    List<su.SpaceUnit> result = [];
    // أضف الوحدات المرتبطة بالمساحات المحلية
    for (final unit in allUnits) {
      if (localSpaceIds.contains(unit.spaceId) && !addedUnitIds.contains(unit.id)) {
        result.add(unit);
        addedUnitIds.add(unit.id);
      }
    }
    // أضف الوحدات من الـ6 وحدات المحفوظة (randomUnits)
    for (final unit in _randomUnits) {
      if (!addedUnitIds.contains(unit.id)) {
        result.add(unit);
        addedUnitIds.add(unit.id);
      }
    }
    return result;
  }

  // دوال لتحديث العشوائية عند التحديث أو أول تحميل
  void updateRandomSpacesAndUnitsForHome() {
    final shuffledSpaces = List.of(_spaces)..shuffle();
    _randomSpacesForHome = shuffledSpaces.length > 4 ? shuffledSpaces.sublist(0, 4) : shuffledSpaces;
    final shuffledUnits = List.of(_randomUnits)..shuffle();
    _randomUnitsForHome = shuffledUnits.length > 4 ? shuffledUnits.sublist(0, 4) : shuffledUnits;
    notifyListeners();
  }

  // عند التحديث اليدوي (refresh)
  Future<void> refreshRandomSpacesAndUnitsForHome() async {
    updateRandomSpacesAndUnitsForHome();
  }
}

import 'package:flutter/material.dart';
import 'package:work_spaces/controler/spaces_controller.dart';
import 'package:work_spaces/model/space_model.dart';
import 'package:work_spaces/model/local_database.dart';
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

  List<Space> get spaces => _spaces;
  bool get loading => _loading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

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
          notifyListeners();
          return;
        }
        print('fetchSpacesAndUnits called');
        _spaces = await fetchSpaces();
        await saveSpacesToLocal(_spaces);
        print('Fetched spaces: \x1b[32m\x1b[32m\x1b[32m\x1b[32m${_spaces.length}\x1b[0m');
      } else {
        _spaces = await LocalDatabase.getSpaces();
      }
      _isInitialized = true;
    } catch (e) {
      // في حال حدوث أي خطأ، جلب من اللوكال
      try {
        _spaces = await LocalDatabase.getSpaces();
        _error = 'تم عرض بيانات قديمة لعدم توفر اتصال بالسيرفر أو الإنترنت';
      } catch (e2) {
        _error = 'حدث خطأ أثناء الاتصال بالسيرفر أو الإنترنت: ${e.toString()}';
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadSpacesFromLocal() async {
    _spaces = await LocalDatabase.getSpaces();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSpacesToLocal(List<Space> spaces) async {
    await LocalDatabase.saveSpaces(spaces);
  }

  void reset() {
    _spaces = [];
    _loading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }
}

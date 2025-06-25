import 'package:flutter/material.dart';
import 'package:work_spaces/controler/space_unit_controller.dart';
import 'package:work_spaces/model/space_units_model.dart';
import 'package:work_spaces/model/local_database.dart';
import 'dart:io';

class SpaceUnitsProvider extends ChangeNotifier {
  List<SpaceUnit> _units = [];
  bool _loading = false;
  String? _error;
  bool _isInitialized = false;

  List<SpaceUnit> get units => _units;
  bool get loading => _loading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

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
        if (!await hasInternetConnection()) {
          _error = 'لا يوجد اتصال فعلي بالإنترنت';
          _units = await LocalDatabase.getUnits();
          _loading = false;
          notifyListeners();
          return;
        }
        print('fetchAndUnits called');
        _units = await SpaceUnitController().fetchSpaceUnits();
        await saveUnitsToLocal(_units);
        print('Fetched units: \\${_units.length}');
      } else {
        _units = await LocalDatabase.getUnits();
      }
      _isInitialized = true;
    } catch (e) {
      // في حال حدوث أي خطأ، جلب من اللوكال
      try {
        _units = await LocalDatabase.getUnits();
        _error = 'تم عرض بيانات قديمة لعدم توفر اتصال بالسيرفر أو الإنترنت';
      } catch (e2) {
        _error = 'حدث خطأ أثناء الاتصال بالسيرفر أو الإنترنت: ${e.toString()}';
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadUnitsFromLocal() async {
    _units = await LocalDatabase.getUnits();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveUnitsToLocal(List<SpaceUnit> units) async {
    await LocalDatabase.saveUnits(units);
  }

  void setUnits(List<SpaceUnit> units) {
    _units = units;
    notifyListeners();
  }

  void clearUnits() {
    _units = [];
    notifyListeners();
  }

  void reset() {
    _units = [];
    _loading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }
}

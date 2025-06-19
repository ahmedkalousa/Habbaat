import 'dart:math';
import 'package:flutter/material.dart';
import 'package:work_spaces/controler/space_unit_controller.dart';
import 'package:work_spaces/model/space_units_model.dart';
import 'package:work_spaces/model/local_database.dart';

class SpaceUnitsProvider extends ChangeNotifier {
  List<SpaceUnit> _units = [];
  bool _loading = false;
  String? _error;
  bool _isInitialized = false;

  List<SpaceUnit> get units => _units;
  bool get loading => _loading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> fetchSpacesAndUnits({bool isOnline = true, bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) {
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (isOnline) {
        print('fetchAndUnits called');
        _units = await SpaceUnitController().fetchSpaceUnits();
        print('Fetched units: \\${_units.length}');
        // لا تخزن عشوائي ولا تحفظ محلياً عند وجود نت
      } else {
        _units = await LocalDatabase.getUnits();
      }
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
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

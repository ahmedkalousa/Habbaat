import 'package:flutter/material.dart';
import 'package:work_spaces/controler/spaces_controller.dart';
import 'package:work_spaces/model/space_model.dart';
import 'package:work_spaces/model/local_database.dart';

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

  Future<void> fetchSpacesAndUnits({bool isOnline = true, bool forceRefresh = false}) async {
    if (_isInitialized && !forceRefresh) {
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (isOnline) {
        print('fetchSpacesAndUnits called');
        _spaces = await fetchSpaces();
        print('Fetched spaces: \x1b[32m[32m[32m${_spaces.length}\x1b[0m');
        // لا تخزن عشوائي ولا تحفظ محلياً عند وجود نت
      } else {
        // جلب من اللوكال
        _spaces = await LocalDatabase.getSpaces();
      }
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
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

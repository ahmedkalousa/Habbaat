import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_spaces/model/space_units_model.dart';
import 'package:work_spaces/util/constant.dart';

class SpaceUnitController {
  Future<List<SpaceUnit>> fetchSpaceUnits() async {
    final response = await http.get(Uri.parse(spaceUnitUrl));
    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/json')) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => SpaceUnit.fromJson(e)).toList();
      } else {
        throw Exception('تم استلام استجابة غير متوقعة من الخادم (ليست JSON).');
      }
    } else {
      throw Exception('فشل في جلب بيانات الوحدات. رمز الحالة: ${response.statusCode}');
    }
  }
}

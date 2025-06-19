import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:work_spaces/model/space_model.dart';
import 'package:work_spaces/util/constant.dart';

Future<List<Space>> fetchSpaces() async {
  final response = await http.get(Uri.parse(spaceUrl));

  if (response.statusCode == 200) {
    final contentType = response.headers['content-type'];
    if (contentType != null && contentType.contains('application/json')) {
      final List<dynamic> data = json.decode(response.body);
      var result = data.map((json) => Space.fromJson(json)).toList();
      return result;
    } else {
      throw Exception('تم استلام استجابة غير متوقعة من الخادم (ليست JSON).');
    }
  } else {
    throw Exception('فشل في جلب المساحات. رمز الحالة: ${response.statusCode}');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inventerization_4aas/constants/app_constants.dart';
import 'package:inventerization_4aas/models/update_info_model.dart';

class UpdateRepository {
  Future<UpdateInfo?> fetchLatestVersion(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseAPIUrl}updateAppVersion/get_version.php?platform=$platform'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return UpdateInfo.fromJson(json['data']);
        }
      }
    } catch (e) {

    }
    return null;
  }
}
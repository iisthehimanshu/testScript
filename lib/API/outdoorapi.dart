import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/landmark.dart';
import '../APIMODELS/outdoormodel.dart';
import '../SharedPreferenceHelper.dart';
import 'guestloginapi.dart';


class outBuilding {
  static const String baseUrl = "https://dev.iwayplus.in/secured/outdoor";

  static Future<outdoormodel?> outbuilding(List<String> ids) async {
    SharedPreferenceHelper prefs = await SharedPreferenceHelper.getInstance();

    final Map<String, dynamic> data = {
      "buildingIds": ids
    };
    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': await prefs.getMap("signin")!["accessToken"]
      },
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print("outdoor api data $responseBody");
      return outdoormodel.fromJson(responseBody);
    }
  }
}
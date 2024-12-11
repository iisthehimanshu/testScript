import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/landmark.dart';
import '../SharedPreferenceHelper.dart';
import 'guestloginapi.dart';


class landmarkApi {
  static const String baseUrl = "https://dev.iwayplus.in/secured/landmarks";

  static Future<land?> fetchLandmarkData(String id) async {
    SharedPreferenceHelper prefs = await SharedPreferenceHelper.getInstance();

    final Map<String, dynamic> data = {
      "id": id
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
      return land.fromJson(responseBody);
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/waypoint.dart';
import 'guestloginapi.dart';


class waypointapi {

  static const String baseUrl = "https://dev.iwayplus.in/secured/indoor-path-network";
  static Future<List<PathModel>?> fetchwaypoint(String id) async {
    final Map<String, dynamic> data = {
      "building_ID": id
    };
    final response = await http.post(
      Uri.parse(baseUrl), body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': await guestApi.guestlogin().then((value){
          return value.accessToken!;
        })
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => PathModel.fromJson(data as Map<String, dynamic>)).toList();
    }
  }
}

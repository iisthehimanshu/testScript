import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIMODELS/Building.dart';
import '../SharedPreferenceHelper.dart';
import 'guestloginapi.dart';


class buildingapi {
  final String baseUrl = "https://dev.iwayplus.in/secured/building/all";

  Future<List<buildingAll>?> fetchbuildings() async {
    SharedPreferenceHelper prefs = await SharedPreferenceHelper.getInstance();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-access-token': await prefs.getMap("signin")!["accessToken"]
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      List<buildingAll> buildingList = responseBody
          .where((data) => data['initialBuildingName'] != null)
          .map((data) => buildingAll.fromJson(data))
          .toList();
      return buildingList;
    }else if (response.statusCode == 403){
      prefs.clearAll();
    }
  }
}
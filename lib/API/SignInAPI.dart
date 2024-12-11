import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../APIMODELS/SignInAPIModel.dart';
import '../SharedPreferenceHelper.dart';


class SignInAPI{

  final String baseUrl = "https://dev.iwayplus.in/auth/signin2";

  Future<SignInApiModel?> signIN(String username, String password) async {

    SharedPreferenceHelper prefs = await SharedPreferenceHelper.getInstance();

    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "appId":"com.iwayplus.testScript"
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseBody = json.decode(response.body);
        SignInApiModel ss = new SignInApiModel();
        ss.accessToken = responseBody["accessToken"];
        ss.refreshToken = responseBody["refreshToken"];
        ss.payload?.userId = responseBody["payload"]["userId"];
        ss.payload?.roles = responseBody["payload"]["roles"];
        await prefs.saveMap("signin", responseBody);
        return ss;
      } catch (e) {
        throw Exception('Failed to parse data');
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:async';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    // only return token (function), only return this token, when
    // token not expired or has token existed
    return token != null;
  }

  String get token {
    if(_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {

    final url = "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyALelmSQp5TOQOpB8gatCE4SmKJWClpUBQ";

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      
      final responseData = json.decode(response.body);
      if(responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
            seconds: int.parse(
                responseData["expiresIn"]
            )
        ),
      );
      _autoLogout();
      notifyListeners();

      // return a tunnel to the your device storage
      final preferences = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String()
      });

      // store the data
      preferences.setString("userConfig", userData);

    } catch (error) {
      throw error;
    }
  }

  Future<void> signup (String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }


  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // if no such data on the device's storage, stop auto login
    if (!prefs.containsKey("userConfig")) {
      return false;
    }

    final getUserData = json.decode(prefs.getString("userConfig")) as Map<String, Object>;
    final expiryDate = DateTime.parse(getUserData["expiryDate"]);

    // get the data but the token is expired, stop auto login
    if(expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    // retrieve data from the variable
    _token = getUserData['token'];
    _userId = getUserData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    if(_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    // clear all the data on the configuration
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if(_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
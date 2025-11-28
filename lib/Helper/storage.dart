import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Storage._();

  static final Storage instance = Storage._();
  late SharedPreferences sharedpreferences;

  Future<void> initializeStorage() async {
    sharedpreferences = await SharedPreferences.getInstance();
  }

  Future<void> setUser(String token) async {
    debugPrint('set token ${token}');
    await sharedpreferences.setString("token", token);
    await sharedpreferences.setBool("isLoggedIn", true);
  }

  get isLoggedIn => sharedpreferences.getBool("isLoggedIn") ?? false;

  get token => sharedpreferences.getString("token") ?? "";

  // Get user ID for Apple IAP - this can be used to track purchases per user
  get userId => sharedpreferences.getString("userId") ?? token;

  // Store user ID when available
  Future<void> setUserId(String id) async {
    await sharedpreferences.setString("userId", id);
  }

  Future<void> logout() async {
    await sharedpreferences.clear();
  }
}

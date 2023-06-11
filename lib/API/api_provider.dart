import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Models/generic_response.dart';
import '../Models/genres.dart';
import '../Models/languages.dart';
import '../Models/types.dart';

class ApiProvider {
  ApiProvider._();

  static final ApiProvider instance = ApiProvider._();

  final String baseUrl = "http://test.niri9.com/";

  final String path = "api";

  Dio? dio;

  Future<GenresResponse> getGenres() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/genres";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getGenres response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenresResponse.fromJson(response?.data);
      } else {
        debugPrint("getGenres error response: ${response?.data}");
        return GenresResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getGenres  error: ${e.error} ${e.message}");
      return GenresResponse.withError(e.message);
    }
  }
  Future<TypesResponse> getTypes() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/types";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("TypesResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return TypesResponse.fromJson(response?.data);
      } else {
        debugPrint("TypesResponse error response: ${response?.data}");
        return TypesResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("TypesResponse  error: ${e.error} ${e.message}");
      return TypesResponse.withError(e.message);
    }
  }

  Future<LanguageResponse> getLanguages() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/languages";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getLanguages response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return LanguageResponse.fromJson(response?.data);
      } else {
        debugPrint("getLanguages error response: ${response?.data}");
        return LanguageResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getLanguages  error: ${e.error} ${e.message}");
      return LanguageResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getAbout() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/about";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getLanguages response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("getLanguages error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getLanguages  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getPrivacyPolicy() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/privacy";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getPrivacyPolicy response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("getPrivacyPolicy error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getPrivacyPolicy  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getRefundPolicy() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/refund_policy";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getRefundPolicy response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("getRefundPolicy error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getRefundPolicy  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getTermsPolicy() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/terms";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getTermsPolicy response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("getTermsPolicy error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getTermsPolicy  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }




}

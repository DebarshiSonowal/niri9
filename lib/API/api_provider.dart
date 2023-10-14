import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/user.dart';

import '../Helper/storage.dart';
import '../Models/category.dart';
import '../Models/episode.dart';
import '../Models/generic_response.dart';
import '../Models/genres.dart';
import '../Models/languages.dart';
import '../Models/login.dart';
import '../Models/payment_gateway.dart';
import '../Models/sections.dart';
import '../Models/settings.dart';
import '../Models/social.dart';
import '../Models/subscription.dart';
import '../Models/types.dart';
import '../Models/video.dart';

class ApiProvider {
  ApiProvider._();

  static final ApiProvider instance = ApiProvider._();

  final String baseUrl = "http://test.niri9.com";

  final String path = "api";

  Dio? dio;

  Future<LoginResponse> login(
      String provider,
      String country_code,
      String mobile,
      String f_name,
      String l_name,
      String email,
      String profile_pic,
      String social_id,
      String device_token) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/users/login";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "provider": provider,
    };
    if (country_code != "") {
      data.addAll({
        "country_code": country_code,
      });
    }
    if (mobile != "") {
      data.addAll({
        "mobile": mobile,
      });
    }
    if (f_name != "") {
      data.addAll({
        "f_name": f_name,
      });
    }
    if (l_name != "") {
      data.addAll({
        "l_name": l_name,
      });
    }
    if (email != "") {
      data.addAll({
        "email": email,
      });
    }
    if (profile_pic != "") {
      data.addAll({
        "profile_pic": profile_pic,
      });
    }
    if (social_id != "") {
      data.addAll({
        "social_id": social_id,
      });
    }
    if (device_token != "") {
      data.addAll({
        "device_token": device_token,
      });
    }
    debugPrint(jsonEncode(data));
    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint("login response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return LoginResponse.fromJson(response?.data);
      } else {
        debugPrint("login error response: ${response?.data}");
        return LoginResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("login error: ${e.error} ${e.message}");
      return LoginResponse.withError(e.message);
    }
  }

  Future<GenresResponse> getGenres() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/genres";
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

  Future<PaymentGatewayResponse> getPaymentGateway() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/genres";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getPaymentGatewayResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return PaymentGatewayResponse.fromJson(response?.data);
      } else {
        debugPrint(
            "getPaymentGatewayResponse error response: ${response?.data}");
        return PaymentGatewayResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getPaymentGatewayResponse  error: ${e.error} ${e.message}");
      return PaymentGatewayResponse.withError(e.message);
    }
  }

  Future<ProfileResponse> getProfile() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/users/profile";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    debugPrint('Bearer ${Storage.instance.token}');

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("getProfile response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return ProfileResponse.fromJson(response?.data);
      } else {
        debugPrint("getProfile error response: ${response?.data}");
        return ProfileResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getPRofile  error: ${e.error} ${e.message}");
      return ProfileResponse.withError(e.message);
    }
  }

  Future<GenresResponse> updateVideoTime(
    video_list_id,
    view_duration,
    unique_id,
    last_play_time,
    platform,
    event_name,
  ) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(
          seconds: Constants.waitTime,
        ),
        receiveTimeout: const Duration(
          seconds: Constants.waitTime,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/update-view-time";
    // var url = "http://asamis.assam.gov.in/api/login";
    debugPrint("${Storage.instance.token}");
    dio = Dio(option);
    debugPrint(url.toString());

    var data = {
      "video_list_id": video_list_id,
      "view_duration": view_duration,
      'unique_id': unique_id,
      'last_play_time': last_play_time,
      'platform': platform,
      'event_name': event_name,
    };
    debugPrint(jsonEncode(data));
    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
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

  Future<CategoryResponse> getCategories() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/categories";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "CategoryResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return CategoryResponse.fromJson(response?.data);
      } else {
        debugPrint("CategoryResponse error response: ${response?.data}");
        return CategoryResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("CategoryResponse  error: ${e.error} ${e.message}");
      return CategoryResponse.withError(e.message);
    }
  }

  Future<VideoResponse> getVideos(
      int page_no, Sections? section, Category? category, Genres? genre) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    Map<String, dynamic> data = {
      'page_no': page_no,
    };
    if (section != null) {
      data.addAll({
        'section': section.slug ?? "",
      });
    }
    if (category != null) {
      data.addAll({
        'category': category.slug ?? "",
      });
    }
    if (genre != null) {
      data.addAll({
        'genre': genre.slug ?? "",
      });
    }
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "VideoResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("VideoResponse error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("VideoResponse  error: ${e.error} ${e.message}");
      return VideoResponse.withError(e.message);
    }
  }

  Future<VideoResponse> getRental() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/rent-list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "VideoRentalResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("VideoRentalResponse error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("VideoRentalResponse  error: ${e.error} ${e.message}");
      return VideoResponse.withError(e.message);
    }
  }

  Future<VideoResponse> getMyVideos() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/my-list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // var data = {
    //   'page_no': page_no,
    //   'section': section,
    //   'category': category,
    //   'genre': genre,
    // };
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getMyVideos response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("getMyVideos error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getMyVideos  error: ${e.error} ${e.message}");
      return VideoResponse.withError(e.message);
    }
  }

  Future<VideoResponse> getRentVideos() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/rent-list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // var data = {
    //   'page_no': page_no,
    //   'section': section,
    //   'category': category,
    //   'genre': genre,
    // };
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getMyVideos response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("getMyVideos error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getMyVideos  error: ${e.error} ${e.message}");
      return VideoResponse.withError(e.message);
    }
  }

  Future<VideoDetails> getVideoDetails(id) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/$id";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "VideoDetails response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoDetails.fromJson(response?.data);
      } else {
        debugPrint("VideoDetails error response: ${response?.data}");
        return VideoDetails.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("VideoDetails  error: ${e.error} ${e.message}");
      return VideoDetails.withError(e.message);
    }
  }

  Future<TypesResponse> getTypes() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
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
      debugPrint(
          "TypesResponse response: ${response?.data} ${response?.headers}");
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

  Future<SubscriptionResponse> getSubscriptions() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/subscriptions/list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "TypesResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return SubscriptionResponse.fromJson(response?.data);
      } else {
        debugPrint("TypesResponse error response: ${response?.data}");
        return SubscriptionResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("TypesResponse  error: ${e.error} ${e.message}");
      return SubscriptionResponse.withError(e.message);
    }
  }

  Future<LanguageResponse> getLanguages() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
      debugPrint(
          "getLanguages response: ${response?.data} ${response?.headers}");
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

  Future<SettingsResponse> getSettings() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/setting/app";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "SettingsResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return SettingsResponse.fromJson(response?.data);
      } else {
        debugPrint("SettingsResponse error response: ${response?.data}");
        return SettingsResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("SettingsResponse error: ${e.error} ${e.message}");
      return SettingsResponse.withError(e.message);
    }
  }

  Future<SocialResponse> getSocial() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/setting/app/social";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "SettingsResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return SocialResponse.fromJson(response?.data);
      } else {
        debugPrint("SettingsResponse error response: ${response?.data}");
        return SocialResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("SettingsResponse error: ${e.error} ${e.message}");
      return SocialResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getAbout() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
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
      debugPrint(
          "getLanguages response: ${response?.data} ${response?.headers}");
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
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
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
      debugPrint(
          "getPrivacyPolicy response: ${response?.data} ${response?.headers}");
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
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/refund-policy";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getRefundPolicy response: ${response?.data} ${response?.headers}");
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
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/terms-and-condition";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getTermsPolicy response: ${response?.data} ${response?.headers}");
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

  Future<GenericResponse> getHelpCenter() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/help-center";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "help-center response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("help-center error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("help-center  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getFAQ() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/faq";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("faq response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("faq error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("faq  error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<GenericResponse> getContact() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/legal-pages/contact-us";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint("contact-us response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("contact-us error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("contact-us error: ${e.error} ${e.message}");
      return GenericResponse.withError(e.message);
    }
  }

  Future<SectionsResponse> getSections() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/widgets/sections";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "getSections response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return SectionsResponse.fromJson(response?.data);
      } else {
        debugPrint("getSections error response: ${response?.data}");
        return SectionsResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getSections  error: ${e.error} ${e.message}");
      return SectionsResponse.withError(e.message);
    }
  }

  Future<EpisodeResponse> getEpisodes(int videoListId) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/episodes/$videoListId";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "EpisodeResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return EpisodeResponse.fromJson(response?.data);
      } else {
        debugPrint("EpisodeResponse error response: ${response?.data}");
        return EpisodeResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("EpisodeResponse  error: ${e.error} ${e.message}");
      return EpisodeResponse.withError(e.message);
    }
  }
}

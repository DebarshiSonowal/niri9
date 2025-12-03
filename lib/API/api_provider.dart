import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/VideoResolution.dart';
import 'package:niri9/Models/order_history.dart';
import 'package:niri9/Models/user.dart';

import '../Helper/storage.dart';
import '../Models/banner.dart';
import '../Models/category.dart';
import '../Models/episode.dart';
import '../Models/film_festival.dart';
import '../Models/generic_response.dart';
import '../Models/genres.dart';
import '../Models/initiate_order_response.dart';
import '../Models/languages.dart';
import '../Models/login.dart';
import '../Models/order_history_details.dart';
import '../Models/payment_gateway.dart';
import '../Models/rent_plan_details_response.dart';
import '../Models/sections.dart';
import '../Models/series_episode_details.dart';
import '../Models/settings.dart';
import '../Models/social.dart';
import '../Models/subscription.dart';
import '../Models/types.dart';
import '../Models/video.dart';

class ApiProvider {
  ApiProvider._();

  static final ApiProvider instance = ApiProvider._();

  final String baseUrl = "https://niri9.com";
  final String path = "api";

  // Cached dio instance with optimizations
  static Dio? _cachedDio;
  static final CacheOptions _cacheOptions = CacheOptions(
    store: MemCacheStore(maxSize: 10 * 1024 * 1024),
    // 10MB cache
    policy: CachePolicy.request,
    // hitCacheOnErrorExcept: [401, 403, 500, 502, 503],
    maxStale: const Duration(minutes: 30),
    priority: CachePriority.high,
  );

  Dio? dio;

  // Get optimized dio instance
  Dio _getDio({bool useCache = false}) {
    if (_cachedDio == null) {
      BaseOptions options = BaseOptions(
        connectTimeout: const Duration(seconds: 15), // Reduced from 30
        receiveTimeout: const Duration(seconds: 20), // Reduced from 30
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      _cachedDio = Dio(options);

      // Add cache interceptor for static data
      if (useCache) {
        _cachedDio!.interceptors
            .add(DioCacheInterceptor(options: _cacheOptions));
      }

      // Add connection pooling
      (_cachedDio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          () {
        final client = HttpClient();
        client.maxConnectionsPerHost = 10;
        client.connectionTimeout = const Duration(seconds: 15);
        return client;
      };
    }
    return _cachedDio!;
  }

  Future<LoginResponse> login(
    String provider,
    String country_code,
    String mobile,
    String f_name,
    String l_name,
    String email,
    String profile_pic,
    String social_id,
    String device_token,
    String? otp,
  ) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 15), // Reduced
        receiveTimeout: const Duration(seconds: 20), // Reduced
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
    var url = "$baseUrl/$path/users/login";
    dio = Dio(option);

    // Build data more efficiently
    Map<String, dynamic> data = {"provider": provider};
    if (country_code.isNotEmpty) data["country_code"] = country_code;
    if (mobile.isNotEmpty) data["mobile"] = mobile;
    if (otp?.isNotEmpty == true) data["otp"] = otp!;
    if (f_name.isNotEmpty) data["f_name"] = f_name;
    if (l_name.isNotEmpty) data["l_name"] = l_name;
    if (email.isNotEmpty) data["email"] = email;
    if (profile_pic.isNotEmpty) data["profile_pic"] = profile_pic;
    if (social_id.isNotEmpty) data["social_id"] = social_id;
    if (device_token.isNotEmpty) data["device_token"] = device_token;

    try {
      Response? response = await dio?.post(url, data: data);
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return LoginResponse.fromJson(response?.data);
      } else {
        return LoginResponse.withError(
            response?.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      return LoginResponse.withError(
          e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<GenericOTPResponse> generateOTP(String mobile) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
    var url = "$baseUrl/$path/users/generate-otp";
    dio = Dio(option);
    var data = {"mobile": mobile};

    try {
      Response? response = await dio?.post(url, data: data);
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericOTPResponse.fromJson(response?.data);
      } else {
        return GenericOTPResponse.withError(
            response?.data['message'] ?? 'OTP generation failed');
      }
    } on DioException catch (e) {
      return GenericOTPResponse.withError(
          e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<FilmFestivalResponse> getFestival(int id) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/festival";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "mobile": id,
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "getFestival response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return FilmFestivalResponse.fromJson(response?.data);
      } else {
        debugPrint("getFestival error response: ${response?.data}");
        return FilmFestivalResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getFestival  error: ${e.error} ${e.message}");
      return FilmFestivalResponse.withError(e.message);
    }
  }

  Future<GenresResponse> getGenres() async {
    final dio = _getDio();
    var url = "/$path/videos/genres";

    try {
      final response = await dio.get(
        url,
        options: _cacheOptions.toOptions(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GenresResponse.fromJson(response.data);
      } else {
        return GenresResponse.withError(
            response.data['message'] ?? 'Failed to fetch genres');
      }
    } on DioException catch (e) {
      return GenresResponse.withError(
          e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<InitiateOrderResponse> initiateOrder(id, videoId, int type) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/sales/order";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "id": id,
      "video_id": videoId,
      "order_type": type == 0 ? 'subscription' : 'rent',
      "currency": 'INR'
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "initiateOrder response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return InitiateOrderResponse.fromJson(response?.data);
      } else {
        debugPrint("initiateOrder error response: ${response?.data}");
        return InitiateOrderResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("initiateOrder  error: ${e.error} ${e.response} ${e.message}");
      return InitiateOrderResponse.withError(e.response?.data['message']);
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

  Future<GenericResponse> deleteAccount() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
        });
    var url = "$baseUrl/$path/users/profile/delete";
    dio = Dio(option);
    debugPrint(url.toString());
    debugPrint('Bearer ${Storage.instance.token}');

    try {
      Response? response = await dio?.post(url);
      debugPrint("deleteAccount response: ${response?.data}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("deleteAccount error response: ${response?.data}");
        return GenericResponse.withError(
            response?.data['message'] ?? 'Failed to delete account');
      }
    } on DioException catch (e) {
      debugPrint("deleteAccount error: ${e.error} ${e.message}");
      return GenericResponse.withError(
          e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<GenericResponse> updateVideoTime(
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
      debugPrint(
          "updateViewDuration response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("updateViewDuration error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint(
          "updateViewDuration error: ${e.error} ${e.response?.data} ${e.message}");
      return GenericResponse.withError(e.response?.data['message']);
    }
  }

  Future<CategoryResponse> getCategories() async {
    // Create a dio instance with longer timeouts for this specific request
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    final dio = Dio(options);

    var url = "/$path/videos/categories";

    debugPrint("ApiProvider: Fetching categories from: $baseUrl$url");

    try {
      final response = await dio.get(url);

      debugPrint(
          "ApiProvider: Categories response status: ${response.statusCode}");
      debugPrint("ApiProvider: Categories response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final categoryResponse = CategoryResponse.fromJson(response.data);
        debugPrint(
            "ApiProvider: Categories parsed - success: ${categoryResponse.success}");
        debugPrint(
            "ApiProvider: Categories count: ${categoryResponse.categories.length}");

        for (int i = 0; i < categoryResponse.categories.length; i++) {
          final category = categoryResponse.categories[i];
          debugPrint(
              "ApiProvider: Category $i - name: '${category.name}', slug: '${category.slug}'");
        }

        return categoryResponse;
      } else {
        debugPrint("ApiProvider: Categories error response: ${response.data}");
        return CategoryResponse.withError(
            response.data['message'] ?? 'Failed to fetch categories');
      }
    } on DioException catch (e) {
      debugPrint(
          "ApiProvider: Categories DioException: ${e.message}, type: ${e.type}");

      String errorMessage = 'Network error';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Bad response: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error - check internet connection';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error: ${e.message}';
          break;
        default:
          errorMessage = e.message ?? 'Network error';
      }

      return CategoryResponse.withError(errorMessage);
    } catch (e) {
      debugPrint("ApiProvider: Categories unexpected error: $e");
      return CategoryResponse.withError('Unexpected error: $e');
    }
  }

  Future<VideoResponse> getVideos(
      int page_no,
      String? language,
      String? category,
      String? genre,
      String? search,
      String? page,
      String? type) async {
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
    dio = Dio(option);

    final queryParams = <String, dynamic>{'page_no': page_no};
    if (language?.isNotEmpty == true) queryParams['language'] = language;
    if (search?.isNotEmpty == true) queryParams['search'] = search;
    if (page?.isNotEmpty == true) queryParams['page_for'] = page;
    if (category?.isNotEmpty == true) queryParams['category'] = category;
    if (genre?.isNotEmpty == true) queryParams['genre'] = genre;
    if (type?.isNotEmpty == true) queryParams['type'] = type;

    debugPrint("getVideos request: $url");
    debugPrint("getVideos queryParams: $queryParams");

    try {
      final response = await dio?.get(
        url,
        queryParameters: queryParams,
      );

      debugPrint("getVideos response status: ${response?.statusCode}");
      debugPrint(
          "getVideos response data keys: ${(response?.data as Map?)?.keys}");

      if (response?.data['result'] != null) {
        debugPrint(
            "getVideos result keys: ${(response?.data['result'] as Map?)?.keys}");
        if (response?.data['result']['data'] != null) {
          debugPrint(
              "getVideos data length: ${(response?.data['result']['data'] as List?)?.length}");
        } else {
          debugPrint("getVideos: result.data is null");
        }
      } else {
        debugPrint("getVideos: result is null");
      }

      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        return VideoResponse.withError(
            response?.data['message'] ?? 'Failed to fetch videos');
      }
    } on DioException catch (e) {
      debugPrint("getVideos DioException: ${e.message}");
      return VideoResponse.withError(
          e.response?.data?['message'] ?? e.message ?? 'Network error');
    }
  }

  Future<VideoResponse> getRecentlyVideos(int page_no) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/recently-viewed-list";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      'page_no': page_no,
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // queryParameters: data,
        // data: jsonEncode(data),
      );
      debugPrint(
          "recently-viewed-list response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("recently-viewed-list error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("recently-viewed-list  error: ${e.error} ${e.message}");
      return VideoResponse.withError(e.message);
    }
  }

  Future<VideoResponse> search(String search) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/search";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    Map<String, dynamic> data = {
      'search': search,
    };

    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        queryParameters: data,
      );
      debugPrint(
          "SearchResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoResponse.fromJson(response?.data);
      } else {
        debugPrint("SearchResponse error response: ${response?.data}");
        return VideoResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("SearchResponse  error: ${e.error} ${e.message}");
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

  Future<OrderHistoryResponse> getOrderHistory() async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/sales/order";
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
        return OrderHistoryResponse.fromJson(response?.data);
      } else {
        debugPrint("VideoRentalResponse error response: ${response?.data}");
        return OrderHistoryResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("VideoRentalResponse  error: ${e.error} ${e.message}");
      return OrderHistoryResponse.withError(e.message);
    }
  }

  Future<OrderHistoryDetailsResponse> getOrderHistoryDetails(id) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/sales/order/$id";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "OrderHistoryDetailsResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return OrderHistoryDetailsResponse.fromJson(response?.data);
      } else {
        debugPrint(
            "OrderHistoryDetailsResponse error response: ${response?.data}");
        return OrderHistoryDetailsResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("OrderHistoryDetailsResponse error: ${e.error} ${e.message}");
      return OrderHistoryDetailsResponse.withError(e.message);
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
          "getMyVideos response: ${response?.data} \n${response?.statusCode}");
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

  Future<GenericResponse> addMyVideos(id) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/my-list/$id";
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
      Response? response = await dio?.post(
        url,
        // data: jsonEncode(data),
      );
      debugPrint(
          "addMyVideos response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("addMyVideos error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint(
          "addMyVideos  error: ${e.error} ${e.response?.data} ${e.message}");
      return GenericResponse.withError(e.response?.data['message']);
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
    debugPrint('Bearer ${Storage.instance.token}');

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

  Future<RentPlanDetailsResponse> getRentPlans(int id) async {
    print(Storage.instance.token);
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/rent/$id";
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
        return RentPlanDetailsResponse.fromJson(response?.data);
      } else {
        debugPrint("getMyVideos error response: ${response?.data}");
        return RentPlanDetailsResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getMyVideos  error: ${e.error} ${e.message}");
      return RentPlanDetailsResponse.withError(e.message);
    }
  }

  Future<VideoDetailsResponse> getVideoDetails(id) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/$id";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      'platform': 'phone',
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        // data: jsonEncode(data),
        queryParameters: data,
      );
      debugPrint(
          "VideoDetails response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return VideoDetailsResponse.fromJson(response?.data);
      } else {
        debugPrint("VideoDetails error response: ${response?.data}");
        return VideoDetailsResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("VideoDetails  error: ${e.error} ${e.message}");
      return VideoDetailsResponse.withError(e.message);
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

  Future<GenericResponse> verifyPayment(
      razorpay_payment_id, order_id, amount) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/sales/order/verify-payment";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "razorpay_payment_id": razorpay_payment_id,
      "amount": amount,
      "order_id": order_id,
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "verifyPayment response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("verifyPayment error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint(
          "verifyPayment error: ${e.error} ${e.response?.data} ${e.message}");
      return GenericResponse.withError(e.response?.data['message']);
    }
  }

  Future<GenericResponse> verifyApplePayment(String orderId, String productId,
      String amount, String receiptData, String transactionDate) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
        });
    var url = "$baseUrl/$path/sales/order/verify-apple-payment";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "product_id": productId,
      "amount": amount,
      "order_id": orderId,
      "receipt_data": receiptData,
      "transaction_date": transactionDate,
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "verifyApplePayment response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("verifyApplePayment error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint(
          "verifyApplePayment error: ${e.error} ${e.response?.data} ${e.message}");
      return GenericResponse.withError(
          e.response?.data['message'] ?? e.message);
    }
  }

  Future<GenericResponse> applyDiscount(
      int subscriptionId, String couponCode, String currency) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/discount/apply";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {
      "id": subscriptionId,
      "coupon_code": couponCode,
      "currency": currency,
    };
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "applyDiscount response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return GenericResponse.fromJson(response?.data);
      } else {
        debugPrint("applyDiscount error response: ${response?.data}");
        return GenericResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("applyDiscount error: ${e.error} ${e.message}");
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

  Future<ProfileResponse> updateProfile(
      String email, String fname, String lname) async {
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
    debugPrint("${email} ${fname} ${lname}");
    var data = {};
    if (email != "") {
      data.addAll({
        "email": email,
      });
    }
    if (fname != "") {
      data.addAll({
        "f_name": fname,
      });
    }
    if (lname != "") {
      data.addAll({
        "l_name": lname,
      });
    }
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.post(
        url,
        data: jsonEncode(data),
      );
      debugPrint(
          "updateProfile response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return ProfileResponse.fromJson(response?.data);
      } else {
        debugPrint("updateProfile error response: ${response?.data}");
        return ProfileResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("updateProfile  error: ${e.error} ${e.message}");
      return ProfileResponse.withError(
          e.response?.data['message'] ?? e.message);
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

  // Future<SectionsResponse> getLanguageSections(String page, String page_no, language_id) async {
  //   BaseOptions option = BaseOptions(
  //       connectTimeout: const Duration(seconds: Constants.waitTime),
  //       receiveTimeout: const Duration(seconds: Constants.waitTime),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         // 'Authorization': 'Bearer ${Storage.instance.token}'
  //         // 'APP-KEY': ConstanceData.app_key
  //       });
  //   var url = "$baseUrl/$path/widgets/sections";
  //   // var url = "http://asamis.assam.gov.in/api/login";
  //   dio = Dio(option);
  //   debugPrint(url.toString());
  //   var data = {
  //     'page': page,
  //   };
  //   data.addAll({
  //     'page_no': page_no ?? '1',
  //   });
  //   debugPrint(jsonEncode(data));
  //   // debugPrint(jsonEncode(data));
  //
  //   try {
  //     Response? response = await dio?.get(
  //       url,
  //       queryParameters: data,
  //     );
  //     debugPrint(
  //         "getSections response: ${response?.data} ${response?.headers}");
  //     if (response?.statusCode == 200 || response?.statusCode == 201) {
  //       return SectionsResponse.fromJson(response?.data);
  //     } else {
  //       debugPrint("getSections error response: ${response?.data}");
  //       return SectionsResponse.withError(response?.data['error']
  //           ? response?.data['message']['success']
  //           : response?.data['message']['error']);
  //     }
  //   } on DioError catch (e) {
  //     debugPrint("getSections  error: ${e.error} ${e.message}");
  //     return SectionsResponse.withError(e.message);
  //   }
  // }

  Future<SectionsResponse> getSections(
      String page, String page_no, language_id) async {
    // Create a dio instance with longer timeouts for this specific request
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    final dio = Dio(options);

    var url = "/$path/widgets/sections";

    final queryParams = <String, dynamic>{
      'page': page,
      'page_no': page_no,
    };
    if (language_id?.isNotEmpty == true) {
      queryParams['language_id'] = language_id;
    }

    debugPrint("getSections request: $baseUrl$url with params: $queryParams");

    try {
      final response = await dio.get(
        url,
        queryParameters: queryParams,
      );

      debugPrint("getSections response status: ${response.statusCode}");
      debugPrint("getSections response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final sectionsResponse = SectionsResponse.fromJson(response.data);
        debugPrint(
            "getSections parsed: status=${sectionsResponse.status}, sections count=${sectionsResponse.sections.length}");

        // Debug each section
        for (int i = 0; i < sectionsResponse.sections.length; i++) {
          final section = sectionsResponse.sections[i];
          debugPrint(
              "Section $i: title='${section.title}', videos count=${section.videos.length}");
        }

        return sectionsResponse;
      } else {
        debugPrint("getSections error response: ${response.data}");
        return SectionsResponse.withError(
            response.data['message'] ?? 'Failed to fetch sections');
      }
    } on DioException catch (e) {
      debugPrint(
          "getSections DioException: ${e.message}, type: ${e.type}, response: ${e.response?.data}");

      String errorMessage = 'Network error';
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Bad response: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error - check internet connection';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error: ${e.message}';
          break;
        default:
          errorMessage = e.message ?? 'Network error';
      }

      return SectionsResponse.withError(errorMessage);
    } catch (e) {
      debugPrint("getSections unexpected error: $e");
      return SectionsResponse.withError('Unexpected error: $e');
    }
  }

  Future<BannerResponse> getBannerResponse(String page) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/widgets/banner";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    debugPrint('Bearer ${Storage.instance.token}');
    var data = {
      'page': page,
    };
    debugPrint(jsonEncode(data));
    // debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        queryParameters: data,
      );
      debugPrint("get BannerResponse: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return BannerResponse.fromJson(response?.data);
      } else {
        debugPrint("getSections error response: ${response?.data}");
        return BannerResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("getSections  error: ${e.error} ${e.message}");
      return BannerResponse.withError(e.message);
    }
  }

  Future<EpisodeResponse> getEpisodeDetails(int videoListId) async {
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

  Future<EpisodeListResponse> getEpisodes(int videoListId) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    var url = "$baseUrl/$path/videos/episodes";
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    debugPrint(url.toString());
    var data = {"series_id": "$videoListId"};
    debugPrint(jsonEncode(data));

    try {
      Response? response = await dio?.get(
        url,
        queryParameters: data,
      );
      debugPrint(
          "EpisodeResponse response: ${response?.data} ${response?.headers}");
      if (response?.statusCode == 200 || response?.statusCode == 201) {
        return EpisodeListResponse.fromJson(response?.data);
      } else {
        debugPrint("EpisodeResponse error response: ${response?.data}");
        return EpisodeListResponse.withError(response?.data['error']
            ? response?.data['message']['success']
            : response?.data['message']['error']);
      }
    } on DioError catch (e) {
      debugPrint("EpisodeResponse  error: ${e.error} ${e.message}");
      return EpisodeListResponse.withError(e.message);
    }
  }

  Future<VideoResolutionModel> download2(String url) async {
    BaseOptions option = BaseOptions(
        connectTimeout: const Duration(seconds: Constants.waitTime),
        receiveTimeout: const Duration(seconds: Constants.waitTime),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer ${Storage.instance.token}'
          // 'APP-KEY': ConstanceData.app_key
        });
    // var url = "http://asamis.assam.gov.in/api/login";
    dio = Dio(option);
    try {
      Response? response = await dio?.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return (status ?? 0) < 500;
            }),
      );
      debugPrint("E123 ${response?.headers.toString()}");
      // File file = File(savePath);
      // var raf = file.openSync(mode: FileMode.write);
      // // response.data is List<int> type
      File file = File.fromRawPath(response?.data);
      // final ext = await file.readAsString();
      debugPrint("E123 ${file.path}");
      return VideoResolutionModel(true, extractURLandResolution(file.path));
    } catch (e) {
      print("E1234 $url $e");
      return VideoResolutionModel(false, []);
    }
  }

  List<VideoResolution> extractURLandResolution(String inputText) {
    RegExp regex = RegExp(
        r'RESOLUTION=([0-9]+x[0-9]+),.*\n([^#]+\.m3u8\?useMezzanine=true)');

    Iterable<Match> matches = regex.allMatches(inputText);
    List<VideoResolution> list = [];
    for (Match match in matches) {
      String resolution = match.group(1)!;
      String url = match.group(2)!;
      list.add(VideoResolution(
          resolution, url, int.parse(resolution.split("x")[1])));
      // print('Resolution: $resolution\nURL: $url\n');
    }
    // print("MYE!@# \n");
    list.sort((a, b) => a.resolution.compareTo(b.resolution));
    print("E123A $list");
    return list;
  }

  void showDownloadProgress(int count, int total) {}
}

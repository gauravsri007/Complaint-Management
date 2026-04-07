import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal() {
    _init();
  }

  late Dio dio;
  static const String _baseUrl =
      'https://dashboard.reachinternational.co.in/development/api';
  static const String _cookieKey = 'session_cookie';
  String? _sessionCookie;

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    dio = Dio(
      BaseOptions(

        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "*/*",
          "Connection": "keep-alive",
          "Accept-Encoding": "gzip, deflate, br",
          "User-Agent": "FlutterApp/1.0",
          "Authorization": "Bearer $token", // Add bearer token
        },
      ),
    );

    // Load cookie from storage
    _sessionCookie = prefs.getString(_cookieKey);
    if (_sessionCookie != null) {
      dio.options.headers['Cookie'] = _sessionCookie;
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ensure cookie is attached
          if (_sessionCookie != null &&
              (options.headers['Cookie'] == null ||
                  options.headers['Cookie'].toString().isEmpty)) {
            options.headers['Cookie'] = _sessionCookie;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Capture set-cookie from server
          final setCookieHeader = response.headers['set-cookie'];
          if (setCookieHeader != null && setCookieHeader.isNotEmpty) {
            final cookie = setCookieHeader.first;
            _sessionCookie = cookie;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cookieKey, cookie);

            dio.options.headers['Cookie'] = cookie;
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  /// Call this on logout
  Future<void> clearSession() async {
    _sessionCookie = null;
    dio.options.headers.remove('Cookie');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }
}

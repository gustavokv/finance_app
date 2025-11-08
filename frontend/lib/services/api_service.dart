import 'package:dio/dio.dart';

const String apiUrl = "http://172.0.0.1:8000";

class ApiService {
  // Private instance (Singleton pattern)
  static final ApiService _instance = ApiService._internal();

  // Public getter for instance
  static ApiService get instance => _instance;

  late final Dio _dio;

  ApiService._internal() {
    final BaseOptions options = BaseOptions(
      baseUrl: apiUrl,
      // Max timeout to connect to the server
      connectTimeout: const Duration(seconds: 10),
      // Max timeout to receive data from server
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      print('Error on GET request: $e');
      rethrow; // Re-sends the exception to be treated on UI
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      print('Error on POST request: $e');
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      print('Error on PUT request: $e');
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      print('Error on DELETE request: $e');
      rethrow;
    }
  }

  // Update authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

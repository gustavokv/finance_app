import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:finance_app/services/navigation_service.dart';

const String apiUrl = "http://localhost:3500";

class ApiService {
  // Private instance (Singleton pattern)
  static final ApiService _instance = ApiService._internal();

  // Public getter for instance
  static ApiService get instance => _instance;

  late final Dio _dio;
  bool _initialized = false;
  late CookieJar cookieJar;

  // Construtor síncrono (Configura o básico do Dio)
  ApiService._internal() {
    final BaseOptions options = BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json'},
    );

    _dio = Dio(options);

    _setupInterceptors();

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

  Future<void> initialize() async {
    if (_initialized) return;

    // Previne concorrência se chamado múltiplas vezes rapidamente
    _initialized = true;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      cookieJar = PersistCookieJar(
        storage: FileStorage("$appDocPath/.cookies/"),
        ignoreExpires: true,
        persistSession: true,
      );

      _dio.interceptors.add(CookieManager(cookieJar));
    } catch (e) {
      print("Erro ao inicializar cookies: $e");
      _initialized = false; // Permite tentar de novo se falhar
    }
  }

  // --- Métodos HTTP ---

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await initialize();
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      print('Error on GET request: $e');
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    await initialize();
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
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
    await initialize();
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
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
    await initialize();
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      print('Error on DELETE request: $e');
      rethrow;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['authorization'] = token;
  }

  void clearAuthToken() {
    _dio.options.headers.remove('authorization');
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              final response = await Dio(
                BaseOptions(baseUrl: apiUrl),
              ).post('/auth/access-token');

              final message = response.data?['message'];
              if (message == "invalid token" || message == "jwt expired") {
                _handleLogout();
                return handler.reject(e);
              }

              if (response.statusCode == 200) {
                final newToken = response.data['token'];
                setAuthToken(newToken);

                // Refaz a requisição original
                e.requestOptions.headers['authorization'] = newToken;
                final retryResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              _handleLogout();
              return handler.reject(e);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Função auxiliar para centralizar o logout
  void _handleLogout() async {
    clearAuthToken();
    // Limpa cookies de sessão
    await cookieJar.deleteAll();

    // O GoRouter precisa de um pequeno delay para garantir que o Navigator está pronto
    Future.microtask(() {
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        context.go('/');
      }
    });
  }
}

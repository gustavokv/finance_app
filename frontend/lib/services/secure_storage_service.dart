import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  SecureStorageService._internal();

  static final SecureStorageService _instance =
      SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  static const _authTokenKey = 'authToken';
  static const _usernameKey = 'usernameKey';
  final _secureStorage = const FlutterSecureStorage();

  // ---- AUTHENTICATION TOKEN ----
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    return await _secureStorage.delete(key: _authTokenKey);
  }

  // ---- USERNAME ----
  Future<void> saveUsername(String username) async {
    await _secureStorage.write(key: _usernameKey, value: username);
  }

  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  Future<void> deleteUsername() async {
    return await _secureStorage.delete(key: _usernameKey);
  }
}

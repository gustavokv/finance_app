import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  SecureStorageService._internal();

  static final SecureStorageService _instance =
      SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  static const _tokenKey = 'tokenKey';
  final _secureStorage = const FlutterSecureStorage();

  // ---- AUTHENTICATION TOKEN ----
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteAuthToken() async {
    return await _secureStorage.delete(key: _tokenKey);
  }

  // ---- USER ----
  /*Future<void> saveUser(dynamic user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<String?> getUser() async {
    return await _secureStorage.read(key: _userKey);
  }

  Future<void> deleteUser() async {
    return await _secureStorage.delete(key: _userKey);
  }*/
}

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  SecureStorageService._internal();

  static final SecureStorageService _instance =
      SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  static const _userKey = 'userKey';
  final _secureStorage = const FlutterSecureStorage();

  // ---- AUTHENTICATION TOKEN ----
  Future<void> saveAuthToken(String token, String keyType) async {
    await _secureStorage.write(key: keyType, value: token);
  }

  Future<String?> getAuthToken(String keyType) async {
    return await _secureStorage.read(key: keyType);
  }

  Future<void> deleteAuthToken(keyType) async {
    return await _secureStorage.delete(key: keyType);
  }

  // ---- USER ----
  Future<void> saveUser(dynamic user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<String?> getUser() async {
    return await _secureStorage.read(key: _userKey);
  }

  Future<void> deleteUser() async {
    return await _secureStorage.delete(key: _userKey);
  }
}

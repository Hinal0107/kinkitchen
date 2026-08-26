import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Register User (CUSTOMER or RESTAURANT)
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role, // CUSTOMER or RESTAURANT
  }) async {
    final response = await _apiClient.post(
      ApiConfig.register,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role.toUpperCase(),
      },
    );

    final data = response['data'] ?? response;
    final String token = data['token'] as String? ?? '';
    if (token.isNotEmpty) {
      await _saveTokenAndRole(token, role.toLowerCase(), email);
    }

    final userJson = data['user'] ?? data;
    return User.fromJson(userJson as Map<String, dynamic>);
  }

  // 2. Login User
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
        'device_type': 'android',
        'device_id': 'flutter_device_1',
        'fcm_token': 'fcm_token_1',
      },
    );

    final data = response['data'] ?? response;
    final String token = data['token'] as String? ?? '';
    final userJson = data['user'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
    final String role = (userJson['role'] as String? ?? 'customer').toLowerCase();

    if (token.isNotEmpty) {
      await _saveTokenAndRole(token, role, email);
    }

    return User.fromJson(userJson);
  }

  // 3. Get Current User Profile (Me)
  Future<User> getMe() async {
    final response = await _apiClient.get(ApiConfig.me);
    final data = response['data'] ?? response['user'] ?? response;
    return User.fromJson(data as Map<String, dynamic>);
  }

  // 4. Update Profile
  Future<User> updateProfile({required String name, required String phone}) async {
    final response = await _apiClient.put(
      ApiConfig.profile,
      body: {
        'name': name,
        'phone': phone,
      },
    );
    final data = response['data'] ?? response['user'] ?? response;
    return User.fromJson(data as Map<String, dynamic>);
  }

  // 5. Logout
  Future<void> logout({String? fcmToken}) async {
    try {
      await _apiClient.post(
        ApiConfig.logout,
        body: fcmToken != null ? {'fcm_token': fcmToken} : null,
      );
    } catch (_) {}
    await _secureStorage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveTokenAndRole(String token, String role, String email) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    await prefs.setString('user_email', email);
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // 1. Register User (customer or restaurant)
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role, // customer or restaurant
    String? address,
    String? city,
    String? postcode,
    String? bankHolderName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankBranchName,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.register,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role.toLowerCase(),
        if (address != null && address.isNotEmpty) 'address_line_1': address,
        if (city != null && city.isNotEmpty) 'city': city,
        if (postcode != null && postcode.isNotEmpty) 'pincode': postcode,
        if (bankHolderName != null && bankHolderName.isNotEmpty) 'bank_account_holder': bankHolderName,
        if (bankAccountNumber != null && bankAccountNumber.isNotEmpty) 'bank_account_number': bankAccountNumber,
        if (bankIfscCode != null && bankIfscCode.isNotEmpty) 'bank_ifsc_code': bankIfscCode,
        if (bankBranchName != null && bankBranchName.isNotEmpty) 'bank_branch_name': bankBranchName,
      },
    );

    final data = response['data'] ?? response;
    String token = data['token'] as String? ?? data['access_token'] as String? ?? '';

    if (token.isEmpty) {
      // Auto login after registration to obtain Sanctum auth token
      try {
        return await login(email: email, password: password);
      } catch (_) {}
    } else {
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
    final String token = data['token'] as String? ?? data['access_token'] as String? ?? '';
    final userJson = data['user'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
    final User user = User.fromJson(userJson);

    if (token.isNotEmpty) {
      await _saveTokenAndRole(token, user.role, email);
    }

    return user;
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

  // 6. Delete User Account/Profile
  Future<void> deleteAccount() async {
    try {
      await _apiClient.delete(ApiConfig.profile);
    } catch (_) {
      try {
        await _apiClient.post('/auth/delete-account');
      } catch (_) {}
    }
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

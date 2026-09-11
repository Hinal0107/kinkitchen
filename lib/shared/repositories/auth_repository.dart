import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinkitchen/app/constants/api_constants.dart';
import 'package:kinkitchen/core/network/api_client.dart';
import 'package:kinkitchen/shared/models/user.dart';
import 'package:kinkitchen/shared/services/fcm_service.dart';

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
    final bool isRestaurant = role.toLowerCase() == 'restaurant';

    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role.toLowerCase(),
    };

    if (isRestaurant) {
      body['restaurant_name'] = name;
      if (address != null && address.isNotEmpty) {
        body['address_line_1'] = address;
        body['restaurant_address'] = address;
      }
      body['restaurant_city'] = (city != null && city.isNotEmpty) ? city : 'London';
      body['restaurant_state'] = 'England';
      body['restaurant_country'] = 'United Kingdom';
      if (postcode != null && postcode.isNotEmpty) {
        body['pincode'] = postcode;
        body['restaurant_pincode'] = postcode;
      }
      if (bankHolderName != null && bankHolderName.isNotEmpty) {
        body['bank_account_holder'] = bankHolderName;
      }
      if (bankAccountNumber != null && bankAccountNumber.isNotEmpty) {
        body['bank_account_number'] = bankAccountNumber;
      }
      if (bankIfscCode != null && bankIfscCode.isNotEmpty) {
        body['bank_ifsc_code'] = bankIfscCode;
        body['bank_ifsc'] = bankIfscCode;
      }
      if (bankBranchName != null && bankBranchName.isNotEmpty) {
        body['bank_branch_name'] = bankBranchName;
        body['bank_branch'] = bankBranchName;
      }
    } else {
      if (address != null && address.isNotEmpty) body['address_line_1'] = address;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (postcode != null && postcode.isNotEmpty) body['pincode'] = postcode;
      if (bankHolderName != null && bankHolderName.isNotEmpty) body['bank_account_holder'] = bankHolderName;
      if (bankAccountNumber != null && bankAccountNumber.isNotEmpty) body['bank_account_number'] = bankAccountNumber;
      if (bankIfscCode != null && bankIfscCode.isNotEmpty) {
        body['bank_ifsc_code'] = bankIfscCode;
        body['bank_ifsc'] = bankIfscCode;
      }
      if (bankBranchName != null && bankBranchName.isNotEmpty) {
        body['bank_branch_name'] = bankBranchName;
        body['bank_branch'] = bankBranchName;
      }
    }

    final response = await _apiClient.post(
      ApiConfig.register,
      body: body,
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
    String? fcmToken;
    try {
      fcmToken = await FcmService().getFcmToken();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'flutter_device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }

    final Map<String, dynamic> loginBody = {
      'email': email,
      'password': password,
      'device_type': Platform.isAndroid ? 'android' : 'ios',
      'device_id': deviceId,
      if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
    };

    dynamic response;
    try {
      response = await _apiClient.post(ApiConfig.login, body: loginBody);
    } catch (e) {
      // If backend throws MySQL duplicate entry error on fcm_token / user_devices, retry login cleanly without fcm_token
      if (e.toString().contains('Duplicate entry') ||
          e.toString().contains('fcm_tokens_token_unique') ||
          e.toString().contains('user_devices') ||
          e.toString().contains('1062')) {
        final fallbackBody = Map<String, dynamic>.from(loginBody)..remove('fcm_token');
        response = await _apiClient.post(ApiConfig.login, body: fallbackBody);
      } else {
        rethrow;
      }
    }

    final data = response['data'] ?? response;
    final String token = data['token'] as String? ?? data['access_token'] as String? ?? '';
    final userJson = data['user'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;
    final User user = User.fromJson(userJson);

    if (token.isNotEmpty) {
      await _saveTokenAndRole(token, user.role, email);
      if (fcmToken != null && fcmToken.isNotEmpty) {
        try {
          FcmService().syncTokenWithBackend(fcmToken);
        } catch (_) {}
      }
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
  Future<User> updateProfile({required String name, required String phone, File? image}) async {
    dynamic response;
    if (image != null) {
      response = await _apiClient.multipart(
        'POST',
        ApiConfig.profile,
        {
          '_method': 'PUT',
          'name': name,
          'phone': phone,
        },
        fileKey: 'profile_image',
        file: image,
      );
    } else {
      response = await _apiClient.put(
        ApiConfig.profile,
        body: {
          'name': name,
          'phone': phone,
        },
      );
    }
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

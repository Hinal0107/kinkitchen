import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';
import 'fcm_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _firebaseAuth;
  final _secureStorage = const FlutterSecureStorage();
  final _fcmService = FcmService();

  AuthService({ApiClient? apiClient, fb.FirebaseAuth? firebaseAuth})
      : _apiClient = apiClient ?? ApiClient(),
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  // Sign in with email and password via Laravel backend login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Generate a unique persistent device ID
    final prefs = await SharedPreferences.getInstance();
    final String deviceType = Platform.isAndroid ? 'android' : 'ios';
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${deviceType}_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }

    // Get current FCM token
    final String? fcmToken = await _fcmService.getFcmToken();

    final response = await _apiClient.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
        'device_type': deviceType,
        'device_id': deviceId,
        'fcm_token': fcmToken ?? 'mock-fcm-token-for-testing',
      },
    );

    // Extract token and user from response
    final dynamic responseData = response['data'] ?? response;
    final String token = responseData['token'] as String? 
        ?? responseData['access_token'] as String;
    final Map<String, dynamic> userJson = (responseData['user'] ?? responseData) as Map<String, dynamic>;
    final User user = User.fromJson(userJson);

    // Save Sanctum token in Secure Storage and non-sensitive session data in SharedPreferences
    await _secureStorage.write(key: 'auth_token', value: token);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_email', user.email);

    return user;
  }

  // Register Customer
  Future<User> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String postcode,
    required String password,
  }) async {
    // Generate a deterministic mock UID in case Firebase is offline
    final String cleanEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
    String firebaseUid = 'mock-uid-$cleanEmail';

    // 1. Try to Create User in Firebase Auth
    try {
      final fb.UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User? fbUser = credential.user;
      if (fbUser != null) {
        firebaseUid = fbUser.uid;
        await fbUser.updateDisplayName(name);
      }
    } catch (e) {
      // Catch network errors and continue with backend registration using fallback mock UID
      print('Firebase Auth offline/failed. Falling back to local backend direct registration. Error: $e');
    }

    // 2. Register on Laravel backend
    await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'firebase_uid': firebaseUid,
        'role': 'customer',
        'password': password,
        'password_confirmation': password,
        'address_line_1': address,
        'city': city,
        'pincode': postcode,
        'country': 'United Kingdom',
      },
    );

    // 3. Automatically login to retrieve and store token
    return await login(email: email, password: password);
  }

  // Register Restaurant
  Future<User> registerRestaurant({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String postcode,
    required String password,
    required String bankHolderName,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankBranchName,
  }) async {
    // Generate a deterministic mock UID in case Firebase is offline
    final String cleanEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
    String firebaseUid = 'mock-uid-$cleanEmail';

    // 1. Try to Create User in Firebase Auth
    try {
      final fb.UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User? fbUser = credential.user;
      if (fbUser != null) {
        firebaseUid = fbUser.uid;
        await fbUser.updateDisplayName(name);
      }
    } catch (e) {
      // Catch network errors and continue with backend registration using fallback mock UID
      print('Firebase Auth offline/failed. Falling back to local backend direct registration. Error: $e');
    }

    // 2. Register on Laravel backend
    await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'firebase_uid': firebaseUid,
        'role': 'restaurant',
        'password': password,
        'password_confirmation': password,
        'restaurant_name': name,
        'restaurant_address': address,
        'restaurant_city': 'London',
        'restaurant_state': 'England',
        'restaurant_country': 'United Kingdom',
        'restaurant_pincode': postcode,
        'bank_account_holder': bankHolderName,
        'bank_account_number': bankAccountNumber,
        'bank_ifsc': bankIfscCode,
        'bank_branch': bankBranchName,
      },
    );

    // 3. Automatically login to retrieve and store token
    return await login(email: email, password: password);
  }

  // Fetch current user using bearer token
  Future<User> getCurrentUser() async {
    final response = await _apiClient.get(ApiConfig.me);
    // Backend returns: { "success": true, "data": { "user": {...} } }
    final dynamic responseData = response['data'] ?? response;
    final userJson = (responseData['user'] ?? responseData) as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  // Logout from Firebase + backend API
  Future<void> logout() async {
    try {
      final String? fcmToken = await _fcmService.getFcmToken();
      await _apiClient.post(
        '/auth/logout',
        body: {
          if (fcmToken != null) 'fcm_token': fcmToken,
        },
      );
    } catch (_) {}

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: 'auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
  }

  // Check if session exists locally
  Future<String?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
}

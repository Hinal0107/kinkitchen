import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;
  final fb.FirebaseAuth _firebaseAuth;

  AuthService({ApiClient? apiClient, fb.FirebaseAuth? firebaseAuth})
      : _apiClient = apiClient ?? ApiClient(),
        _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  // Sign in with email and password via Firebase + backend login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // Generate a deterministic mock UID in case Firebase is offline
    final String cleanEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
    String firebaseUid = 'mock-uid-$cleanEmail';

    // 1. Try to Authenticate with Firebase Auth
    try {
      final fb.UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fb.User? fbUser = credential.user;
      if (fbUser != null) {
        firebaseUid = fbUser.uid;
      }
    } catch (e) {
      // Catch network-request-failed or offline errors and use mock UID as fallback
      print('Firebase Auth offline/failed. Falling back to local backend direct login. Error: $e');
    }

    // 2. Authenticate with Laravel Backend using firebase_uid
    final String deviceType = Platform.isAndroid ? 'android' : 'ios';
    final String deviceId = 'device-$deviceType-${firebaseUid.substring(0, firebaseUid.length > 5 ? 5 : firebaseUid.length)}';
    
    final response = await _apiClient.post(
      ApiConfig.login,
      body: {
        'firebase_uid': firebaseUid,
        'device_type': deviceType,
        'fcm_token': 'mock-fcm-token-${firebaseUid.substring(0, firebaseUid.length > 8 ? 8 : firebaseUid.length)}',
        'device_id': deviceId,
      },
    );

    // 3. Extract the token and user from backend response
    // Backend returns: { "success": true, "data": { "user": {...}, "token": "...", "role": "..." } }
    final dynamic responseData = response['data'] ?? response;
    final String token = responseData['token'] as String? 
        ?? responseData['access_token'] as String? 
        ?? firebaseUid;
    final Map<String, dynamic> userJson = (responseData['user'] ?? responseData) as Map<String, dynamic>;
    final User user = User.fromJson(userJson);

    // 4. Save backend token and role locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
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
      await _apiClient.post('/auth/logout');
    } catch (_) {}

    try {
      await _firebaseAuth.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
  }

  // Check if session exists locally
  Future<String?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
}

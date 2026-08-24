import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../errors/failure.dart';

class ApiClient {
  final http.Client _client;
  final _secureStorage = const FlutterSecureStorage();

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Retrieve locally stored backend Auth Bearer Token
  Future<String?> _getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (!isMultipart) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (token != null) 'X-Authorization': 'Bearer $token',
    };
    return headers;
  }

  Future<void> _clearLocalSessionAndRedirect() async {
    await _secureStorage.delete(key: 'auth_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil('/role-selection', (route) => false);
  }

  // GET Request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParameters}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParameters);
      final headers = await _getHeaders();
      final response = await _client.get(uri, headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  // POST Request
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  // PUT Request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  // DELETE Request
  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await _client.delete(uri, headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  // Multipart/Form-Data File Upload Request (for images)
  Future<dynamic> multipart(
    String method,
    String endpoint,
    Map<String, String> fields, {
    String? fileKey,
    File? file,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest(method, uri);
      
      // Inject Authorization Headers
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      // Attach text form fields
      request.fields.addAll(fields);

      // Attach file stream if present
      if (fileKey != null && file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            file.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw const NetworkFailure();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
  }

  // Process Response Status Codes
  dynamic _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    // Parse response body safely
    dynamic body;
    try {
      body = json.decode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    switch (statusCode) {
      case 400:
        throw Failure(body['message'] ?? 'Bad Request');
      case 401:
        _clearLocalSessionAndRedirect();
        throw const AuthFailure('Session expired. Please log in again.');
      case 403:
        throw const AuthFailure('Access denied. You do not have permissions.');
      case 404:
        throw const Failure('Resource not found.');
      case 422:
        // Parse Laravel form validation errors
        throw ValidationFailure(
          body['message'] ?? 'Validation failed.',
          errors: body['errors'],
        );
      case 429:
        throw const Failure('Too many requests. Please slow down.');
      case 500:
      default:
        throw ServerFailure(
          body is Map && body.containsKey('message') 
              ? body['message'] 
              : 'Server error ($statusCode).',
        );
    }
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

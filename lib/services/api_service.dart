import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';

class ApiService {
  String get baseUrl => EnvConfig.baseUrl;
  final _storage = const FlutterSecureStorage();
  String? _token;

  Future<void> init() async {
    _token = await _storage.read(key: 'rabka_auth_token');
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _storage.write(key: 'rabka_auth_token', value: token);
    } else {
      await _storage.delete(key: 'rabka_auth_token');
    }
  }

  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: 'rabka_remember_me', value: value.toString());
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: 'rabka_remember_me');
    return value == 'true';
  }

  Future<void> saveLastEmail(String email) async {
    await _storage.write(key: 'rabka_last_email', value: email);
  }

  Future<String?> getLastEmail() async {
    return await _storage.read(key: 'rabka_last_email');
  }

  Future<void> saveLastPassword(String password) async {
    await _storage.write(key: 'rabka_last_password', value: password);
  }

  Future<String?> getLastPassword() async {
    return await _storage.read(key: 'rabka_last_password');
  }

  Future<dynamic> request(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
    if (_token == null) {
      try {
        _token = await _storage.read(key: 'rabka_auth_token');
      } catch (_) {}
    }

    final url = Uri.parse('$baseUrl$path');
    print('[ApiService] 🔵 $method Request: $url');
    final tokenPreview = _token != null && _token!.length > 8 ? '${_token!.substring(0, 8)}...' : (_token ?? 'NONE');
    print('[ApiService] Auth Token: $tokenPreview');

    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: body != null ? jsonEncode(body) : null);
          break;
        default:
          response = await http.get(url, headers: headers);
      }
      print('[ApiService] 📊 Response Status: ${response.statusCode}');
      final previewLen = response.body.length > 200 ? 200 : response.body.length;
      print('[ApiService] 📦 Response Body: ${response.body.substring(0, previewLen)}');
    } catch (e) {
      print('[ApiService] ❌ Connection Error: $e');
      throw Exception('Connection error: $e');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('[ApiService] ✅ Request successful');
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    Map<String, dynamic>? errorData;
    try {
      errorData = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode == 401) {
      await setToken(null);
    }

    final errorMessage = errorData?['message'] ??
        errorData?['error'] ??
        'API Request failed with status: ${response.statusCode}';
    print('[ApiService] ❌ API Error: ${response.statusCode} - $errorMessage');
    throw Exception(errorMessage);
  }
}

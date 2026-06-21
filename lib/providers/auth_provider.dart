import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthUser? _user;
  Profile? _profile;
  bool _loading = true;
  bool _rememberMe = false;

  AuthUser? get user => _user;
  Profile? get profile => _profile;
  bool get loading => _loading;
  bool get rememberMe => _rememberMe;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _apiService.init();
    _rememberMe = await _apiService.getRememberMe();
    debugPrint('[AuthProvider] Initializing. RememberMe: $_rememberMe');
    
    try {
      if (_rememberMe) {
        debugPrint('[AuthProvider] Attempting auto-login...');
        await fetchMe();
        debugPrint('[AuthProvider] Auto-login successful for: ${_user?.email}');
      } else {
        debugPrint('[AuthProvider] RememberMe is OFF. Clearing token.');
        await _apiService.setToken(null);
      }
    } catch (e) {
      debugPrint('[AuthProvider] Auto-login failed: $e');
      _user = null;
      _profile = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMe() async {
    final data = await _apiService.request('/api/auth/me');
    _user = AuthUser.fromJson(data['user']);
    _profile = Profile.fromJson(data['profile']);
    notifyListeners();
  }

  Future<void> signIn(String email, String password, {bool rememberMe = false}) async {
    final data = await _apiService.request(
      '/api/auth/sign-in',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    await _apiService.setToken(data['token']);
    
    _rememberMe = rememberMe;
    await _apiService.setRememberMe(rememberMe);
    if (rememberMe) {
      await _apiService.saveLastEmail(email);
      await _apiService.saveLastPassword(password);
    } else {
      await _apiService.saveLastEmail('');
      await _apiService.saveLastPassword('');
    }

    _user = AuthUser.fromJson(data['user']);
    _profile = Profile.fromJson(data['profile']);
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String fullName, String phone) async {
    final data = await _apiService.request(
      '/api/auth/sign-up',
      method: 'POST',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      },
    );
    await _apiService.setToken(data['token']);
    
    // Defaulting to false for sign up or we could pass it too
    _rememberMe = false;
    await _apiService.setRememberMe(false);
    await _apiService.saveLastEmail('');

    _user = AuthUser.fromJson(data['user']);
    _profile = Profile.fromJson(data['profile']);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _apiService.request('/api/auth/sign-out', method: 'POST');
    } catch (_) {}
    await _apiService.setToken(null);
    // We don't clear setRememberMe here anymore to keep the preference
    _user = null;
    _profile = null;
    notifyListeners();
  }
  
  Future<String?> getLastEmail() async {
    return await _apiService.getLastEmail();
  }

  Future<String?> getLastPassword() async {
    return await _apiService.getLastPassword();
  }
}

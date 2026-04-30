import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthUser? _user;
  Profile? _profile;
  bool _loading = true;

  AuthUser? get user => _user;
  Profile? get profile => _profile;
  bool get loading => _loading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _apiService.init();
    try {
      await fetchMe();
    } catch (e) {
      // Not logged in or error
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

  Future<void> signIn(String email, String password) async {
    final data = await _apiService.request(
      '/api/auth/sign-in',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    await _apiService.setToken(data['token']);
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
    _user = AuthUser.fromJson(data['user']);
    _profile = Profile.fromJson(data['profile']);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _apiService.request('/api/auth/sign-out', method: 'POST');
    } catch (_) {}
    await _apiService.setToken(null);
    _user = null;
    _profile = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/auth_models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  AuthUser? _user;
  Profile? _profile;
  bool _loading = true;
  bool _rememberMe = false;
  bool _biometricsEnabled = false;
  bool _isBiometricAvailable = false;

  AuthUser? get user => _user;
  Profile? get profile => _profile;
  bool get loading => _loading;
  bool get rememberMe => _rememberMe;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _apiService.init();
    _rememberMe = await _apiService.getRememberMe();
    _biometricsEnabled = await _apiService.getBiometricsEnabled();
    
    // Check if biometrics are available on the device
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      _isBiometricAvailable = canAuthenticate;
    } catch (e) {
      _isBiometricAvailable = false;
    }

    debugPrint('[AuthProvider] Initializing. RememberMe: $_rememberMe, Biometrics: $_biometricsEnabled');
    
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
      // If we don't remember, we can't use biometrics next time either
      await setBiometricsEnabled(false);
    }

    _user = AuthUser.fromJson(data['user']);
    _profile = Profile.fromJson(data['profile']);
    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    await _apiService.setBiometricsEnabled(value);
    notifyListeners();
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricAvailable) return false;

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        final email = await _apiService.getLastEmail();
        final password = await _apiService.getLastPassword();

        if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
          await signIn(email, password, rememberMe: true);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[AuthProvider] Biometric auth error: $e');
      return false;
    }
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
    
    _rememberMe = false;
    await _apiService.setRememberMe(false);
    await _apiService.saveLastEmail('');
    await _apiService.saveLastPassword('');
    await setBiometricsEnabled(false);

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
  
  Future<String?> getLastEmail() async {
    return await _apiService.getLastEmail();
  }

  Future<String?> getLastPassword() async {
    return await _apiService.getLastPassword();
  }
}

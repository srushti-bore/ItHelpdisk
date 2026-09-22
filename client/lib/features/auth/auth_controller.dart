import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_constants.dart';
import 'package:it_helpdesk_client/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthController() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.keyUserData);
      final token = prefs.getString(AppConstants.keyAccessToken);

      if (userJson != null && token != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson));
        // Verify with backend
        try {
          final res = await apiClient.get('/auth/me');
          _currentUser = UserModel.fromJson(res);
          await prefs.setString(AppConstants.keyUserData, jsonEncode(_currentUser!.toJson()));
        } catch (_) {
          // Token expired, clear session
          await logout();
        }
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post('/auth/login', body: {
        'email': email.trim(),
        'password': password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAccessToken, res['access_token']);
      await prefs.setString(AppConstants.keyRefreshToken, res['refresh_token']);

      // Fetch user profile
      final userRes = await apiClient.get('/auth/me');
      _currentUser = UserModel.fromJson(userRes);
      await prefs.setString(AppConstants.keyUserData, jsonEncode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected connection error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName, {String? site}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await apiClient.post('/auth/register', body: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'site': site,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during registration';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(String code, {String? codeVerifier}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post('/auth/google', body: {
        'code': code,
        'code_verifier': codeVerifier,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAccessToken, res['access_token']);
      await prefs.setString(AppConstants.keyRefreshToken, res['refresh_token']);

      final userRes = await apiClient.get('/auth/me');
      _currentUser = UserModel.fromJson(userRes);
      await prefs.setString(AppConstants.keyUserData, jsonEncode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUserData);

    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}

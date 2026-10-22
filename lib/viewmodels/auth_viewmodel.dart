import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

/// ViewModel cho chức năng xác thực (login, register, session)
class AuthViewModel extends ChangeNotifier {
  final FirestoreService _db;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(this._db);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Hash helper ───────────────────────────────────────────────────────────

  String _hashPassword(String pw) {
    return sha256.convert(utf8.encode(pw)).toString();
  }

  // ─── Session ───────────────────────────────────────────────────────────────

  /// Kiểm tra session lưu trong SharedPreferences khi mở app
  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      _currentUser = await _db.getUserById(userId);
      notifyListeners();
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  /// Đăng nhập – trả về true nếu thành công
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _db.getUserByEmail(email.trim().toLowerCase());
      if (user == null || user.password != _hashPassword(password)) {
        _errorMessage = 'Email hoặc mật khẩu không đúng';
        _setLoading(false);
        return false;
      }
      await _saveSession(user.id);
      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi, vui lòng thử lại';
      _setLoading(false);
      return false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────

  /// Đăng ký tài khoản mới – trả về true nếu thành công
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Kiểm tra email đã tồn tại chưa
      final existing = await _db.getUserByEmail(email.trim().toLowerCase());
      if (existing != null) {
        _errorMessage = 'Email đã được sử dụng';
        _setLoading(false);
        return false;
      }

      final newUser = User(
        id: 0,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: _hashPassword(password),
        phone: phone.trim(),
        avatar: null,
        createdAt: DateTime.now().toIso8601String(),
      );

      final userId = await _db.insertUser(newUser);
      final savedUser = await _db.getUserById(userId);
      await _saveSession(userId);
      _currentUser = savedUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi, vui lòng thử lại';
      _setLoading(false);
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    _currentUser = null;
    notifyListeners();
  }

  // ─── Profile update ────────────────────────────────────────────────────────

  /// Cập nhật tên và số điện thoại
  Future<void> updateProfile(String name, String phone) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, phone: phone);
    await _db.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  /// Cập nhật avatar (local file path)
  Future<void> updateAvatar(String path) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(avatar: path);
    await _db.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

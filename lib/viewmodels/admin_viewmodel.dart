import 'package:flutter/foundation.dart';
import '../models/court.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

/// ViewModel cho màn hình quản trị (admin)
class AdminViewModel extends ChangeNotifier {
  final FirestoreService _db;

  List<User> _users = [];
  List<Court> _allCourts = [];
  bool _isLoadingUsers = false;
  bool _isLoadingCourts = false;
  String? _errorMessage;

  AdminViewModel(this._db);

  List<User> get users => _users;
  List<Court> get allCourts => _allCourts;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingCourts => _isLoadingCourts;
  String? get errorMessage => _errorMessage;

  // ─── Users ─────────────────────────────────────────────────────────────────

  /// Tải toàn bộ danh sách users
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await _db.getAllUsers();
    } catch (e) {
      _errorMessage = 'Không tải được danh sách user';
      debugPrint('AdminViewModel.loadUsers error: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  /// Ban hoặc unban tài khoản user
  Future<void> toggleUserBan(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) return;

    final newBanned = !user.isBanned;

    // Optimistic update
    _users[index] = user.copyWith(isBanned: newBanned);
    notifyListeners();

    try {
      await _db.toggleUserBan(user.id, newBanned);
    } catch (e) {
      // Rollback nếu lỗi
      _users[index] = user;
      _errorMessage = 'Không thực hiện được, vui lòng thử lại';
      debugPrint('AdminViewModel.toggleUserBan error: $e');
      notifyListeners();
    }
  }

  // ─── Courts ────────────────────────────────────────────────────────────────

  /// Tải toàn bộ danh sách sân (kể cả đã tắt)
  Future<void> loadCourts() async {
    _isLoadingCourts = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _allCourts = await _db.getAllCourts();
    } catch (e) {
      _errorMessage = 'Không tải được danh sách sân';
      debugPrint('AdminViewModel.loadCourts error: $e');
    } finally {
      _isLoadingCourts = false;
      notifyListeners();
    }
  }

  /// Bật/tắt trạng thái hoạt động của sân
  Future<void> toggleCourtActive(Court court) async {
    final index = _allCourts.indexWhere((c) => c.id == court.id);
    if (index == -1) return;

    final newActive = !court.isActive;

    // Optimistic update
    _allCourts[index] = court.copyWith(isActive: newActive);
    notifyListeners();

    try {
      await _db.toggleCourtActive(court.id, newActive);
    } catch (e) {
      // Rollback nếu lỗi
      _allCourts[index] = court;
      _errorMessage = 'Không thực hiện được, vui lòng thử lại';
      debugPrint('AdminViewModel.toggleCourtActive error: $e');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

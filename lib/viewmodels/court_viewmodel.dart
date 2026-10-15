import 'package:flutter/foundation.dart';
import '../models/court.dart';
import '../services/database_service.dart';

/// ViewModel cho danh sách sân, tìm kiếm và lọc
class CourtViewModel extends ChangeNotifier {
  final DatabaseService _db;

  List<Court> _courts = [];
  List<Court> _filteredCourts = [];
  String _selectedType = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  Court? _selectedCourt;

  CourtViewModel(this._db);

  List<Court> get courts => _courts;
  List<Court> get filteredCourts => _filteredCourts;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  Court? get selectedCourt => _selectedCourt;

  // ─── Load ──────────────────────────────────────────────────────────────────

  /// Tải danh sách tất cả sân từ DB
  Future<void> loadCourts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courts = await _db.getCourts();
      _applyFilter();
    } catch (e) {
      debugPrint('CourtViewModel.loadCourts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải thông tin một sân theo id
  Future<void> loadCourtById(int id) async {
    _selectedCourt = await _db.getCourtById(id);
    notifyListeners();
  }

  // ─── Filter & Search ───────────────────────────────────────────────────────

  /// Lọc sân theo loại
  void filterByType(String type) {
    _selectedType = type;
    _applyFilter();
    notifyListeners();
  }

  /// Tìm kiếm theo từ khoá
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Áp dụng cả filter loại và search query
  void _applyFilter() {
    _filteredCourts = _courts.where((c) {
      final matchType = _selectedType == 'all' || c.type == _selectedType;
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  void clearSelectedCourt() {
    _selectedCourt = null;
    notifyListeners();
  }
}

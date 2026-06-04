import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

/// Announcement Controller
/// Mengelola state dan logic untuk pengumuman dengan pagination
class AnnouncementController extends ChangeNotifier {
  List<AnnouncementModel> _announcementList = [];
  AnnouncementModel? _selectedAnnouncement;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _limit = 20;
  bool _hasMore = true;
  
  // Getters
  List<AnnouncementModel> get announcementList => _announcementList;
  AnnouncementModel? get selectedAnnouncement => _selectedAnnouncement;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  
  // Get All Announcements (first page)
  Future<void> getAllAnnouncements({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _announcementList.clear();
      }
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final result = await AnnouncementService.getAllAnnouncements(
        page: _currentPage,
        limit: _limit,
      );
      
      final announcements = result['announcements'] as List<AnnouncementModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      _announcementList = announcements;
      _currentPage = pagination['page'] ?? 1;
      _totalPages = pagination['totalPages'] ?? 1;
      _totalItems = pagination['total'] ?? 0;
      _hasMore = _currentPage < _totalPages;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Load More Announcements (next page)
  Future<void> loadMoreAnnouncements() async {
    if (_isLoadingMore || !_hasMore) return;
    
    try {
      _isLoadingMore = true;
      notifyListeners();
      
      final nextPage = _currentPage + 1;
      
      final result = await AnnouncementService.getAllAnnouncements(
        page: nextPage,
        limit: _limit,
      );
      
      final announcements = result['announcements'] as List<AnnouncementModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;
      
      _announcementList.addAll(announcements);
      _currentPage = pagination['page'] ?? nextPage;
      _totalPages = pagination['totalPages'] ?? _totalPages;
      _totalItems = pagination['total'] ?? _totalItems;
      _hasMore = _currentPage < _totalPages;
      
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Announcement Detail
  Future<void> getAnnouncementDetail(String announcementId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _selectedAnnouncement = await AnnouncementService.getAnnouncementById(announcementId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Announcements (alias for getAllAnnouncements)
  List<AnnouncementModel> get announcements => _announcementList;
  
  // Get Urgent Announcements
  List<AnnouncementModel> get urgentAnnouncements {
    return _announcementList.where((announcement) => 
      announcement.prioritas == 'urgent'
    ).toList();
  }
  
  // Get Important Announcements
  List<AnnouncementModel> get importantAnnouncements {
    return _announcementList.where((announcement) => 
      announcement.prioritas == 'penting'
    ).toList();
  }
  
  // Get Info Announcements
  List<AnnouncementModel> get infoAnnouncements {
    return _announcementList.where((announcement) => 
      announcement.prioritas == 'info'
    ).toList();
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Clear Selected Announcement
  void clearSelectedAnnouncement() {
    _selectedAnnouncement = null;
    notifyListeners();
  }
}

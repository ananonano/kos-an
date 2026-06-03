import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

/// Announcement Controller
/// Mengelola state dan logic untuk pengumuman
class AnnouncementController extends ChangeNotifier {
  List<AnnouncementModel> _announcementList = [];
  AnnouncementModel? _selectedAnnouncement;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<AnnouncementModel> get announcementList => _announcementList;
  AnnouncementModel? get selectedAnnouncement => _selectedAnnouncement;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get All Announcements
  Future<void> getAllAnnouncements() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _announcementList = await AnnouncementService.getAllAnnouncements();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
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

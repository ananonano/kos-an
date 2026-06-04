import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/announcement_service.dart';
import '../../models/announcement_model.dart';
import './local_notification_service.dart';

/// Notification Polling Service
/// Periodically checks backend for new ANNOUNCEMENTS and shows system notifications
/// NOTE: Only announcements trigger system (HP) notifications from the announcements table.
/// Payment, bill, and maintenance notifications only appear in the in-app notification menu (notifications table).
class NotificationPollingService {
  static Timer? _timer;
  static bool _isRunning = false;
  static const String _lastCheckKey = 'last_announcement_check';
  static Set<int> _shownAnnouncementIds = {};

  /// Start polling for new announcements
  static Future<void> start() async {
    if (_isRunning) {
      debugPrint('⚠️ Announcement polling already running');
      return;
    }

    _isRunning = true;
    await _loadShownAnnouncements();

    // Check immediately on start
    await _checkForNewAnnouncements();

    // Then check every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkForNewAnnouncements();
    });

    debugPrint('✅ Announcement polling started (every 30 seconds)');
  }

  /// Stop polling
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('⏹️ Announcement polling stopped');
  }

  /// Check for new announcements
  static Future<void> _checkForNewAnnouncements() async {
    try {
      debugPrint('🔍 Checking for new announcements...');

      // Get all announcements from backend (they include isRead status)
      final result = await AnnouncementService.getAllAnnouncements();
      final announcements = result['announcements'] as List<AnnouncementModel>;

      if (announcements.isEmpty) {
        debugPrint('📭 No announcements found');
        return;
      }

      // Filter unread announcements that haven't been shown yet
      final newAnnouncements = announcements.where((announcement) {
        final announcementId = int.tryParse(announcement.id) ?? 0;
        return !announcement.isRead && !_shownAnnouncementIds.contains(announcementId);
      }).toList();

      if (newAnnouncements.isEmpty) {
        debugPrint('✅ No new announcements to show');
        return;
      }

      debugPrint('Found ${newAnnouncements.length} new announcements');

      // Show system notifications for new announcements
      for (var announcement in newAnnouncements) {
        final announcementId = int.tryParse(announcement.id) ?? 0;

        await LocalNotificationService.showAnnouncementNotification(
          id: announcementId,
          title: announcement.judul,
          body: announcement.konten,
        );

        // Mark as shown
        _shownAnnouncementIds.add(announcementId);
      }

      // Save shown announcement IDs
      await _saveShownAnnouncements();

      // Update last check timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('✅ Showed ${newAnnouncements.length} announcement system notifications');
    } catch (e) {
      debugPrint('❌ Error checking announcements: $e');
    }
  }

  /// Load shown announcement IDs from local storage
  static Future<void> _loadShownAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = prefs.getStringList('shown_announcement_ids') ?? [];
      _shownAnnouncementIds = idsString.map((id) => int.parse(id)).toSet();
      debugPrint('📥 Loaded ${_shownAnnouncementIds.length} shown announcement IDs');
    } catch (e) {
      debugPrint('❌ Error loading shown announcements: $e');
      _shownAnnouncementIds = {};
    }
  }

  /// Save shown announcement IDs to local storage
  static Future<void> _saveShownAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = _shownAnnouncementIds.map((id) => id.toString()).toList();
      await prefs.setStringList('shown_announcement_ids', idsString);
      debugPrint('💾 Saved ${_shownAnnouncementIds.length} shown announcement IDs');
    } catch (e) {
      debugPrint('❌ Error saving shown announcements: $e');
    }
  }

  /// Clear shown announcements cache (for testing)
  static Future<void> clearCache() async {
    _shownAnnouncementIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shown_announcement_ids');
    await prefs.remove(_lastCheckKey);
    debugPrint('🗑️ Cleared announcement cache');
  }

  /// Get last check time
  static Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCheckKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import './local_notification_service.dart';

/// Notification Polling Service
/// Periodically checks backend for new notifications and shows system notifications
class NotificationPollingService {
  static Timer? _timer;
  static bool _isRunning = false;
  static const String _lastCheckKey = 'last_notification_check';
  static Set<int> _shownNotificationIds = {};

  /// Start polling for new notifications
  static Future<void> start() async {
    if (_isRunning) {
      debugPrint('⚠️ Notification polling already running');
      return;
    }

    _isRunning = true;
    await _loadShownNotifications();

    // Check immediately on start
    await _checkForNewNotifications();

    // Then check every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkForNewNotifications();
    });

    debugPrint('✅ Notification polling started (every 30 seconds)');
  }

  /// Stop polling
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    debugPrint('⏹️ Notification polling stopped');
  }

  /// Check for new notifications
  static Future<void> _checkForNewNotifications() async {
    try {
      debugPrint('🔍 Checking for new notifications...');

      // Get unread notifications from backend
      final notifications = await NotificationService.getAllNotifications(
        isRead: false,
      );

      if (notifications.isEmpty) {
        debugPrint('📭 No new notifications');
        return;
      }

      // Filter notifications that haven't been shown yet
      final newNotifications = notifications.where((notif) {
        final notifId = int.tryParse(notif.id) ?? 0;
        return !_shownNotificationIds.contains(notifId);
      }).toList();

      if (newNotifications.isEmpty) {
        debugPrint('✅ No new notifications to show');
        return;
      }

      debugPrint('🔔 Found ${newNotifications.length} new notifications');

      // Show system notifications for new notifications
      for (var notif in newNotifications) {
        final notifId = int.tryParse(notif.id) ?? 0;

        switch (notif.type) {
          case 'announcement':
            await LocalNotificationService.showAnnouncementNotification(
              id: notifId,
              title: notif.title,
              body: notif.message,
            );
            break;
          case 'payment':
            await LocalNotificationService.showPaymentNotification(
              id: notifId,
              title: notif.title,
              body: notif.message,
            );
            break;
          default:
            await LocalNotificationService.showNotification(
              id: notifId,
              title: notif.title,
              body: notif.message,
              payload: '${notif.type}_${notif.relatedId}',
            );
        }

        // Mark as shown
        _shownNotificationIds.add(notifId);
      }

      // Save shown notification IDs
      await _saveShownNotifications();

      // Update last check timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);

      debugPrint('✅ Showed ${newNotifications.length} system notifications');
    } catch (e) {
      debugPrint('❌ Error checking notifications: $e');
    }
  }

  /// Load shown notification IDs from local storage
  static Future<void> _loadShownNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = prefs.getStringList('shown_notification_ids') ?? [];
      _shownNotificationIds = idsString.map((id) => int.parse(id)).toSet();
      debugPrint('📥 Loaded ${_shownNotificationIds.length} shown notification IDs');
    } catch (e) {
      debugPrint('❌ Error loading shown notifications: $e');
      _shownNotificationIds = {};
    }
  }

  /// Save shown notification IDs to local storage
  static Future<void> _saveShownNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsString = _shownNotificationIds.map((id) => id.toString()).toList();
      await prefs.setStringList('shown_notification_ids', idsString);
      debugPrint('💾 Saved ${_shownNotificationIds.length} shown notification IDs');
    } catch (e) {
      debugPrint('❌ Error saving shown notifications: $e');
    }
  }

  /// Clear shown notifications cache (for testing)
  static Future<void> clearCache() async {
    _shownNotificationIds.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shown_notification_ids');
    await prefs.remove(_lastCheckKey);
    debugPrint('🗑️ Cleared notification cache');
  }

  /// Get last check time
  static Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCheckKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
}

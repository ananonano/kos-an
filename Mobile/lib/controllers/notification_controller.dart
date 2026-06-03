import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Notification Controller
/// Mengelola state dan logic untuk notifikasi
class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  // Get all notifications
  Future<void> getAllNotifications() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _notifications = await NotificationService.getAllNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          relatedId: _notifications[index].relatedId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          relatedId: n.relatedId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await NotificationService.deleteNotification(id);

      // Update local state
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

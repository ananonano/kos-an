import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

/// Chat Controller
/// Mengelola state dan logic untuk chat realtime
class ChatController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentChatRoomId;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentChatRoomId => _currentChatRoomId;
  
  // Create or Get Chat Room
  Future<String?> createOrGetChatRoom({
    required String penghuniId,
    required String adminId,
    String? penghuniName,
    String? adminName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentChatRoomId = await ChatService.createOrGetChatRoom(
        penghuniId: penghuniId,
        adminId: adminId,
        penghuniName: penghuniName,
        adminName: adminName,
      );
      
      _isLoading = false;
      notifyListeners();
      return _currentChatRoomId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
  
  // Send Message
  Future<bool> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
    String? imageUrl,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      await ChatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        message: message,
        imageUrl: imageUrl,
        senderName: senderName,
        senderRole: senderRole,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Stream Messages
  Stream<List<ChatMessageModel>> streamMessages(String chatRoomId) {
    return ChatService.streamMessages(chatRoomId);
  }
  
  // Stream Chat Rooms
  Stream<List<ChatRoomModel>> streamChatRooms({
    String? userId,
    String? role,
  }) {
    return ChatService.streamChatRooms(userId: userId, role: role);
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

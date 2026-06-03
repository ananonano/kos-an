import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Message Model
/// Model untuk pesan chat (disimpan di Firebase Firestore)
class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;
  
  // Relations
  final String? senderName;
  final String? senderRole;
  
  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.message,
    this.imageUrl,
    required this.createdAt,
    this.senderName,
    this.senderRole,
  });
  
  // From Firestore
  factory ChatMessageModel.fromFirestore(Map<String, dynamic> data) {
    return ChatMessageModel(
      id: data['id'],
      chatRoomId: data['chat_room_id'],
      senderId: data['sender_id'],
      message: data['message'],
      imageUrl: data['image_url'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      senderName: data['sender_name'],
      senderRole: data['sender_role'],
    );
  }
  
  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'message': message,
      'image_url': imageUrl,
      'sender_name': senderName,
      'sender_role': senderRole,
    };
  }
}

/// Chat Room Model
/// Model untuk chat room
class ChatRoomModel {
  final String id;
  final String penghuniId;
  final String adminId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final String? penghuniName;
  final String? adminName;
  
  ChatRoomModel({
    required this.id,
    required this.penghuniId,
    required this.adminId,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    this.penghuniName,
    this.adminName,
  });
  
  // From Firestore
  factory ChatRoomModel.fromFirestore(Map<String, dynamic> data) {
    return ChatRoomModel(
      id: data['id'],
      penghuniId: data['penghuni_id'],
      adminId: data['admin_id'],
      lastMessage: data['last_message'],
      lastMessageTime: data['last_message_time'] != null
          ? (data['last_message_time'] as Timestamp).toDate()
          : null,
      unreadCount: data['unread_count'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      penghuniName: data['penghuni_name'],
      adminName: data['admin_name'],
    );
  }
  
  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'penghuni_id': penghuniId,
      'admin_id': adminId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'penghuni_name': penghuniName,
      'admin_name': adminName,
    };
  }
}

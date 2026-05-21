import '../core/services/firebase_service.dart';
import '../core/config/app_config.dart';
import '../models/chat_model.dart';

/// Chat Service
/// Mengelola operasi chat realtime melalui Firebase Firestore
class ChatService {
  // Create or Get Chat Room
  static Future<String> createOrGetChatRoom({
    required String penghuniId,
    required String adminId,
    String? penghuniName,
    String? adminName,
  }) async {
    try {
      // Check if chat room already exists
      final existingRooms = await FirebaseService.getDocuments(
        AppConfig.chatCollection,
        where: {
          'penghuni_id': penghuniId,
          'admin_id': adminId,
        },
      );
      
      if (existingRooms.isNotEmpty) {
        return existingRooms.first['id'];
      }
      
      // Create new chat room
      final data = {
        'penghuni_id': penghuniId,
        'admin_id': adminId,
        'last_message': null,
        'last_message_time': null,
        'unread_count': 0,
        'penghuni_name': penghuniName,
        'admin_name': adminName,
      };
      
      final docId = await FirebaseService.addDocument(
        AppConfig.chatCollection,
        data,
      );
      
      return docId;
    } catch (e) {
      throw Exception('Gagal membuat chat room: ${e.toString()}');
    }
  }
  
  // Send Message
  static Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String message,
    String? imageUrl,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      // Add message to subcollection
      final messageData = {
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'message': message,
        'image_url': imageUrl,
        'sender_name': senderName,
        'sender_role': senderRole,
      };
      
      await FirebaseService.addDocument(
        '${AppConfig.chatCollection}/$chatRoomId/messages',
        messageData,
      );
      
      // Update chat room last message
      await FirebaseService.updateDocument(
        AppConfig.chatCollection,
        chatRoomId,
        {
          'last_message': message,
          'last_message_time': DateTime.now(),
          'unread_count': 1, // Increment in real implementation
        },
      );
    } catch (e) {
      throw Exception('Gagal mengirim pesan: ${e.toString()}');
    }
  }
  
  // Stream Messages
  static Stream<List<ChatMessageModel>> streamMessages(String chatRoomId) {
    try {
      return FirebaseService.streamDocuments(
        '${AppConfig.chatCollection}/$chatRoomId/messages',
        orderBy: 'createdAt',
        descending: false,
      ).map((docs) {
        return docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Gagal streaming pesan: ${e.toString()}');
    }
  }
  
  // Stream Chat Rooms
  static Stream<List<ChatRoomModel>> streamChatRooms({
    String? userId,
    String? role,
  }) {
    try {
      final where = <String, dynamic>{};
      if (userId != null && role != null) {
        if (role == 'admin') {
          where['admin_id'] = userId;
        } else {
          where['penghuni_id'] = userId;
        }
      }
      
      return FirebaseService.streamDocuments(
        AppConfig.chatCollection,
        orderBy: 'updatedAt',
        descending: true,
        where: where.isNotEmpty ? where : null,
      ).map((docs) {
        return docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Gagal streaming chat rooms: ${e.toString()}');
    }
  }
}

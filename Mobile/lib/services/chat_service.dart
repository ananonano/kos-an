import '../core/services/firebase_service.dart';
import '../core/config/app_config.dart';
import '../models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      // Check if chat room already exists using Firestore query
      final existingRooms = await FirebaseFirestore.instance
          .collection(AppConfig.chatCollection)
          .where('penghuni_id', isEqualTo: penghuniId)
          .where('admin_id', isEqualTo: adminId)
          .limit(1)
          .get();
      
      if (existingRooms.docs.isNotEmpty) {
        return existingRooms.docs.first.id;
      }
      
      // Create new chat room directly using Firestore
      final chatRoomRef = FirebaseFirestore.instance
          .collection(AppConfig.chatCollection)
          .doc(); // Auto-generate ID
      
      final data = {
        'id': chatRoomRef.id,
        'penghuni_id': penghuniId,
        'admin_id': adminId,
        'last_message': null,
        'last_message_time': null,
        'unread_count': 0,
        'penghuni_name': penghuniName,
        'admin_name': adminName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await chatRoomRef.set(data);
      
      return chatRoomRef.id;
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
      print('📤 [ChatService] Sending message...');
      print('  Chat Room ID: $chatRoomId');
      print('  Sender ID: $senderId');
      print('  Message: $message');
      
      // Get reference to chat room
      final chatRoomRef = FirebaseFirestore.instance
          .collection(AppConfig.chatCollection)
          .doc(chatRoomId);
      
      // Get reference to messages subcollection
      final messagesRef = chatRoomRef.collection('messages');
      
      print('📍 [ChatService] Messages path: ${AppConfig.chatCollection}/$chatRoomId/messages');
      
      // Add message to subcollection
      final messageData = {
        'chat_room_id': chatRoomId,
        'sender_id': senderId,
        'message': message,
        'image_url': imageUrl,
        'sender_name': senderName,
        'sender_role': senderRole,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      print('📦 [ChatService] Adding message to subcollection...');
      final docRef = await messagesRef.add(messageData);
      print('✅ [ChatService] Message added with ID: ${docRef.id}');
      
      // Update message with its ID
      await messagesRef.doc(docRef.id).update({'id': docRef.id});
      print('✅ [ChatService] Message ID updated');
      
      // Update chat room last message
      await chatRoomRef.update({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Don't increment unread_count for now (can be improved later)
      });
      
      print('✅ [ChatService] Chat room updated');
      print('🎉 [ChatService] Message sent successfully!');
    } catch (e) {
      print('❌ [ChatService] Error sending message: $e');
      throw Exception('Gagal mengirim pesan: ${e.toString()}');
    }
  }
  
  // Stream Messages
  static Stream<List<ChatMessageModel>> streamMessages(String chatRoomId) {
    try {
      return FirebaseFirestore.instance
          .collection(AppConfig.chatCollection)
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = {'id': doc.id, ...doc.data()};
          return ChatMessageModel.fromFirestore(data);
        }).toList();
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
      Query query = FirebaseFirestore.instance
          .collection(AppConfig.chatCollection);
      
      if (userId != null && role != null) {
        if (role == 'admin') {
          query = query.where('admin_id', isEqualTo: userId);
        } else {
          // For tenant, query by penghuni_id (tenant_id from tenants table)
          query = query.where('penghuni_id', isEqualTo: userId);
        }
      }
      
      query = query.orderBy('updatedAt', descending: true);
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = {'id': doc.id, ...doc.data() as Map<String, dynamic>};
          return ChatRoomModel.fromFirestore(data);
        }).toList();
      });
    } catch (e) {
      throw Exception('Gagal streaming chat rooms: ${e.toString()}');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/helpers.dart';
import '../../models/chat_model.dart';
import '../../widgets/app_drawer.dart';

/// Chat List View - Tenant Only
/// Tampilan daftar chat room untuk tenant dengan admin kos
class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final chatController = context.watch<ChatController>();
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leadingWidth: 70,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFFA23900), size: 24),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        title: const Text(
          'Kos Terpadu',
          style: TextStyle(
            color: Color(0xFFA23900),
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(27, 37, 27, 0),
        child: _buildTenantChatList(chatController, user),
      ),
      floatingActionButton: _buildNewChatFAB(context, chatController, user),
    );
  }

  // Tenant Chat List - Show chat with admin only
  Widget _buildTenantChatList(ChatController chatController, user) {
    final userId = user?.id;
    
    return StreamBuilder<List<ChatRoomModel>>(
      stream: chatController.streamChatRooms(userId: userId, role: 'tenant'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan', style: AppTheme.bodyText1),
          );
        }
        
        final chatRooms = snapshot.data ?? [];
        
        if (chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Belum ada percakapan',
                  style: AppTheme.bodyText1.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.separated(
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => const SizedBox(height: 19),
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            
            return _buildChatCard(
              name: chatRoom.adminName ?? 'Admin',
              lastMessage: chatRoom.lastMessage ?? 'Belum ada pesan',
              time: chatRoom.lastMessageTime != null 
                  ? Helpers.formatTime(chatRoom.lastMessageTime!) 
                  : '',
              hasUnread: chatRoom.unreadCount > 0,
              photoUrl: null,
              isAdminChat: true,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.chatRoom,
                  arguments: {
                    'chatRoomId': chatRoom.id,
                    'recipientName': chatRoom.adminName,
                    'recipientId': chatRoom.adminId,
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Chat Card Widget
  Widget _buildChatCard({
    required String name,
    required String lastMessage,
    required String time,
    required bool hasUnread,
    String? photoUrl,
    bool isAdminChat = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFFFFF8F0) : const Color(0xFFFAF9F6),
          border: Border.all(width: 1, color: const Color(0xFFE8DED2)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(17),
            topRight: Radius.circular(11),
            bottomLeft: Radius.circular(17),
            bottomRight: Radius.circular(11),
          ),
          boxShadow: hasUnread ? [
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Left border for unread
            if (hasUnread)
              Positioned(
                left: -19,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA23900),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar - Always show "AK" for admin
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA23900),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'AK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 19),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFFA23900),
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              time.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xB258423A),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.55,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (hasUnread)
                            const Text(
                              'New: ',
                              style: TextStyle(
                                color: Color(0xFFA23900),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              lastMessage,
                              style: TextStyle(
                                color: const Color(0xFF58423A),
                                fontSize: 15,
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Unread indicator dot
            if (hasUnread)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA23900),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // FAB - New Chat Button
  Widget _buildNewChatFAB(BuildContext context, ChatController chatController, user) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 27),
      decoration: BoxDecoration(
        color: const Color(0xFFA23900),
        borderRadius: BorderRadius.circular(11),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () => _onNewChatPressed(context, chatController, user),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 11),
            Text(
              'New Chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle New Chat Button Press
  Future<void> _onNewChatPressed(BuildContext context, ChatController chatController, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? adminId;
      String adminName = 'Admin';
      
      // Try to find existing admin from previous chats
      final existingChats = await FirebaseFirestore.instance
          .collection(AppConfig.chatCollection)
          .where('penghuni_id', isEqualTo: user?.id)
          .limit(1)
          .get();
      
      if (existingChats.docs.isNotEmpty) {
        final chatData = existingChats.docs.first.data();
        adminId = chatData['admin_id'];
        adminName = chatData['admin_name'] ?? 'Admin';
      } else {
        // No existing chat, find any admin from other chats
        final anyAdminChat = await FirebaseFirestore.instance
            .collection(AppConfig.chatCollection)
            .where('admin_id', isNotEqualTo: 'admin')
            .limit(1)
            .get();
        
        if (anyAdminChat.docs.isNotEmpty) {
          final chatData = anyAdminChat.docs.first.data();
          adminId = chatData['admin_id'];
          adminName = chatData['admin_name'] ?? 'Admin';
        }
      }
      
      adminId ??= 'admin';
      
      final penghuniId = user?.id ?? '';
      final penghuniName = user?.nama ?? 'Penghuni';
      
      final chatRoomId = await chatController.createOrGetChatRoom(
        penghuniId: penghuniId,
        adminId: adminId,
        penghuniName: penghuniName,
        adminName: adminName,
      );
      
      if (context.mounted) {
        Navigator.pop(context);
        
        if (chatRoomId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.chatRoom,
            arguments: {
              'chatRoomId': chatRoomId,
              'recipientName': adminName,
              'recipientId': adminId,
            },
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

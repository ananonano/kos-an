import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/chat_model.dart';

/// Chat List View
/// Tampilan daftar chat room (realtime)
class ChatListView extends StatelessWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final chatController = context.watch<ChatController>();
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatController.streamChatRooms(
          userId: user?.id,
          role: user?.role,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: AppTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
          
          final chatRooms = snapshot.data ?? [];
          
          if (chatRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada percakapan',
                    style: AppTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final isAdmin = user?.role == 'admin';
              final recipientName = isAdmin 
                  ? chatRoom.penghuniName 
                  : chatRoom.adminName;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  recipientName ?? 'Unknown',
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  chatRoom.lastMessage ?? 'Belum ada pesan',
                  style: AppTheme.bodyText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chatRoom.lastMessageTime != null)
                      Text(
                        Helpers.formatTime(chatRoom.lastMessageTime!),
                        style: AppTheme.caption,
                      ),
                    if (chatRoom.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chatRoom.unreadCount}',
                          style: AppTheme.caption.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatRoom,
                    arguments: {
                      'chatRoomId': chatRoom.id,
                      'recipientName': recipientName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

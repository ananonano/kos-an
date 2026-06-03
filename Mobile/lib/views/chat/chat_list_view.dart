import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/tenant_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/helpers.dart';
import '../../models/chat_model.dart';
import '../../models/penghuni_model.dart';
import '../../widgets/app_drawer.dart';

/// Chat List View
/// Tampilan daftar chat room (realtime) dengan hamburger menu
class ChatListView extends StatefulWidget {
  const ChatListView({super.key});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<PenghuniModel> _allTenants = [];
  bool _isLoadingTenants = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    final authController = context.read<AuthController>();
    if (!authController.isAdmin) return;

    setState(() {
      _isLoadingTenants = true;
    });

    try {
      final tenantController = context.read<TenantController>();
      await tenantController.getAllTenants(status: 'aktif');
      setState(() {
        _allTenants = tenantController.tenantList;
        _isLoadingTenants = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTenants = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final chatController = context.watch<ChatController>();
    final user = authController.currentUser;
    final isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: isAdmin ? 'Cari penghuni...' : 'Cari chat...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: isAdmin ? _buildAdminChatList(chatController, user) : _buildTenantChatList(chatController, user),
      floatingActionButton: !isAdmin ? _buildTenantFAB(context, chatController, user) : null,
    );
  }

  // Admin: Show list of all tenants to select and chat
  Widget _buildAdminChatList(ChatController chatController, user) {
    if (_isLoadingTenants) {
      return const Center(child: CircularProgressIndicator());
    }

    var filteredTenants = _allTenants;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTenants = filteredTenants.where((tenant) {
        return tenant.nama.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (filteredTenants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty 
                  ? Icons.people_outline 
                  : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'Belum ada penghuni aktif' 
                  : 'Tidak ada hasil',
              style: AppTheme.bodyText1,
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<ChatRoomModel>>(
      stream: chatController.streamChatRooms(
        userId: user?.id,
        role: user?.role,
      ),
      builder: (context, snapshot) {
        final existingChatRooms = snapshot.data ?? [];
        
        return ListView.separated(
          itemCount: filteredTenants.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tenant = filteredTenants[index];
            
            // Find existing chat room for this tenant
            final existingRoom = existingChatRooms.where((room) => 
              room.penghuniId == tenant.id
            ).firstOrNull;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      _getInitials(tenant.nama),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      tenant.nama,
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (existingRoom?.lastMessageTime != null)
                    Text(
                      Helpers.formatTime(existingRoom!.lastMessageTime!),
                      style: AppTheme.caption.copyWith(fontSize: 11),
                    ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      existingRoom?.lastMessage ?? 'Mulai percakapan',
                      style: AppTheme.bodyText2.copyWith(
                        color: (existingRoom?.unreadCount ?? 0) > 0 
                            ? Colors.black87 
                            : Colors.grey,
                        fontWeight: (existingRoom?.unreadCount ?? 0) > 0 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if ((existingRoom?.unreadCount ?? 0) > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${existingRoom!.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () async {
                // Create or get chat room using user_id for both
                final penghuniUserId = tenant.userId;
                if (penghuniUserId == null) return;
                
                final chatRoomId = await chatController.createOrGetChatRoom(
                  penghuniId: penghuniUserId, // Use user_id for consistency
                  adminId: user?.id ?? '',
                  penghuniName: tenant.nama,
                  adminName: user?.nama ?? 'Admin',
                );
                
                if (chatRoomId != null && context.mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.chatRoom,
                    arguments: {
                      'chatRoomId': chatRoomId,
                      'recipientName': tenant.nama,
                      'recipientId': penghuniUserId,
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Tenant: Show existing chat rooms with admin
  Widget _buildTenantChatList(ChatController chatController, user) {
    // Use user_id directly (simplified approach)
    final userId = user?.id;
    
    return StreamBuilder<List<ChatRoomModel>>(
      stream: chatController.streamChatRooms(
        userId: userId,
        role: 'tenant', // Always use 'tenant' role for query
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                const Text(
                  'Terjadi kesalahan',
                  style: AppTheme.bodyText1,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: AppTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        var chatRooms = snapshot.data ?? [];
        
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          chatRooms = chatRooms.where((room) {
            return room.adminName?.toLowerCase().contains(_searchQuery) ?? false;
          }).toList();
        }
        
        if (chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty 
                      ? Icons.chat_bubble_outline 
                      : Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty 
                      ? 'Belum ada percakapan' 
                      : 'Tidak ada hasil',
                  style: AppTheme.bodyText1,
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan tombol + untuk chat dengan admin',
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }
        
        return ListView.separated(
          itemCount: chatRooms.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      _getInitials(chatRoom.adminName ?? 'A'),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Online indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      chatRoom.adminName ?? 'Admin',
                      style: AppTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chatRoom.lastMessageTime != null)
                    Text(
                      Helpers.formatTime(chatRoom.lastMessageTime!),
                      style: AppTheme.caption.copyWith(fontSize: 11),
                    ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      chatRoom.lastMessage ?? 'Belum ada pesan',
                      style: AppTheme.bodyText2.copyWith(
                        color: chatRoom.unreadCount > 0 
                            ? Colors.black87 
                            : Colors.grey,
                        fontWeight: chatRoom.unreadCount > 0 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chatRoom.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${chatRoom.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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

  // FAB for tenant to start chat with admin
  Widget _buildTenantFAB(BuildContext context, ChatController chatController, user) {
    return FloatingActionButton(
      onPressed: () async {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Try to find existing admin from any chat room
          String? adminId;
          String adminName = 'Admin';
          
          // Check if there's any existing chat room with an admin
          final existingChats = await FirebaseFirestore.instance
              .collection(AppConfig.chatCollection)
              .where('penghuni_id', isEqualTo: user?.id)
              .limit(1)
              .get();
          
          if (existingChats.docs.isNotEmpty) {
            // Use existing admin_id from previous chat
            final chatData = existingChats.docs.first.data();
            adminId = chatData['admin_id'];
            adminName = chatData['admin_name'] ?? 'Admin';
          } else {
            // No existing chat, try to find any admin from other chats
            final anyAdminChat = await FirebaseFirestore.instance
                .collection(AppConfig.chatCollection)
                .where('admin_id', isNotEqualTo: 'admin') // Not placeholder
                .limit(1)
                .get();
            
            if (anyAdminChat.docs.isNotEmpty) {
              final chatData = anyAdminChat.docs.first.data();
              adminId = chatData['admin_id'];
              adminName = chatData['admin_name'] ?? 'Admin';
            }
          }
          
          // If still no admin found, use placeholder
          adminId ??= 'admin';
          
          // For tenant, use user_id as penghuni_id
          final penghuniId = user?.id ?? '';
          final penghuniName = user?.nama ?? 'Penghuni';
          
          // Create or get chat room with admin
          final chatRoomId = await chatController.createOrGetChatRoom(
            penghuniId: penghuniId,
            adminId: adminId,
            penghuniName: penghuniName,
            adminName: adminName,
          );
          
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            
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
            Navigator.pop(context); // Close loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: const Icon(Icons.add),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

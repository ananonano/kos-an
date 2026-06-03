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
        child: isAdmin 
            ? _buildAdminChatListNew(chatController, user) 
            : _buildTenantChatListNew(chatController, user),
      ),
      floatingActionButton: !isAdmin ? _buildNewChatFAB(context, chatController, user) : null,
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
    return '${parts[0]}${parts[1][0]}'.toUpperCase();
  }

  // NEW DESIGN - Admin Chat List
  Widget _buildAdminChatListNew(ChatController chatController, user) {
    if (_isLoadingTenants) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTenants = _allTenants;

    if (filteredTenants.isEmpty) {
      return Center(
        child: Text(
          'Belum ada penghuni aktif',
          style: AppTheme.bodyText1.copyWith(color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<List<ChatRoomModel>>(
      stream: chatController.streamChatRooms(userId: user?.id, role: user?.role),
      builder: (context, snapshot) {
        final existingChatRooms = snapshot.data ?? [];
        
        return ListView.separated(
          itemCount: filteredTenants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 19),
          itemBuilder: (context, index) {
            final tenant = filteredTenants[index];
            final existingRoom = existingChatRooms.where((room) => 
              room.penghuniId == tenant.id
            ).firstOrNull;
            
            final hasUnread = (existingRoom?.unreadCount ?? 0) > 0;
            
            return _buildChatCard(
              name: tenant.nama,
              lastMessage: existingRoom?.lastMessage ?? 'Mulai percakapan',
              time: existingRoom?.lastMessageTime != null 
                  ? Helpers.formatTime(existingRoom!.lastMessageTime!) 
                  : '',
              hasUnread: hasUnread,
              photoUrl: null,
              onTap: () async {
                final penghuniUserId = tenant.userId;
                if (penghuniUserId == null) return;
                
                final chatRoomId = await chatController.createOrGetChatRoom(
                  penghuniId: penghuniUserId,
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

  // NEW DESIGN - Tenant Chat List
  Widget _buildTenantChatListNew(ChatController chatController, user) {
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

  // NEW DESIGN - Chat Card Widget
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
                  decoration: BoxDecoration(
                    color: isAdminChat ? const Color(0xFFA23900) : const Color(0xFFA23900),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar (Always show initials, no photo)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isAdminChat ? const Color(0xFFA23900) : const Color(0xFFF8BD45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isAdminChat ? 'AK' : _getInitials(name),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isAdminChat ? Colors.white : const Color(0xFF271900),
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
                              style: TextStyle(
                                color: isAdminChat ? const Color(0xFFA23900) : const Color(0xFF1A1C1A),
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

  // NEW FAB Design
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
          children: [
            const Icon(Icons.add, color: Colors.white),
            const SizedBox(width: 11),
            const Text(
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

  Future<void> _onNewChatPressed(BuildContext context, ChatController chatController, user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String? adminId;
      String adminName = 'Admin';
      
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
          SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

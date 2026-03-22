/**
 * C端 - 消息会话列表页
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/im_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class _ConversationItem {
  final int conversationId;
  final int agentId;
  final int? houseId;
  final String lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;

  _ConversationItem({
    required this.conversationId,
    required this.agentId,
    this.houseId,
    required this.lastMessagePreview,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory _ConversationItem.fromJson(Map<String, dynamic> json) {
    DateTime? lastAt;
    final rawAt = json['last_message_at'];
    if (rawAt is String && rawAt.isNotEmpty) {
      try {
        lastAt = DateTime.parse(rawAt).toLocal();
      } catch (_) {}
    }

    return _ConversationItem(
      conversationId: json['conversation_id'] as int? ?? 0,
      agentId: json['agent_id'] as int? ?? 0,
      houseId: json['house_id'] as int?,
      lastMessagePreview:
          json['last_message_preview'] as String? ?? '',
      lastMessageAt: lastAt,
      unreadCount: json['user_unread_count'] as int? ?? 0,
    );
  }
}

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  late final ImApi _imApi;
  List<_ConversationItem> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _imApi = ImApi(DioClient.instance);
    _loadConversations();
  }

  String? get _token => ref.read(authProvider).user?.token;

  Future<void> _loadConversations() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final result = await _imApi.getConversations(
        userType: 'buyer',
        token: token,
      );

      final data = result['data'];
      List<dynamic> rawList = [];
      if (data is Map) {
        rawList = (data['list'] as List?) ?? [];
      } else if (data is List) {
        rawList = data;
      }

      final items = rawList
          .map((e) =>
              _ConversationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _conversations = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ChatListPage _loadConversations error: $e');
      Fluttertoast.showToast(
        msg: '消息列表加载失败',
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[dt.weekday];
    } else {
      return '${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        title: Text(
          l.message,
          style: const TextStyle(
            color: AppColors.gray800,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _loadConversations();
              },
              child: _conversations.isEmpty
                  ? _buildEmptyState()
                  : _buildConversationList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context);
    return ListView(
      // ListView is needed so RefreshIndicator works with empty state
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray300),
              const SizedBox(height: 16),
              Text(
                l.noData,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '联系经纪人后，消息将显示在这里',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConversationList() {
    return ListView.separated(
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final item = _conversations[index];
        return _buildConversationTile(item);
      },
    );
  }

  Widget _buildConversationTile(_ConversationItem item) {
    final initials = 'A${item.agentId}';

    return InkWell(
      onTap: () {
        context.push(
          '/buyer/chat/${item.agentId}',
          extra: {
            'conversationId': item.conversationId,
            'agentId': item.agentId,
          },
        );
      },
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 头像
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.unreadCount > 99
                            ? '99+'
                            : '${item.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 会话信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '经纪人 ${item.agentId}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray800,
                        ),
                      ),
                      Text(
                        _formatTime(item.lastMessageAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.lastMessagePreview.isEmpty
                        ? '暂无消息'
                        : item.lastMessagePreview,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.unreadCount > 0
                          ? AppColors.gray700
                          : AppColors.gray400,
                      fontWeight: item.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

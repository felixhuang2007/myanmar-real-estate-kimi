/**
 * C端 - IM聊天页
 */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/im_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class ChatPage extends ConsumerStatefulWidget {
  /// targetId is the string-form agent or conversation identifier (used in route params)
  final String targetId;

  /// agentId: numeric agent ID used to get-or-create the conversation.
  /// If conversationId is supplied directly, agentId is not needed.
  final int? agentId;

  /// conversationId: pre-known conversation ID (e.g. from agent side).
  final int? conversationId;

  const ChatPage({
    super.key,
    required this.targetId,
    this.agentId,
    this.conversationId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _showEmojiPicker = false;
  bool _showMoreMenu = false;
  bool _isLoading = true;
  bool _isSending = false;

  int? _conversationId;
  Timer? _pollTimer;

  late final ImApi _imApi;

  @override
  void initState() {
    super.initState();
    _imApi = ImApi(DioClient.instance);
    _conversationId = widget.conversationId;
    _initialize();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? get _token => ref.read(authProvider).user?.token;

  Future<void> _initialize() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      _showError('未登录，请重新登录');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Step 1: get or create conversation if we don't already have a conversationId
      if (_conversationId == null) {
        final agentId = widget.agentId ?? int.tryParse(widget.targetId) ?? 0;
        final result = await _imApi.getOrCreateConversation(
          agentId: agentId,
          token: token,
        );
        final data = result['data'] as Map<String, dynamic>?;
        _conversationId = data?['conversation_id'] as int? ??
            data?['id'] as int?;
      }

      if (_conversationId == null) {
        _showError('连接失败，无法建立会话');
        setState(() => _isLoading = false);
        return;
      }

      // Step 2: load message history
      await _loadMessages();

      // Step 3: mark conversation as read
      _markAsRead();

      // Step 4: start polling every 5 seconds
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) _loadMessages(silent: true);
      });
    } catch (e) {
      _showError('连接失败，请稍后重试');
      debugPrint('ChatPage _initialize error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final token = _token;
    final convId = _conversationId;
    if (token == null || convId == null) return;

    try {
      final result = await _imApi.getMessages(
        conversationId: convId,
        token: token,
        limit: 50,
      );

      final data = result['data'];
      List<dynamic> rawList = [];
      if (data is Map) {
        rawList = (data['list'] as List?) ?? (data['messages'] as List?) ?? [];
      } else if (data is List) {
        rawList = data;
      }

      final currentUserId = ref.read(authProvider).user?.userId;

      final messages = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        final senderId = m['sender_id'];
        final senderType = m['sender_type'] as String? ?? '';
        // "buyer" sender_type means the current user sent it
        final isMe = senderType == 'buyer' ||
            (currentUserId != null && senderId == currentUserId);

        return ChatMessage(
          id: m['message_id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          content: m['content'] as String? ?? '',
          isMe: isMe,
          timestamp: _parseTime(m['sent_at']),
          type: _parseMessageType(m['message_type'] as String? ?? 'text'),
        );
      }).toList();

      if (mounted) {
        setState(() => _messages
          ..clear()
          ..addAll(messages));
        _scrollToBottom();
      }
    } catch (e) {
      if (!silent) {
        _showError('消息加载失败');
      }
      debugPrint('ChatPage _loadMessages error: $e');
    }
  }

  Future<void> _markAsRead() async {
    final token = _token;
    final convId = _conversationId;
    if (token == null || convId == null) return;
    try {
      await _imApi.markAsRead(conversationId: convId, token: token);
    } catch (e) {
      debugPrint('ChatPage _markAsRead error: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final token = _token;
    final convId = _conversationId;
    if (token == null || convId == null) {
      _showError('连接失败，无法发送消息');
      return;
    }

    // Optimistically add to UI
    final optimisticMsg = ChatMessage(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      content: text,
      isMe: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    setState(() {
      _messages.add(optimisticMsg);
      _messageController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      await _imApi.sendMessage(
        conversationId: convId,
        messageType: 'text',
        content: text,
        token: token,
      );
      // Refresh messages to get server-assigned ID
      await _loadMessages(silent: true);
    } catch (e) {
      _showError('消息发送失败');
      debugPrint('ChatPage _sendMessage error: $e');
      // Remove optimistic message on failure
      if (mounted) {
        setState(() => _messages.removeWhere((m) => m.id == optimisticMsg.id));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  DateTime _parseTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  MessageType _parseMessageType(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'house':
        return MessageType.house;
      case 'voice':
        return MessageType.voice;
      default:
        return MessageType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 房源卡片提示
          _buildHouseCard(context),

          // 消息列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(),
          ),

          // 输入区域
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
      ),
      title: Column(
        children: [
          Text(
            '经纪人',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '在线',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.green500,
                ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.phone, color: AppColors.gray700),
        ),
      ],
    );
  }

  Widget _buildHouseCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.gray200,
              child: const Icon(Icons.home, color: AppColors.gray400),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '仰光Tamwe区精装3室公寓',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '12,000万缅币',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('查看'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noData,
          style: const TextStyle(color: AppColors.gray400),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary100,
              child: Text(
                '经',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:
                    message.isMe ? AppColors.primary700 : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(message.isMe ? 12 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 12),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color:
                      message.isMe ? AppColors.white : AppColors.gray800,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.gray200,
              child:
                  const Icon(Icons.person, size: 16, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                // 语音按钮
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.keyboard_voice, color: AppColors.gray600),
                ),

                // 输入框
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '输入消息...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),

                // 表情按钮
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                      _showMoreMenu = false;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppColors.gray600,
                  ),
                ),

                // 更多按钮
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMoreMenu = !_showMoreMenu;
                      _showEmojiPicker = false;
                    });
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.gray600,
                  ),
                ),

                // 发送按钮
                if (_messageController.text.isNotEmpty)
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary700,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: AppColors.white,
                              size: 20,
                            ),
                    ),
                  ),
              ],
            ),

            // 更多菜单
            if (_showMoreMenu)
              Container(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    _buildMoreButton(Icons.image, '相册', () {}),
                    _buildMoreButton(Icons.camera_alt, '拍摄', () {}),
                    _buildMoreButton(Icons.location_on, AppLocalizations.of(context).location, () {}),
                    _buildMoreButton(Icons.home, '房源', () {}),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(
      IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.gray700),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MessageType {
  text,
  image,
  house,
  voice,
}

class ChatMessage {
  final String id;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
    required this.type,
  });
}

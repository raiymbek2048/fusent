import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:intl/intl.dart';

class ChatConversationPage extends StatefulWidget {
  final String chatId;
  final String shopName;
  final String? recipientId;

  const ChatConversationPage({
    super.key,
    required this.chatId,
    required this.shopName,
    this.recipientId,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isLoading = false;
  String? _conversationId;
  String? _currentUserId;
  String? _recipientId;  // Store recipient ID for sending messages

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  Future<void> _initializeConversation() async {
    setState(() {
      _isLoading = true;
    });

    // Get current user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.id;
    }

    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║ CHAT INITIALIZATION - ${DateTime.now().toString()}');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║ Current User ID: $_currentUserId');
    debugPrint('║ Widget chatId: ${widget.chatId}');
    debugPrint('║ Widget shopName: ${widget.shopName}');
    debugPrint('║ Widget recipientId: ${widget.recipientId}');
    debugPrint('║ recipientId is null: ${widget.recipientId == null}');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    try {
      // If we have a recipientId, create or get conversation
      if (widget.recipientId != null) {
        debugPrint('→ RecipientId provided, calling createOrGetConversation...');

        // Store recipientId for sending messages
        _recipientId = widget.recipientId;

        final response = await _apiClient.createOrGetConversation(
          recipientId: widget.recipientId!,
        );

        debugPrint('← API Response status: ${response.statusCode}');
        debugPrint('← API Response data: ${response.data}');

        if (response.statusCode == 200) {
          final convData = response.data as Map<String, dynamic>;
          _conversationId = convData['conversationId']?.toString();
          debugPrint('✓ Stored conversation ID: $_conversationId');
        }
      } else {
        // Use the chatId as conversationId
        debugPrint('→ No recipientId, using chatId as conversationId');
        _conversationId = widget.chatId;
        debugPrint('✓ Stored conversation ID: $_conversationId');
      }

      // Load messages
      if (_conversationId != null) {
        debugPrint('→ Loading messages for conversation: $_conversationId');
        await _loadMessages();
      } else {
        debugPrint('✗ Cannot load messages: conversationId is null');
      }
    } catch (e) {
      debugPrint('!!! Error initializing conversation: $e');
      if (e.toString().contains('DioException')) {
        debugPrint('!!! This is a DioException - likely a backend error');
      }

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть чат: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) {
      debugPrint('✗ Cannot load messages: conversationId is null');
      return;
    }

    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║ LOADING MESSAGES');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║ Conversation ID: $_conversationId');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    try {
      final response = await _apiClient.getConversationMessages(_conversationId!);
      debugPrint('← Load messages response status: ${response.statusCode}');

      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> content = data['content'] as List<dynamic>;

        debugPrint('✓ Loaded ${content.length} messages');

        setState(() {
          _messages = content.reversed.map((msg) {
            final msgMap = msg as Map<String, dynamic>;
            final isMine = msgMap['senderId'] == _currentUserId;

            return {
              'id': msgMap['id'],
              'text': msgMap['messageText'] ?? '',
              'isMine': isMine,
              'time': _formatTime(msgMap['createdAt']),
              'status': msgMap['isRead'] == true ? 'read' : 'delivered',
              'senderId': msgMap['senderId'],
            };
          }).toList();
        });

        debugPrint('✓ Messages displayed in UI');

        // Mark unread messages as read
        _markMessagesAsRead();

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      debugPrint('✗ Error loading messages: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      // Find all unread messages that are not mine
      final unreadMessages = _messages
          .where((msg) =>
              !msg['isMine'] &&
              msg['status'] != 'read' &&
              msg['id'] != null)
          .toList();

      if (unreadMessages.isEmpty) {
        debugPrint('✓ No unread messages to mark as read');
        return;
      }

      debugPrint('→ Marking ${unreadMessages.length} messages as read');

      // Mark each unread message as read
      for (final msg in unreadMessages) {
        try {
          final messageId = msg['id'].toString();
          await _apiClient.put(
            '/api/v1/chat/messages/$messageId/read',
            data: {},
          );
          debugPrint('✓ Marked message $messageId as read');

          // Update local state
          setState(() {
            msg['status'] = 'read';
          });
        } catch (e) {
          debugPrint('✗ Failed to mark message ${msg['id']} as read: $e');
        }
      }
    } catch (e) {
      debugPrint('✗ Error in _markMessagesAsRead: $e');
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final DateTime messageTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(messageTime);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _recipientId == null) {
      debugPrint('✗ Cannot send message: text is empty or recipientId is null');
      debugPrint('  MessageText isEmpty: ${_messageController.text.trim().isEmpty}');
      debugPrint('  RecipientId is null: ${_recipientId == null}');
      debugPrint('  RecipientId value: $_recipientId');
      return;
    }

    final messageText = _messageController.text;
    _messageController.clear();

    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║ SENDING MESSAGE');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║ Recipient ID: $_recipientId');
    debugPrint('║ Current Conversation ID: $_conversationId');
    debugPrint('║ Message Text: $messageText');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');

    // Optimistically add message to UI
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _messages.add({
        'id': tempId,
        'text': messageText,
        'isMine': true,
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'status': 'sent',
        'senderId': _currentUserId,
      });
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await _apiClient.sendChatMessage(
        recipientId: _recipientId!,
        messageText: messageText,
      );

      debugPrint('← Send message response status: ${response.statusCode}');

      if (mounted && response.statusCode == 200) {
        final sentMessage = response.data as Map<String, dynamic>;
        debugPrint('✓ Message sent successfully!');
        debugPrint('  Message ID: ${sentMessage['id']}');
        debugPrint('  Conversation ID from response: ${sentMessage['conversationId']}');

        // Update conversation ID to ensure we're viewing the correct conversation
        final newConversationId = sentMessage['conversationId']?.toString();
        if (newConversationId != null && newConversationId != _conversationId) {
          debugPrint('⚠ Updating conversation ID!');
          debugPrint('  OLD: $_conversationId');
          debugPrint('  NEW: $newConversationId');
          _conversationId = newConversationId;
        } else {
          debugPrint('✓ Conversation ID unchanged: $_conversationId');
        }

        // Update the temporary message with real data
        setState(() {
          final index = _messages.indexWhere((m) => m['id'] == tempId);
          if (index != -1) {
            _messages[index] = {
              'id': sentMessage['id'],
              'text': sentMessage['messageText'] ?? messageText,
              'isMine': true,
              'time': _formatTime(sentMessage['createdAt']),
              'status': 'delivered',
              'senderId': sentMessage['senderId'],
            };
          }
        });
      }
    } catch (e) {
      debugPrint('✗ Error sending message: $e');

      // Remove the temporary message on error
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m['id'] == tempId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось отправить сообщение: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surface,
              child: const Icon(
                Icons.person,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.shopName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () {
              // Show chat options
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMine = message['isMine'] as bool;

                      return _buildMessage(
                        text: message['text'] as String,
                        isMine: isMine,
                        time: message['time'] as String,
                        status: isMine ? message['status'] as String? : null,
                      );
                    },
                  ),
                ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attach button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    onPressed: () {
                      // TODO: Attach image/file
                    },
                  ),
                  const SizedBox(width: 8),

                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Сообщение...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required String text,
    required bool isMine,
    required String time,
    String? status,
  }) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMine ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isMine && status != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      status == 'sent'
                          ? Icons.check
                          : status == 'delivered'
                              ? Icons.done_all
                              : Icons.done_all,
                      size: 14,
                      color: status == 'read'
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

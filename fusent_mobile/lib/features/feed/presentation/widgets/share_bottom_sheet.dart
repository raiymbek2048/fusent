import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';

class ShareBottomSheet extends StatefulWidget {
  final String? productId;
  final String? postId;

  const ShareBottomSheet({
    super.key,
    this.productId,
    this.postId,
  }) : assert(productId != null || postId != null, 'Either productId or postId must be provided');

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUsers = {};

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];
  bool _isLoading = false;
  bool _isSending = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.getConversations();

      if (mounted && response.statusCode == 200) {
        final List<dynamic> conversations = response.data as List<dynamic>;

        setState(() {
          _conversations = conversations.map((conv) {
            final convMap = conv as Map<String, dynamic>;
            return {
              'userId': convMap['otherUserId'] as String,
              'userName': convMap['otherUserName'] ?? 'Неизвестный',
              'conversationId': convMap['conversationId'] as String,
            };
          }).toList();
          _filteredConversations = _conversations;
        });
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterConversations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((conv) =>
                (conv['userName'] as String).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  Future<void> _shareToSelectedUsers() async {
    if (_selectedUsers.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      int successCount = 0;
      int failCount = 0;

      for (final userId in _selectedUsers) {
        try {
          final messageData = {
            'recipientId': userId,
            'messageText': widget.productId != null
                ? 'Поделился товаром'
                : 'Поделился публикацией',
            'messageType': widget.productId != null ? 'PRODUCT_SHARE' : 'POST_SHARE',
            if (widget.productId != null) 'sharedProductId': widget.productId,
            if (widget.postId != null) 'sharedPostId': widget.postId,
          };

          final response = await _apiClient.sendMessage(messageData);

          if (response.statusCode == 200) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          debugPrint('Error sharing to user $userId: $e');
          failCount++;
        }
      }

      if (mounted) {
        Navigator.pop(context);

        final message = failCount == 0
            ? 'Отправлено ${successCount} ${_pluralize(successCount, 'пользователю', 'пользователям', 'пользователям')}'
            : 'Отправлено ${successCount}, не удалось отправить ${failCount}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: failCount == 0 ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при отправке'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count % 10 == 1 && count % 100 != 11) {
      return one;
    } else if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    } else {
      return many;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Поделиться',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedUsers.isNotEmpty)
                  TextButton(
                    onPressed: _isSending ? null : _shareToSelectedUsers,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Отправить (${_selectedUsers.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск пользователей...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterConversations('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterConversations,
            ),
          ),

          const SizedBox(height: 16),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final user = _filteredConversations[index];
                          final userId = user['userId'] as String;
                          final isSelected = _selectedUsers.contains(userId);

                          return InkWell(
                            onTap: () => _toggleUserSelection(userId),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.surface,
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // User name
                                  Expanded(
                                    child: Text(
                                      user['userName'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),

                                  // Selection indicator
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.chat_bubble_outline : Icons.search_off,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Нет контактов'
                : 'Ничего не найдено',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Начните переписку с кем-нибудь,\nчтобы делиться контентом'
                : 'Попробуйте изменить запрос',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

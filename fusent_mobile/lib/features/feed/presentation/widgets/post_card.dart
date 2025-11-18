import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class PostCard extends StatefulWidget {
  final String username;
  final String userAvatar;
  final String postImage;
  final String description;
  final int likes;
  final int comments;
  final bool isLiked;
  final String? linkedProductId; // ID привязанного товара
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostCard({
    super.key,
    required this.username,
    required this.userAvatar,
    required this.postImage,
    required this.description,
    required this.likes,
    required this.comments,
    required this.isLiked,
    this.linkedProductId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showProductButton = false;

  @override
  void initState() {
    super.initState();
    // Показать кнопку "Перейти на товар" через 2 секунды, если есть привязанный товар
    if (widget.linkedProductId != null) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showProductButton = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surface,
                  backgroundImage: widget.userAvatar.isNotEmpty ? NetworkImage(widget.userAvatar) : null,
                  child: widget.userAvatar.isEmpty
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        '2 часа назад',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    // TODO: Show post options
                  },
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
            onDoubleTap: widget.onLike,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: AppColors.surface,
                child: widget.postImage.isNotEmpty
                    ? Image.network(
                        widget.postImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked ? Colors.red : AppColors.textPrimary,
                  ),
                  onPressed: widget.onLike,
                ),
                Text(
                  _formatNumber(widget.likes),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: AppColors.textPrimary,
                  onPressed: widget.onComment,
                ),
                Text(
                  _formatNumber(widget.comments),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  color: AppColors.textPrimary,
                  onPressed: widget.onShare,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  color: AppColors.textPrimary,
                  onPressed: widget.onSave,
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: widget.username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(text: widget.description),
                ],
              ),
            ),
          ),

          // Кнопка "Перейти на товар" (показывается через 2 секунды если есть linkedProductId)
          if (_showProductButton && widget.linkedProductId != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/product/${widget.linkedProductId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text(
                    'Перейти на товар',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

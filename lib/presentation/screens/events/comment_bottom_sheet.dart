import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connect_heart/data/models/comment.dart';
import 'package:connect_heart/data/services/event_service.dart';

class CommentBottomSheet extends StatefulWidget {
  final int eventId;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final User userInfo;
  final Function(int) onCommentAdded;
  final bool isEvent;
  final int blogId;

  const CommentBottomSheet({
    super.key,
    required this.eventId,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.userInfo,
    required this.onCommentAdded,
    required this.isEvent,
    required this.blogId,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  List<Comment>? _comments;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // Tải các bình luận từ API
  Future<void> _loadComments() async {
    if (widget.isEvent) {
      try {
        final list = await EventService().fetchCommentsForEvent(widget.eventId);
        setState(() => _comments = list);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bình luận: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      try {
        final list = await BlogService().fetchCommentsForBlog(widget.blogId);
        setState(() => _comments = list);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bình luận blog: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

// Gửi bình luận mới
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (widget.isEvent) {
      try {
        await EventService().createCommentForEvent(
          eventId: widget.eventId,
          content: text,
        );
        final me = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          content: text,
          userName: 'Bạn',
          imageProfile: widget.userInfo.imageProfile ?? '',
          createdAt: DateTime.now(),
          children: [],
        );
        setState(() {
          _comments?.insert(0, me);
          _commentController.clear();
        });

        // Call the callback function to update the comment count
        widget.onCommentAdded(_comments?.length ?? widget.commentCount + 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi bình luận thất bại: $e')),
        );
      }
    } else {
      try {
        await BlogService().createCommentForBlog(
          blogId: widget.blogId,
          content: text,
        );
        final me = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          content: text,
          userName: 'Bạn',
          imageProfile: widget.userInfo.imageProfile ?? '',
          createdAt: DateTime.now(),
          children: [],
        );
        setState(() {
          _comments?.insert(0, me);
          _commentController.clear();
        });

        // Call the callback function to update the comment count
        widget.onCommentAdded(_comments?.length ?? widget.commentCount + 1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi bình luận blog thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        if (_isLoading) {
          return const _FullScreenCommentShimmer();
        }

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Header counts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCount(Icons.favorite, widget.likeCount),
                    _buildCount(Icons.mode_comment_outlined,
                        _comments?.length ?? widget.commentCount),
                    _buildCount(Icons.send, widget.shareCount),
                  ],
                ),
              ),
              const Divider(),

              // Body: comments list
              Expanded(
                child: (_comments == null || _comments!.isEmpty)
                    ? const Center(child: Text('Chưa có bình luận nào.'))
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments?.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = _comments![index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị ảnh đại diện của người bình luận
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: c.imageProfile.isNotEmpty
                                    ? NetworkImage(c.imageProfile)
                                    : const AssetImage('assets/khi_hau.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Check if the comment's userName is the same as the logged-in user's userName
                                    Text(
                                      c.userName == widget.userInfo.userName
                                          ? '@Bạn · ${formatTimeAgo(c.createdAt)}' // Show @Bạn if it's the current user
                                          : '@${c.userName} · ${formatTimeAgo(c.createdAt)}', // Otherwise show the commenter's username
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(c.content),
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
              ),

              // Input bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: const Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Row(
                  children: [
                    // Hiển thị ảnh đại diện người dùng trong phần nhập bình luận
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                          widget.userInfo.imageProfile ??
                              'default_avatar_url'), // Ảnh đại diện người dùng
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendComment,
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Xây dựng count cho số lượt thích, bình luận, chia sẻ
  Widget _buildCount(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Text(count.toString()),
      ],
    );
  }
}

// Shimmer skeleton khi đang load bình luận
class _FullScreenCommentShimmer extends StatelessWidget {
  const _FullScreenCommentShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 5, color: Colors.white),
          const SizedBox(height: 16),

          // counts bar placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 60, height: 16, color: Colors.white),
                Container(width: 60, height: 16, color: Colors.white),
                Container(width: 60, height: 16, color: Colors.white),
              ],
            ),
          ),
          const Divider(),

          // comment list placeholder
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 15,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 120, height: 12, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(
                              width: double.infinity,
                              height: 10,
                              color: Colors.white),
                          const SizedBox(height: 4),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 10,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // input bar placeholder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(height: 36, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Container(width: 36, height: 36, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

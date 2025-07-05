import 'package:flutter/material.dart';
import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/models/comment.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/utils/time_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';

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
    Key? key,
    required this.eventId,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.userInfo,
    required this.onCommentAdded,
    required this.isEvent,
    required this.blogId,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  List<Comment>? _comments;
  bool _isLoading = true;

  // Trả lời
  int? _replyToCommentId;
  String? _replyToUserName;

  // Chỉnh sửa
  int? _editingCommentId;
  String? _originalCommentContent;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final list = widget.isEvent
          ? await EventService().fetchCommentsForEvent(widget.eventId)
          : await BlogService().fetchCommentsForBlog(widget.blogId);
      if (!mounted) return;
      setState(() => _comments = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải bình luận: \$e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      if (_editingCommentId != null) {
        // Cập nhật comment
        Comment updated = widget.isEvent
            ? await EventService().updateComment(
                commentId: _editingCommentId!,
                content: text,
              )
            : await EventService().updateComment(
                commentId: _editingCommentId!,
                content: text,
              );
        setState(() {
          final idx = _comments!.indexWhere((c) => c.id == _editingCommentId);
          if (idx != -1) _comments![idx] = updated;
          _editingCommentId = null;
          _originalCommentContent = null;
          _commentController.clear();
        });
      } else {
        // Tạo comment mới hoặc trả lời
        if (widget.isEvent) {
          await EventService().createCommentForEvent(
            eventId: widget.eventId,
            content: text,
            parent_id: _replyToCommentId,
          );
        } else {
          await BlogService().createCommentForBlog(
            blogId: widget.blogId,
            content: text,
            parent_id: _replyToCommentId,
          );
        }
        final me = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          content: text,
          userName: widget.userInfo.userName,
          imageProfile: widget.userInfo.imageProfile ?? '',
          createdAt: DateTime.now(),
          children: [],
          likeCount: 0,
        );
        setState(() {
          if (_replyToCommentId != null) {
            final parent =
                _comments!.firstWhere((c) => c.id == _replyToCommentId);
            parent.children.insert(0, me);
          } else {
            _comments!.insert(0, me);
          }
          _commentController.clear();
          _replyToCommentId = null;
          _replyToUserName = null;
        });
        widget.onCommentAdded(_comments!.length);
      }
    } on DioError catch (e) {
      if (!mounted) return;
      final detail = e.response?.data['message'] ?? e.message;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Thao tác thất bại: \$detail')));
    }
  }

  void _onReplyTap(Comment comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToUserName = comment.userName;
      _editingCommentId = null;
      _commentController.text = '@${comment.userName} ';
    });
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  void _showCommentOptions(Comment comment, {bool isChild = false}) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trả lời luôn được phép
            if (!isChild)
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Trả lời'),
                onTap: () {
                  Navigator.pop(context);
                  _onReplyTap(comment);
                },
              ),
            // Chỉnh sửa: chỉ khi comment.userName == widget.userInfo.userName
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                if (comment.userName == widget.userInfo.userName) {
                  setState(() {
                    _editingCommentId = comment.id;
                    _replyToCommentId = null;
                    _originalCommentContent = comment.content;
                    _commentController.text = comment.content;
                  });
                  FocusScope.of(context).requestFocus(_commentFocusNode);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Không thể chỉnh sửa bình luận của người khác'),
                    ),
                  );
                }
              },
            ),
            // Xóa: cũng chỉ khi chủ bình luận
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Xóa'),
              onTap: () async {
                Navigator.pop(context);
                if (comment.userName == widget.userInfo.userName) {
                  try {
                    if (widget.isEvent) {
                      await EventService().deleteComment(commentId: comment.id);
                    } else {
                      await EventService().deleteComment(commentId: comment.id);
                    }
                    setState(() {
                      _comments!.removeWhere((c) => c.id == comment.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa bình luận')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xóa thất bại: \$e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể xóa bình luận của người khác'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) {
        if (_isLoading) return const _FullScreenCommentShimmer();
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
              _CountHeader(
                likeCount: widget.likeCount,
                commentCount: _comments?.length ?? widget.commentCount,
                shareCount: widget.shareCount,
              ),
              const Divider(),
              Expanded(
                child: (_comments == null || _comments!.isEmpty)
                    ? const _EmptyState()
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = _comments![index];
                          final isReplying = c.id == _replyToCommentId;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onLongPress: () => _showCommentOptions(c, isChild: false),
                                child: _CommentItem(
                                  comment: c,
                                  isReplying: isReplying,
                                  onReply: () => _onReplyTap(c),
                                ),
                              ),
                              if (c.children.isNotEmpty)
                                ...c.children.map((child) => GestureDetector(
                                      onLongPress: () =>
                                          _showCommentOptions(child, isChild: true),
                                      child: _ReplyItem(comment: child),
                                    )),
                            ],
                          );
                        },
                      ),
              ),
              if (_replyToCommentId != null)
                _ReplyTag(
                  userName: _replyToUserName!,
                  onCancel: () {
                    setState(() {
                      _replyToCommentId = null;
                      _replyToUserName = null;
                      _commentController.clear();
                    });
                  },
                ),
              _InputBar(
                controller: _commentController,
                focusNode: _commentFocusNode,
                avatarUrl: widget.userInfo.imageProfile ?? '',
                onSend: _sendComment,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CountHeader extends StatelessWidget {
  final int likeCount;
  final int commentCount;
  final int shareCount;

  const _CountHeader({
    Key? key,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  }) : super(key: key);

  Widget _buildCount(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        Text(count.toString())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCount(Icons.favorite, likeCount),
          _buildCount(Icons.mode_comment_outlined, commentCount),
          // _buildCount(Icons.send, shareCount),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isReplying;
  final VoidCallback onReply;

  const _CommentItem(
      {Key? key,
      required this.comment,
      required this.isReplying,
      required this.onReply})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: comment.imageProfile.isNotEmpty
              ? NetworkImage(comment.imageProfile)
              : const AssetImage('assets/khi_hau.png') as ImageProvider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      isReplying ? Colors.grey.shade200 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${comment.userName}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(comment.content),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: onReply,
                    child: Text('Trả lời',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: isReplying
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyItem extends StatelessWidget {
  final Comment comment;

  const _ReplyItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: comment.imageProfile.isNotEmpty
                ? NetworkImage(comment.imageProfile)
                : const AssetImage('assets/khi_hau.png') as ImageProvider,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${comment.userName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(comment.content,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTimeAgo(comment.createdAt),
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyTag extends StatelessWidget {
  final String userName;
  final VoidCallback onCancel;

  const _ReplyTag({Key? key, required this.userName, required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('Đang trả lời @$userName')),
          GestureDetector(
              onTap: onCancel, child: const Icon(Icons.close, size: 18)),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String avatarUrl;
  final VoidCallback onSend;

  const _InputBar(
      {Key? key,
      required this.controller,
      required this.focusNode,
      required this.avatarUrl,
      required this.onSend})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          border: const Border(top: BorderSide(color: Colors.grey))),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24)),
                  isDense: true),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: onSend)
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('Chưa có bình luận nào.\nHãy là người đầu tiên bình luận.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 60, height: 16, color: Colors.white),
                  Container(width: 60, height: 16, color: Colors.white),
                  Container(width: 60, height: 16, color: Colors.white),
                ]),
          ),
          const Divider(),
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
                              color: Colors.white, shape: BoxShape.circle)),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 10,
                                  color: Colors.white),
                            ]),
                      ),
                    ]);
              },
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 36, color: Colors.white)),
                const SizedBox(width: 8),
                Container(width: 36, height: 36, color: Colors.white),
              ])),
        ],
      ),
    );
  }
}

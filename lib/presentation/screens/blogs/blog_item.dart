import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/presentation/screens/blogs/blog_form.dart';
import 'package:connect_heart/presentation/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/presentation/screens/events/comment_bottom_sheet.dart';
import 'package:connect_heart/presentation/screens/events/full_screen_image.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class BlogItem extends ConsumerStatefulWidget {
  final int id;
  final String avatar;
  final String username;
  final String content;
  final String image;
  final int wishlistsCount;
  int commentsCount;
  final bool isMyBlog;
  final Blog? blog;
  final bool is_wishlist;

  BlogItem({
    super.key,
    required this.id,
    required this.avatar,
    required this.username,
    required this.content,
    required this.image,
    required this.wishlistsCount,
    required this.commentsCount,
    required this.isMyBlog,
    required this.blog,
    required this.is_wishlist,
  });

  @override
  ConsumerState<BlogItem> createState() => _BlogItemState();
}

class _BlogItemState extends ConsumerState<BlogItem> {
  bool isLiked = false;
  bool isExpanded = false; // Track if the content is expanded
  bool _isLoadingLike = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.is_wishlist;
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ userProvider
    final user = ref.watch(userProvider);

    // Kiểm tra xem người dùng đã đăng nhập chưa
    if (user == null) {
      return Center(child: Text("Vui lòng đăng nhập để xem thông tin"));
    }

    // Kiểm tra xem hình ảnh có phải là URL hợp lệ hay không
    bool isImageUrl = Uri.tryParse(widget.image)?.isAbsolute ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hiển thị ảnh đại diện của người dùng
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: widget.avatar.isNotEmpty
                          ? NetworkImage(widget.avatar)
                          : const AssetImage('assets/khi_hau.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.username,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: Colors.blue),
                  ],
                ),
                if (widget.isMyBlog)
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () => _showBlogOptions(context, widget.blog!),
                    tooltip: 'Tùy chọn',
                  ),
              ],
            ),
          ),

          // Hiển thị hình ảnh của bài viết
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageViewer(
                      imageUrl: widget.image,
                      isNetwork: isImageUrl,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: widget.image,
                child: isImageUrl
                    ? Image.network(widget.image,
                        fit: BoxFit.cover, width: double.infinity, height: 150)
                    : Image.asset(widget.image,
                        fit: BoxFit.cover, width: double.infinity, height: 150),
              ),
            ),
          ),

          // Content of the blog with dynamic maxLines
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị nội dung bài viết
                Text(
                  widget.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: isExpanded ? null : 2, // Show only 2 lines or all
                  overflow: isExpanded
                      ? null
                      : TextOverflow.ellipsis, // Add ellipsis when collapsed
                ),
                const SizedBox(height: 4),

                // Link "Xem thêm" or "Ẩn bớt"
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded; // Toggle expanded state
                    });
                  },
                  child: Text(
                    isExpanded ? 'Ẩn bớt' : 'Xem thêm',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ),
                const SizedBox(height: 8),

                // Action Buttons: like, comment, share
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isLoadingLike
                          ? null
                          : () async {
                              setState(() {
                                isLiked = !isLiked;
                                _isLoadingLike = true;
                              });
                              try {
                                if (isLiked) {
                                  await BlogService().addToWishlist(
                                      blogId: widget.id); // Thêm vào wishlist
                                } else {
                                  await BlogService().removeWishlistBlog(
                                      widget.id); // Xóa khỏi wishlist
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              } finally {
                                setState(() {
                                  _isLoadingLike = false;
                                });
                              }
                            },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.red : Colors.black,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Hiển thị số lượt thích
                    Text((isLiked
                            ? widget.wishlistsCount + 1
                            : widget.wishlistsCount)
                        .toString()),
                    const SizedBox(width: 16),

                    // Comment button
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          builder: (_) => CommentBottomSheet(
                            likeCount: isLiked
                                ? widget.wishlistsCount + 1
                                : widget.wishlistsCount,
                            commentCount: widget.commentsCount,
                            shareCount: 13,
                            eventId: 0,
                            userInfo: user,
                            onCommentAdded: (newCommentCount) {
                              // Cập nhật số lượng bình luận sau khi thêm
                              setState(() {
                                widget.commentsCount = newCommentCount;
                              });
                            },
                            isEvent: false,
                            blogId: widget.id,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.mode_comment_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.commentsCount.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Share button
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: const Row(
                    //     children: [
                    //       Icon(Icons.send, size: 16),
                    //       SizedBox(width: 4),
                    //       Text('13'),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBlogOptions(BuildContext context, Blog blog) {
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Chỉnh sửa bài viết',
                    style: TextStyle(fontSize: 18)),
                onTap: () async {
                  Navigator.pop(context); // 1) Đóng bottom sheet
                  // 2) Chuyển sang màn edit và đợi kết quả
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BlogFormScreen(isEdit: true, existingBlog: blog),
                    ),
                  );
                  // 3) Nếu edit thành công, làm mới provider
                  if (result == true) {
                    ref.refresh(userBlogsProvider);
                  }
                },
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Xóa bài viết', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(bottomSheetCtx);
                  _showDeleteConfirmationDialog(parentContext, blog.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext parentContext,
    int blogId,
  ) async {
    final bool? confirmed = await confirm(
      parentContext,
      title: Text('Xác nhận xóa bài viết'),
      content: Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
      textCancel: Text('Hủy bỏ'),
      textOK: Text('Xóa bài viết'),
    );

    if (confirmed == true) {
      try {
        await BlogService().deleteBlog(blogId);

        // 1) Refresh lại danh sách
        ref.refresh(userBlogsProvider);

        // 2) Show SnackBar trên Scaffold của ProfileScreen
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('🎉 Xóa bài viết thành công')),
        );
      } catch (e) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    }
  }
}

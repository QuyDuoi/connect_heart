import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/presentation/screens/events/event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/presentation/screens/comment/comment_bottom_sheet.dart';
import 'package:connect_heart/presentation/screens/events/full_screen_image.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class EventItem extends ConsumerStatefulWidget {
  final int id;
  final String avatar;
  final String username;
  final String image;
  final String title;
  final String participants;
  final String field;
  final String form;
  final String date;
  final String location;
  final int wishlistsCount;
  int commentsCount;
  final int registrationsCount;
  final bool is_wishlist;
  bool is_registration;
  final String description;
  final bool isMyEvent;
  final Event? event;
  final String userRole;

  EventItem({
    super.key,
    required this.id,
    required this.avatar,
    required this.username,
    required this.image,
    required this.title,
    required this.participants,
    required this.field,
    required this.form,
    required this.date,
    required this.location,
    required this.wishlistsCount,
    required this.commentsCount,
    required this.registrationsCount,
    required this.is_wishlist,
    required this.is_registration,
    required this.description,
    required this.isMyEvent,
    required this.event,
    required this.userRole,
  });

  @override
  ConsumerState<EventItem> createState() => _EventItemState();
}

class _EventItemState extends ConsumerState<EventItem> {
  late bool isLiked;
  bool _isLoadingLike = false;
  int tappedIndex = -1;
  final EventService _eventService = EventService();
  bool _isDescExpanded = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.is_wishlist;
  }

  Future<void> _handleJoin() async {
    if (widget.is_registration) {
      // Already registered, call API cancel or show message
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đợi BTC xác nhận đăng ký')));
      return;
    }
    if (_isRegistering) return;
    setState(() => _isRegistering = true);
    try {
      await _eventService.thamGiaSuKien(widget.id);
      setState(() {
        widget.is_registration = true;
        // widget.event.registrationsCount++;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Thông tin đăng ký đã được gửi, vui lòng chờ xác nhận.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khi đăng ký: \$e')));
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(userProvider); // Lấy thông tin người dùng từ userProvider

    // Kiểm tra xem người dùng đã đăng nhập hay chưa
    if (user == null) {
      return Center(child: Text("Vui lòng đăng nhập để xem thông tin"));
    }

    // Kiểm tra xem ảnh của sự kiện và avatar có phải là URL hợp lệ hay không
    final bool isAvatarUrl = Uri.tryParse(widget.avatar)?.isAbsolute ?? false;

    final hasImage = widget.image.isNotEmpty &&
        Uri.tryParse(widget.image)?.isAbsolute == true;

    // Định dạng thời gian của sự kiện
    final parsedDate = DateTime.tryParse(widget.date) ?? DateTime.now();
    final formattedDate =
        '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')} - '
        '${parsedDate.day.toString().padLeft(2, '0')}/'
        '${parsedDate.month.toString().padLeft(2, '0')}/'
        '${parsedDate.year}';

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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: isAvatarUrl
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
                if (widget.isMyEvent)
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () =>
                        _showEventOptions(context, widget.id, widget.event!),
                    tooltip: 'Tùy chọn',
                  ),
              ],
            ),
          ),

          // Image
          if (hasImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImageViewer(
                        imageUrl: widget.image,
                        isNetwork: true,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: widget.image,
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 150,
                  ),
                ),
              ),
            ),

          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & participants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title with ellipsis if it exceeds 60% of the available space
                    Expanded(
                      flex:
                          7, // Adjust the flex to make title occupy 60% of the space
                      child: Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow
                            .ellipsis, // Truncate text with ellipsis
                        maxLines: 1, // Ensure the title is a single line
                      ),
                    ),
                    // Participants count, taking up the remaining space (40%)
                    Expanded(
                      flex:
                          3, // Adjust the flex to make participants count occupy 40% of the space
                      child: Text(
                        '${widget.participants} người đăng ký',
                        style: const TextStyle(color: Colors.green),
                        overflow: TextOverflow
                            .ellipsis, // Optional: add ellipsis here if needed
                        maxLines: 1, // Ensure this text stays on a single line
                        textAlign: TextAlign
                            .end, // Align the participants count to the end
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Field & form
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Lĩnh vực: ${widget.field == "1" ? "Y tế" : widget.field == "2" ? "Giáo dục" : widget.field == "3" ? "Cứu hộ" : widget.field == "4" ? "Khí hậu" : widget.field}',
                        style: const TextStyle(color: Colors.blue)),
                    Text(
                      'Hình thức: ${widget.form.toLowerCase() == 'offline' ? 'Offline' : 'Online'}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date & location
                Text('Thời gian: $formattedDate'),
                const SizedBox(height: 4),
                Text('Địa điểm: ${widget.location}'),
                const SizedBox(height: 4),
                _buildDescription(),

                // Footer actions
                Row(
                  children: [
                    // ❤️ Like
                    GestureDetector(
                      onTapDown: (_) => setState(() => tappedIndex = 0),
                      onTapUp: (_) => setState(() => tappedIndex = -1),
                      onTapCancel: () => setState(() => tappedIndex = -1),
                      onTap: _isLoadingLike
                          ? null
                          : () async {
                              setState(() {
                                tappedIndex = -1;
                                _isLoadingLike = true;
                                isLiked =
                                    !isLiked; // Lật lại trạng thái isLiked
                              });

                              try {
                                if (isLiked) {
                                  await _eventService.addToWishlist(
                                      eventId: widget.id); // Gọi API để like
                                } else {
                                  await _eventService.removeFromWishlist(
                                      eventId: widget.id); // Gọi API để unlike
                                }
                              } catch (e) {
                                setState(() {
                                  isLiked =
                                      !isLiked; // Lật lại trạng thái nếu có lỗi
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Thao tác thất bại: $e')),
                                );
                              } finally {
                                setState(() => _isLoadingLike = false);
                              }
                            },
                      child: Opacity(
                        opacity: tappedIndex == 0 ? 0.5 : 1.0,
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isLiked ? Colors.red : Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                                '${widget.wishlistsCount + (isLiked ? 1 : 0)}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 💬 Comment
                    GestureDetector(
                      onTapDown: (_) => setState(() => tappedIndex = 1),
                      onTapCancel: () => setState(() => tappedIndex = -1),
                      onTap: () {
                        setState(() => tappedIndex = 1);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => CommentBottomSheet(
                            likeCount:
                                widget.wishlistsCount + (isLiked ? 1 : 0),
                            commentCount: widget.commentsCount,
                            shareCount: widget.registrationsCount,
                            eventId: widget.id,
                            userInfo:
                                user, // Truyền thông tin người dùng vào bottom sheet
                            onCommentAdded: (newCommentCount) {
                              // Cập nhật số lượng bình luận sau khi thêm
                              setState(() {
                                widget.commentsCount = newCommentCount;
                              });
                            },
                            isEvent: true,
                            blogId: 0,
                          ),
                        ).whenComplete(() => setState(() => tappedIndex = -1));
                      },
                      child: Opacity(
                        opacity: tappedIndex == 1 ? 0.5 : 1.0,
                        child: Row(
                          children: [
                            const Icon(Icons.mode_comment_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.commentsCount.toString()),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Tham gia button
                    ElevatedButton(
                      onPressed: _handleJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(80, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.is_registration ? 'Đã đăng ký' : 'Tham gia',
                        style: TextStyle(
                          color: widget.is_registration
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(BuildContext context, int eventId, Event event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Chỉnh sửa sự kiện',
                    style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EventFormScreen(
                            isEdit: true, existingEvent: event)),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Xóa sự kiện', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, eventId);
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
    int eventId,
  ) {
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon delete
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                // Tiêu đề
                const Text(
                  'Xác nhận xóa sự kiện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Nội dung
                Text(
                  'Bạn có chắc chắn muốn xóa sự kiện này không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Nút Hủy / Xóa
                Row(
                  children: [
                    // Hủy bỏ
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Xóa sự kiện
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // 1) Đóng dialog
                          Navigator.of(dialogContext).pop();
                          // 2) Gọi API xóa sự kiện
                          try {
                            await EventService().deleteEvent(eventId);
                            // 3) Show SnackBar
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Sự kiện đã được xóa'),
                              ),
                            );
                            // 4) Nếu bạn dùng Riverpod / Provider, refresh lại danh sách ở đây
                            //    ref.read(eventsProvider.notifier).refresh();
                          } catch (e) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(content: Text('Lỗi khi xóa: $e')),
                            );
                          }
                        },
                        child: const Text(
                          'Xóa sự kiện',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mô tả: " + widget.description,
          textAlign: TextAlign.justify,
          style: const TextStyle(color: Colors.black87),
          maxLines: _isDescExpanded ? null : 1,
          overflow:
              _isDescExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _isDescExpanded ? 'Ẩn bớt' : 'Xem thêm',
              style: const TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

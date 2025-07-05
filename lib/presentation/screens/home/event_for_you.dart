import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:connect_heart/presentation/screens/events/comment_bottom_sheet.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';

class EventForYouSection extends StatefulWidget {
  const EventForYouSection({super.key});

  @override
  State<EventForYouSection> createState() => _EventForYouSectionState();
}

class _EventForYouSectionState extends State<EventForYouSection> {
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = EventService().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dành cho bạn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Event>>(
            future: futureEvents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 245,
                  child: ShimmerLoader(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Không có sự kiện nào');
              } else {
                final events = snapshot.data!;
                return SizedBox(
                  height: 245,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    padding: const EdgeInsets.only(right: 16),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return EventForYouItem(event: events[index]);
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class EventForYouItem extends ConsumerStatefulWidget {
  final Event event;
  const EventForYouItem({super.key, required this.event});

  @override
  ConsumerState<EventForYouItem> createState() => _EventForYouItemState();
}

class _EventForYouItemState extends ConsumerState<EventForYouItem> {
  late bool isLiked;
  bool _isLoadingLike = false;
  late int commentsCount;

  @override
  void initState() {
    super.initState();
    // Bạn có thể khởi isLiked từ một property nếu có
    isLiked = false;
    commentsCount = widget.event.commentsCount;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return const SizedBox();
    }

    final thumbList = widget.event.thumbnails;
    final imageUrl = thumbList.isNotEmpty ? thumbList.first : null;
    final hasThumb = imageUrl != null && Uri.tryParse(imageUrl)!.isAbsolute;
    final author = widget.event.creator;

    return SizedBox(
      width: 260,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + username
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: author.imageProfile.isNotEmpty &&
                            Uri.tryParse(author.imageProfile)!.isAbsolute
                        ? NetworkImage(author.imageProfile)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    author.userName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 16, color: Colors.blue),
                ],
              ),
            ),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: hasThumb
                  ? Image.network(
                      imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/blog.png', 
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),

            // Actions: like, comment, share
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: [
                  // Like
                  InkWell(
                    onTap: _isLoadingLike
                        ? null
                        : () async {
                            setState(() {
                              _isLoadingLike = true;
                              isLiked = !isLiked;
                            });
                            try {
                              if (isLiked) {
                                await EventService()
                                    .addToWishlist(eventId: widget.event.id);
                              } else {
                                await EventService().removeFromWishlist(
                                    eventId: widget.event.id);
                              }
                            } catch (_) {
                              setState(() => isLiked = !isLiked);
                            } finally {
                              setState(() => _isLoadingLike = false);
                            }
                          },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.event.wishlistsCount + (isLiked ? 1 : 0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Comment
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => CommentBottomSheet(
                          likeCount:
                              widget.event.wishlistsCount + (isLiked ? 1 : 0),
                          commentCount: commentsCount,
                          shareCount: widget.event.registrationsCount,
                          eventId: widget.event.id,
                          userInfo: user,
                          isEvent: true,
                          blogId: 0,
                          onCommentAdded: (newCount) {
                            setState(() => commentsCount = newCount);
                          },
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.mode_comment_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          commentsCount.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Share
                  // const Icon(Icons.send, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

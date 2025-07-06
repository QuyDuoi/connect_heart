import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:connect_heart/data/models/feedback_model.dart';
import 'package:connect_heart/data/services/event_service.dart';

class FeedbackModal extends ConsumerStatefulWidget {
  final int eventId;

  const FeedbackModal({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<FeedbackModal> createState() => _FeedbackModalState();
}

class _FeedbackModalState extends ConsumerState<FeedbackModal> {
  late Future<List<FeedbackModel>> _futureFeedbacks;

  @override
  void initState() {
    super.initState();
    _futureFeedbacks = EventService().fetchFeedbacks(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    // Tính chiều cao tối đa cho modal (70% màn hình)
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Đánh giá sự kiện',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 24, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body: bọc trong Expanded để scroll khi quá dài
            Expanded(
              child: FutureBuilder<List<FeedbackModel>>(
                future: _futureFeedbacks,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    // Shimmer loader
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: 9,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, __) => _buildShimmerItem(),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Lỗi: ${snap.error}'),
                    );
                  }
                  final feedbacks = snap.data!;
                  if (feedbacks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Chưa có đánh giá nào'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: feedbacks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildFeedbackItem(feedbacks[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            color: Colors.white,
            margin: const EdgeInsets.only(right: 12),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 8, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: double.infinity, height: 8, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(FeedbackModel fb) {
    final stars = List<Widget>.generate(5, (i) {
      return Icon(
        i < fb.rating ? Icons.star : Icons.star_border,
        size: 16,
        color: Colors.amber,
      );
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: fb.user.imageProfile.isNotEmpty
              ? NetworkImage(fb.user.imageProfile)
              : null,
          child: fb.user.imageProfile.isEmpty
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fb.user.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...stars,
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  fb.content ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

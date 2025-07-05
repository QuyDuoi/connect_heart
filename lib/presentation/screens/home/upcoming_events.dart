import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';
import 'package:connect_heart/presentation/screens/home/section_upcomming.dart';
import 'package:flutter/material.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  String formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Sắp diễn ra',
            onSeeMore: () {
              // TODO: điều hướng đến danh sách đầy đủ
            },
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Event>>(
            future: EventService().fetchCommingEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerLoader();
              } else if (snapshot.hasError) {
                return const Text('Lỗi khi tải dữ liệu sự kiện');
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Text(
                  'Không có sự kiện nào',
                  style: TextStyle(color: Colors.grey),
                );
              }

              final events = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length > 3 ? 3 : events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: (() {
                              // Lấy đường dẫn ảnh đầu tiên nếu có
                              final thumbList = event.thumbnails;
                              if (thumbList.isNotEmpty) {
                                final url = thumbList.first;
                                final isUrl =
                                    Uri.tryParse(url)?.isAbsolute ?? false;
                                if (isUrl) {
                                  return Image.network(
                                    url,
                                    width: 100,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                }
                              }
                              // Fallback asset nếu không có thumbnail
                              return Image.asset(
                                'assets/event_comming.png',
                                width: 100,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            })(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Thời gian: ${formatDate(event.dateStart)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'Địa điểm: ${event.location}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

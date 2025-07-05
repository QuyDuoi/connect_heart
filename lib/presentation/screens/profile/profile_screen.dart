import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_header.dart';
import 'profile_info.dart';
import 'profile_statistics.dart';
import 'package:connect_heart/presentation/screens/profile/my_blog_list.dart';
import 'package:connect_heart/presentation/screens/profile/my_event_list.dart';

// Create FutureProviders to fetch blogs and events
final userBlogsProvider = FutureProvider<List<Blog>>((ref) async {
  final blogService = BlogService();
  return await blogService.fetchUserBlogs();
});

final userEventsProvider = FutureProvider<List<Event>>((ref) async {
  final eventService = EventService();
  return await eventService.fetchUserEvents();
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when the screen is mounted
    ref.refresh(userBlogsProvider); // Load user blogs
    ref.refresh(userEventsProvider); // Load user events
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final blogsAsyncValue = ref.watch(userBlogsProvider);
    final eventsAsyncValue = ref.watch(userEventsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF8FF),
        body: SafeArea(
          child: Column(
            children: [
              ProfileHeader(), // ProfileHeader
              ProfileInfo(user: user), // ProfileInfo
              const SizedBox(height: 14),
              ProfileStatistics(user: user), // ProfileStatistics
              const SizedBox(height: 14),

              // Nếu là tổ chức thiện nguyện thì show TabBar
              if (user?.role == 'Tổ chức thiện nguyện')
                TabBar(
                  indicatorWeight: 3,
                  indicatorColor: Colors.blue,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Danh sách bài viết'),
                    Tab(text: 'Danh sách sự kiện'),
                  ],
                ),

              // Nội dung chính
              Expanded(
                child: user?.role == 'Tổ chức thiện nguyện'
                    // với 2 Tab
                    ? TabBarView(
                        children: [
                          // Tab 1: Blogs
                          blogsAsyncValue.when(
                            data: (blogs) => MyBlogList(blogs: blogs),
                            loading: () => const ShimmerListLoader(),
                            error: (e, st) => Center(child: Text('Lỗi: $e')),
                          ),
                          // Tab 2: Events
                          eventsAsyncValue.when(
                            data: (events) => MyEventList(events: events),
                            loading: () => const ShimmerListLoader(),
                            error: (e, st) => Center(child: Text('Lỗi: $e')),
                          ),
                        ],
                      )

                    // chỉ Blog list đối với user thường
                    : blogsAsyncValue.when(
                        data: (blogs) => MyBlogList(blogs: blogs),
                        loading: () => const ShimmerListLoader(),
                        error: (e, st) => Center(child: Text('Lỗi: $e')),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/presentation/screens/events/event_item.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';
import 'package:connect_heart/providers/user_provider.dart';

class WishlistEventsScreen extends ConsumerStatefulWidget {
  const WishlistEventsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WishlistEventsScreen> createState() =>
      _WishlistEventsScreenState();
}

class _WishlistEventsScreenState extends ConsumerState<WishlistEventsScreen> {
  late Future<List<Event>> _futureWishlist;

  @override
  void initState() {
    super.initState();
    _futureWishlist = EventService().fetchWishlistEvents();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy user từ Riverpod
    final user = ref.watch(userProvider);
    final role = user?.role ?? 'Tình nguyện viên';
    const baseTextStyle = TextStyle(fontFamily: 'Merriweather');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        title: Text(
          'Sự kiện yêu thích',
          style: baseTextStyle.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FutureBuilder<List<Event>>(
          future: _futureWishlist,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerListLoader();
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Chưa có sự kiện yêu thích nào.'));
            } else {
              final events = snapshot.data!;
              return ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final e = events[index];
                  return EventItem(
                    id: e.id,
                    avatar: e.creator.imageProfile,
                    username: e.creator.userName,
                    image: e.thumbnails.isNotEmpty ? e.thumbnails.first : '',
                    title: e.title,
                    participants: e.registrationsCount.toString(),
                    field: e.category?.categoryName ?? 'Không có thể loại',
                    form: e.type,
                    date: e.dateStart,
                    location: e.location,
                    wishlistsCount: e.wishlistsCount,
                    commentsCount: e.commentsCount,
                    registrationsCount: e.registrationsCount,
                    is_wishlist: e.is_wishlist,
                    is_registration: e.is_registration,
                    description: e.description,
                    isMyEvent: false,
                    event: e,
                    userRole: role,
                    isEvented: false,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

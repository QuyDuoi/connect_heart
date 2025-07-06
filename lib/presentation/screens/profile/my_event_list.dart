import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/presentation/screens/events/event_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyEventList extends ConsumerWidget {
  final List<Event> events;

  const MyEventList({super.key, required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventItem(
          avatar: event.creator.imageProfile,
          username: event.creator.userName,
          image: event.thumbnails.isNotEmpty ? event.thumbnails.first : '',
          title: event.title,
          participants: event.registrationsCount.toString(),
          field: event.category?.categoryName ?? 'Không có thể loại',
          form: event.type,
          date: event.dateStart,
          location: event.location,
          wishlistsCount: event.wishlistsCount,
          commentsCount: event.commentsCount,
          registrationsCount: event.registrationsCount,
          id: event.id,
          description: event.description,
          isMyEvent: true,
          event: event,
          is_wishlist: event.is_wishlist,
          is_registration: event.is_registration,
          userRole: user?.role ?? 'Tình nguyện viên',
          isEvented: false,
        );
      },
    );
  }
}

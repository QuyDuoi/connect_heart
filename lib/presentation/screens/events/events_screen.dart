import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:connect_heart/presentation/screens/events/event_form.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/presentation/screens/events/event_item.dart';
import 'package:connect_heart/presentation/screens/events/event_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  int selectedCategory = 0;
  final List<String> categories = [
    'Tất cả',
    'Nổi bật',
    'Sắp diễn ra',
    'Mới nhất'
  ];

  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _loadEventsByCategory();
  }

  void _loadEventsByCategory() {
    switch (selectedCategory) {
      case 1:
        _futureEvents = EventService().fetchHighlightedEvents();
        break;
      case 2:
        _futureEvents = EventService().fetchCommingEvents();
        break;
      case 3:
        _futureEvents = EventService().fetchNewestEvents();
        break;
      case 0:
      default:
        _futureEvents = EventService().fetchEvents();
    }
  }

  void _searchEvents(String query) {
    if (query.isEmpty) {
      // nếu xóa hết text, về lại fetch bình thường
      _loadEventsByCategory();
      setState(() {});
    } else {
      setState(() {
        _futureEvents = EventService().searchEvents(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventHeader(onSearch: _searchEvents),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          categories.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(categories[index]),
                              selected: selectedCategory == index,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = index;
                                  _loadEventsByCategory();
                                });
                              },
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: selectedCategory == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Danh sách sự kiện',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (user?.role == 'Tổ chức thiện nguyện')
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EventFormScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Thêm mới',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Display events with FutureBuilder
                    FutureBuilder<List<Event>>(
                      future: _futureEvents,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Show shimmer loader while data is loading
                          return const ShimmerListLoader();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Hiện không có sự kiện nào'));
                        } else {
                          // Display the list of events
                          final events = snapshot.data!;
                          return Column(
                            children: events
                                .map(
                                  (event) => EventItem(
                                    avatar: event.creator.imageProfile,
                                    username: event.creator.userName,
                                    image: event.thumbnails.isNotEmpty
                                        ? event.thumbnails.first
                                        : '',
                                    title: event.title,
                                    participants:
                                        event.registrationsCount.toString(),
                                    field: event.category?.categoryName ??
                                        'Không có thể loại',
                                    form: event.type,
                                    date: event.dateStart,
                                    location: event.location,
                                    wishlistsCount: event.wishlistsCount,
                                    commentsCount: event.commentsCount,
                                    registrationsCount:
                                        event.registrationsCount,
                                    id: event.id,
                                    description: event.description,
                                    isMyEvent: false,
                                    event: event,
                                    is_wishlist: event.is_wishlist,
                                    is_registration: event.is_registration,
                                    userRole: user?.role ?? 'Tình nguyện viên',
                                  ),
                                )
                                .toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

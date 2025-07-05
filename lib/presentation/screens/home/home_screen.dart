import 'package:connect_heart/presentation/screens/home/featured_blog.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/presentation/screens/home/upcoming_events.dart';
import 'package:connect_heart/presentation/screens/home/home_banner.dart';
import 'package:connect_heart/presentation/screens/home/home_header.dart';
import 'package:connect_heart/presentation/screens/home/home_menu.dart';
import 'package:connect_heart/presentation/screens/home/event_for_you.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const HomeBanner(),
              const HomeMenu(),
              const UpcomingEventsSection(),
              const EventForYouSection(),
              const FeaturedBlogPost(),
            ],
          ),
        ),
      ),
    );
  }
}

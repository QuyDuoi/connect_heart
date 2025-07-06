import 'package:connect_heart/presentation/screens/activity/registered_events_screen%20.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_blogs_screen.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_events_screen.dart';
import 'package:connect_heart/presentation/screens/blogs/blog_form.dart';
import 'package:connect_heart/presentation/screens/events/event_form.dart';
import 'package:connect_heart/presentation/screens/settings/change_password_screen.dart';
import 'package:connect_heart/presentation/screens/profile/setting_screen.dart';
import 'package:connect_heart/presentation/screens/settings/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/signup/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/events/events_screen.dart';
import '../presentation/screens/blogs/blogs_screen.dart';
import '../presentation/screens/certificate/certificate_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      // 🟢 Route public
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/update-profile',
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/form-event',
        builder: (context, state) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/wishlist-events',
        builder: (context, state) => const WishlistEventsScreen(),
      ),
      GoRoute(
        path: '/wishlist-blogs',
        builder: (context, state) => const WishlistBlogsScreen(),
      ),
      GoRoute(
        path: '/form-blog',
        builder: (context, state) => const BlogFormScreen(),
      ),
      GoRoute(
        path: '/event_submit',
        builder: (context, state) => const RegisteredEventsScreen(),
      ),

      // 🔵 Shell route dùng MainScaffold chứa BottomNav
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/blogs',
            builder: (context, state) => const BlogsScreen(),
          ),
          GoRoute(
            path: '/certificate',
            builder: (context, state) => const CertificateScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

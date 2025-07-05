import 'package:flutter/material.dart';
import 'package:connect_heart/presentation/widgets/user_greeting.dart';
import 'package:connect_heart/presentation/screens/profile/setting_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const UserGreeting(),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

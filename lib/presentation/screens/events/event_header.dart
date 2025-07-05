import 'package:connect_heart/presentation/widgets/user_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/providers/user_provider.dart';

class EventHeader extends ConsumerWidget {
  const EventHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const UserGreeting(),
          const Spacer(),
          Row(
            children: const [
              Icon(Icons.search, size: 24),
              SizedBox(width: 16),
              Icon(Icons.filter_alt_outlined, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

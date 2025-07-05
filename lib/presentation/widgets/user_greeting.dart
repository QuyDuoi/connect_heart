import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/providers/user_provider.dart';

class UserGreeting extends ConsumerWidget {
  const UserGreeting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logo.png',
          height: 40,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xin chào',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

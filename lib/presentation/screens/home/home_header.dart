import 'package:connect_heart/presentation/widgets/user_greeting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_heart/providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + lời chào
          const UserGreeting(),

          // Search field + button
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextField(
          //         style: const TextStyle(fontSize: 16),
          //         decoration: InputDecoration(
          //           isDense: true,
          //           prefixIcon: const Icon(Icons.search),
          //           hintText: 'Search for Events...',
          //           hintStyle: const TextStyle(fontWeight: FontWeight.w500),
          //           contentPadding: const EdgeInsets.symmetric(
          //               horizontal: 16, vertical: 18),
          //           border: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(12),
          //             borderSide: const BorderSide(color: Colors.purple),
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     SizedBox(
          //       height: 56,
          //       child: ElevatedButton(
          //         onPressed: () {},
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: const Color(0xFF002F6C),
          //           minimumSize: const Size(100, 56),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(16),
          //           ),
          //         ),
          //         child: const Text(
          //           'Search',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 16,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

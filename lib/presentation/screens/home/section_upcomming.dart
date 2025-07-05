import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeMore;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          InkWell(
            onTap: onSeeMore,
            child: const Text(
              'Xem thêm...',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 40,
              width: 200,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerListLoader extends StatelessWidget {
  const ShimmerListLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerLoader(),
        ShimmerLoader(),
        ShimmerLoader(),
      ],
    );
  }
}

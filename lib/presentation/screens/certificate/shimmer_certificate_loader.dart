import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCertificateLoader extends StatelessWidget {
  const ShimmerCertificateLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => _buildShimmerItem(context)),
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: 180,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 16,
              width: 140,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

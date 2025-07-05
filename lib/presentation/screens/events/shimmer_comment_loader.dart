import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCommentLoader extends StatelessWidget {
  const ShimmerCommentLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tạo 5 dòng placeholder
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // name + content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 120,
                      height: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // content line 1
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: double.infinity,
                      height: 10,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // content line 2
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

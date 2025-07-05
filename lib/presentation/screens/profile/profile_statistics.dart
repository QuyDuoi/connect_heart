import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileStatistics extends ConsumerStatefulWidget {
  final User? user;
  const ProfileStatistics({super.key, this.user});

  @override
  ConsumerState<ProfileStatistics> createState() => _ProfileStatisticsState();
}

class _ProfileStatisticsState extends ConsumerState<ProfileStatistics> {
  late Future<Map<String, dynamic>> statisticsFuture;

  @override
  void initState() {
    super.initState();
    statisticsFuture = AuthService().fetchProfileStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: statisticsFuture,
        builder: (context, snapshot) {
          // Hiển thị số 0 khi đang chờ dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (widget.user?.role == 'Tình nguyện viên') ...[
                  _buildStatBox('0', 'Bài viết', Colors.amber.shade200),
                  _buildStatBox('0', 'Lượt thích', Colors.amber.shade300),
                ] else ...[
                  _buildStatBox('0', 'Sự kiện', Colors.blue.shade200),
                  _buildStatBox('0', 'Bài viết', Colors.amber.shade200),
                  _buildStatBox('0', 'Lượt thích', Colors.amber.shade300),
                ],
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('Không có dữ liệu');
          }

          final stats = snapshot.data!;
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (widget.user?.role == 'Tình nguyện viên') ...[
                  _buildStatBox(stats['total_blogs'].toString(), 'Bài viết',
                      Colors.amber.shade200),
                  _buildStatBox(stats['total_likes'].toString(), 'Lượt thích',
                      Colors.amber.shade300),
                ] else ...[
                  _buildStatBox(stats['total_events'].toString(), 'Sự kiện',
                      Colors.blue.shade200),
                  _buildStatBox(stats['total_blogs'].toString(), 'Bài viết',
                      Colors.amber.shade200),
                  _buildStatBox(stats['total_likes'].toString(), 'Lượt thích',
                      Colors.amber.shade300),
                ],
              ]);
        },
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

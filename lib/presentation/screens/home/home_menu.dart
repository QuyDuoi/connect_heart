import 'package:flutter/material.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': 'assets/y_te.png', 'label': 'Y tế'},
      {'icon': 'assets/giao_duc.png', 'label': 'Giáo dục'},
      {'icon': 'assets/cuu_ho.png', 'label': 'Cứu hộ'},
      {'icon': 'assets/khi_hau.png', 'label': 'Khí hậu'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return SizedBox(
            width: 80, // 👈 Điều chỉnh độ rộng ngang từng item tại đây
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Navigation xử lý sau
                },
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.blue.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset(item['icon']!, width: 48, height: 48),
                      const SizedBox(height: 8),
                      Text(
                        item['label']!,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

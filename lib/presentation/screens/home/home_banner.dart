import 'package:flutter/material.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Margin ngang
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh nền
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/banner.png',
                fit: BoxFit.cover,
              ),
            ),

            // Lớp overlay làm mờ ảnh
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Căn lề text bên trong ảnh
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'TOGETHER WE CAN MAKE A DIFFERENCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Every child matters. Every bit helps.\nTogether, we can do wonders to help children in need',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16), // Tạo khoảng cách phía dưới trước button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Join now', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

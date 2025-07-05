import 'package:connect_heart/data/services/auth_service.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_blogs_screen.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_events_screen.dart';
import 'package:connect_heart/presentation/screens/login/login_screen.dart';
import 'package:connect_heart/presentation/screens/settings/change_password_screen.dart';
import 'package:connect_heart/presentation/screens/settings/update_profile_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const baseTextStyle = TextStyle(fontFamily: 'Merriweather');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Ngăn không cho quay lại màn hình trước
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: Text(
          'Cài đặt và hoạt động',
          style: baseTextStyle.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildItem(
            icon: Icons.pin_drop,
            text: 'Đổi mật khẩu',
            style: baseTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),
          _buildItem(
            icon: Icons.shield_outlined,
            text: 'Cập nhật thông tin tài khoản',
            style: baseTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdateProfileScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hoạt động',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Merriweather',
              ),
            ),
          ),
          _buildItem(
            icon: Icons.favorite_border,
            text: 'Bài viết yêu thích',
            style: baseTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistBlogsScreen()),
              );
            },
          ),
          _buildItem(
            icon: Icons.thumb_up_alt_outlined,
            text: 'Sự kiện yêu thích',
            style: baseTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistEventsScreen()),
              );
            },
          ),
          _buildItem(
              icon: Icons.event_available_outlined,
              text: 'Sự kiện đã đăng ký',
              style: baseTextStyle),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // Hiển thị modal đăng xuất
                _showLogoutConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('Đăng xuất', style: baseTextStyle),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String text,
    required TextStyle style,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(text, style: style),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Confirmation Dialog for Logout
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy bỏ'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Đăng xuất'),
              onPressed: () async {
                // Gọi hàm đăng xuất
                final result = await AuthService.logout();

                result.fold(
                  (error) => print('Lỗi đăng xuất: $error'),
                  (_) {
                    // Nếu đăng xuất thành công, chuyển tới màn hình đăng nhập
                    Navigator.of(context).pop(); // Close the dialog first

                    // Chờ cho đến khi frame được xây dựng xong, sau đó chuyển hướng
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    });
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

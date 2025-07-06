import 'package:connect_heart/data/services/auth_service.dart';
import 'package:connect_heart/presentation/screens/activity/registered_events_screen%20.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_blogs_screen.dart';
import 'package:connect_heart/presentation/screens/activity/wishlist_events_screen.dart';
import 'package:connect_heart/presentation/screens/settings/change_password_screen.dart';
import 'package:connect_heart/presentation/screens/settings/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            // Quay về màn hình gốc, không giữ route cũ
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
            style: baseTextStyle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisteredEventsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('Đăng xuất', style: baseTextStyle),
            ),
          ),
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

  Future<void> _showLogoutConfirmationDialog(BuildContext parentContext) {
    return showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon logout tròn nền hồng nhạt (giao diện code trên)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Xác nhận đăng xuất',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Nội dung
                Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Hủy bỏ
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // chỉ đóng dialog
                        },
                        child: const Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Đăng xuất
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          // 1) Đóng dialog
                          Navigator.of(dialogContext).pop();
                          // 2) Gọi API logout
                          final result = await AuthService.logout();
                          result.fold(
                            (error) {
                              debugPrint('Lỗi đăng xuất: $error');
                              // TODO: show SnackBar nếu cần
                            },
                            (_) {
                              // 3) Dùng GoRouter để quay về /login, xóa sạch stack
                              parentContext.go('/login');
                            },
                          );
                        },
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:connect_heart/data/services/auth_service.dart';
import 'package:connect_heart/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect_heart/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInfo extends ConsumerWidget {
  final User? user;

  const ProfileInfo({super.key, required this.user});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();

    // Show the bottom sheet with the options
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      isScrollControlled:
          true, // Ensures the sheet adjusts its height based on content
      builder: (context) => Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Allows the height to be adjusted based on content
          children: [
            ListTile(
              onTap: () async {
                final pickedImage =
                    await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, pickedImage);
              },
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centering the Row content
                children: const [
                  Icon(Icons.camera_alt, size: 24), // Camera icon
                  SizedBox(width: 10), // Spacing between icon and text
                  Text('Chụp ảnh từ Camera'), // Text for camera option
                ],
              ),
            ),
            const Divider(), // Horizontal divider between items
            ListTile(
              onTap: () async {
                final pickedImage =
                    await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, pickedImage);
              },
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centering the Row content
                children: const [
                  Icon(Icons.image, size: 24), // Image gallery icon
                  SizedBox(width: 10), // Spacing between icon and text
                  Text('Chọn ảnh từ Thư viện'), // Text for gallery option
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (pickedFile != null) {
      // After selecting the image, upload it
      _uploadProfileImage(context, ref, pickedFile.path);
    }
  }

  Future<void> _uploadProfileImage(
      BuildContext context, WidgetRef ref, String imagePath) async {
    try {
      // Gọi API để cập nhật ảnh đại diện
      final result = await AuthService.updateProfileImage(imagePath: imagePath);

      // Nếu API thành công, chúng ta cần load lại thông tin người dùng với ảnh mới
      result.fold(
        (failure) => print('Lỗi: $failure'), // Xử lý lỗi
        (success) async {
          print('Cập nhật ảnh thành công');
          await AuthService
              .init(); // Khởi tạo lại AuthService sau khi cập nhật ảnh

          // Lưu thông tin người dùng mới vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final userJson = jsonEncode(
              success); // Lưu đối tượng user mới vào SharedPreferences
          await prefs.setString('user_data', userJson);

          // Cập nhật lại thông tin người dùng trong state
          await ref.read(userProvider.notifier).setUser(success);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Cập nhật ảnh thành công')),
          );
        },
      );
    } catch (e) {
      print('Lỗi cập nhật ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Stack(
          children: [
            // Add a Key to force image reload when updated
            CircleAvatar(
              radius: 48,
              key: ValueKey(user
                  ?.imageProfile), // This forces a reload whenever the imageProfile changes
              backgroundImage: user?.imageProfile != null
                  ? NetworkImage(user!.imageProfile!)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider<Object>,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: GestureDetector(
                  onTap: () {
                    _pickImage(context, ref); // Pass ref here
                  },
                  child: Image.asset(
                    'assets/edit_avatar.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${user?.lastName} ${user?.firstName ?? ''}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Text('Tổ chức từ thiện'),
      ],
    );
  }
}

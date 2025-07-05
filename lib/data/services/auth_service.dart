import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/services/certificate_service.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final Dio _dio = Dio();

  /// Khởi tạo interceptor gắn token vào header + log token
  static Future<void> init() async {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔐 Token đính kèm: $token');
        } else {
          print('⚠️ Không có token');
        }
        handler.next(options);
      },
    ));

    // Thêm log toàn bộ request/response để debug
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Đăng ký
  static Future<Either<String, void>> registerUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String? gender,
    required DateTime? dob,
    required String password,
  }) async {
    final data = {
      "user_name": username,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone_number": phone.replaceAll(' ', ''),
      "date_of_birth": dob?.toIso8601String().split('T').first,
      "gender": gender == 'Nam'
          ? 'male'
          : gender == 'Nữ'
              ? 'female'
              : 'other',
      "address": address,
      "password": password,
      "password_confirmation": password,
      "roles": [4],
    };

    try {
      final res = await _dio.post(
        'http://98.84.150.185:8000/api/connect-heart/auth/users',
        data: data,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return right(null);
      } else {
        return left('Lỗi server: ${res.statusMessage}');
      }
    } catch (e) {
      return left('Đăng ký thất bại: $e');
    }
  }

  /// Đăng nhập
  static Future<Either<String, String>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    await init();
    final data = {
      "email_or_phone_number": emailOrPhone,
      "password": password,
    };

    try {
      final res = await _dio.post(
        'http://98.84.150.185:8000/api/connect-heart/auth/login',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = res.data['response']?['token']?['token'];
        if (token is String) {
          await _saveToken(token);

          final userJson = res.data['response']?['token']?['user'];
          if (userJson == null) return left('Không có thông tin người dùng.');

          final user = User.fromJson(userJson);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(user.toJson()));

          await init();
          return right(token);
        } else {
          return left('Không nhận được token từ server.');
        }
      } else {
        return left('Sai thông tin đăng nhập.');
      }
    } on DioException catch (e) {
      final resp = e.response;
      if (resp?.data != null) {
        final data = resp!.data;
        final msg = (data is Map && data['message'] != null)
            ? data['message']
            : data.toString();
        // log thêm nếu muốn
        print('🔥 SERVER MESSAGE: $msg');
        return left('Đăng nhập thất bại: $msg');
      }
      return left('Lỗi mạng hoặc không có phản hồi từ server');
    } catch (e) {
      return left('Lỗi đăng nhập: $e');
    }
  }

  /// Gọi profile (ví dụ dùng token)
  static Future<Either<String, dynamic>> getProfile() async {
    try {
      final res = await _dio
          .get('http://98.84.150.185:8000/api/connect-heart/user/profile');
      if (res.statusCode == 200) {
        return right(res.data);
      } else {
        return left('Lấy profile thất bại');
      }
    } catch (e) {
      return left('Lỗi gọi API: $e');
    }
  }

  /// Đăng xuất
  static Future<Either<String, void>> logout() async {
    final token = await _getToken();
    if (token == null) return left('Token không tồn tại');

    try {
      final res = await _dio.post(
        'http://98.84.150.185:8000/api/connect-heart/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await _clearToken();
        return right(null);
      } else {
        return left('Lỗi đăng xuất: ${res.statusMessage}');
      }
    } catch (e) {
      return left('Lỗi đăng xuất: $e');
    }
  }

  /// Đổi mật khẩu
  static Future<Either<String, void>> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.patch(
        'http://98.84.150.185:8000/api/connect-heart/auth/reset-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return right(null);
      } else {
        return left('Lỗi server: ${res.statusMessage}');
      }
    } on DioException catch (e) {
      return left(e.response?.data.toString() ?? 'Lỗi không xác định');
    } catch (e) {
      return left('Lỗi đổi mật khẩu: $e');
    }
  }

  /// Cập nhật ảnh đại diện
  static Future<Either<String, User>> updateProfileImage({
    required String imagePath, // Đường dẫn ảnh cần cập nhật
  }) async {
    final token = await _getToken();
    if (token == null) return left('Token không tồn tại');

    FormData formData = FormData.fromMap({
      'imageProfile': await MultipartFile.fromFile(
          imagePath), // Tạo MultipartFile từ file đường dẫn
    });

    try {
      final res = await _dio.post(
        'http://98.84.150.185:8000/api/connect-heart/auth/image-profile',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Assuming that the response contains the updated user data
        final updatedUser = User.fromJson(
            res.data['user']); // Parse the user data from the response

        return right(updatedUser); // Return the updated user data
      } else {
        return left('Lỗi server: ${res.statusMessage}');
      }
    } catch (e) {
      return left('Lỗi cập nhật ảnh: $e');
    }
  }

  // Hàm lấy thông tin chi tiết người dùng
  Future<Map<String, dynamic>> fetchProfileStatistics() async {
    try {
      final token = await AuthService._getToken(); // Lấy token từ SharedPreferences
      if (token == null) throw Exception('Token không tồn tại');

      final response = await dio.get(
        'http://98.84.150.185:8000/api/connect-heart/auth/detail-user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Trả về thông tin thống kê từ API
        final data = response.data['response']; // Dữ liệu thống kê
        return {
          'total_events': data['total_events'] ?? 0,
          'total_blogs': data['total_blogs'] ?? 0,
          'total_likes': data['total_likes'] ?? 0,
        };
      } else {
        throw Exception('Lỗi khi lấy thống kê: ${response.statusMessage}');
      }
    } catch (e) {
      print('Lỗi fetchProfileStatistics: $e');
      rethrow;
    }
  }

  /// Lưu token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Lấy token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Xóa token
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Getter để dùng ngoài class
  static Dio get dioInstance => _dio;
}

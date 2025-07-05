import 'dart:io';

import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/models/comment.dart';
import 'package:connect_heart/data/services/auth_service.dart';
import 'package:dio/dio.dart';

class BlogService {
  final Dio dio = AuthService.dioInstance;

  // URL gốc lấy blog
  static const String _baseUrl =
      'http://98.84.150.185:8000/api/connect-heart/organization/blogs';

  // URL tạo wishlist-blog
  static const String _wishlistCreateUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/wishlist/create-wishlist-blog';

  // URL lấy danh sách wishlist-blog
  static const String _wishlistListUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/wishlist/list-wishlist-blog';

  // URL tạo bình luận cho blog
  static const String _createCommentUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/comment/create-comment-blog';

  // URL lấy danh sách bình luận cho blog
  static const String _listCommentsUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/comment/list-comment-blog';

  /// Lấy tất cả bài viết
  Future<List<Blog>> fetchBlogs() async {
    try {
      final response = await dio.get(
        _baseUrl,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );
      final data = response.data;

      if (data != null &&
          data['response'] != null &&
          data['response']['blog'] != null &&
          data['response']['blog']['data'] != null) {
        final list = data['response']['blog']['data'] as List<dynamic>;
        return list
            .map((json) => Blog.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Lỗi: dữ liệu blog không hợp lệ');
      }
    } catch (e) {
      print('Lỗi fetchBlogs: $e');
      rethrow;
    }
  }

  /// Lấy danh sách bài viết yêu thích
  Future<List<Blog>> fetchWishlistBlogs() async {
    try {
      final response = await dio.get(
        _wishlistListUrl,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );
      final data = response.data;

      if (data != null &&
          data['response'] != null &&
          data['response']['blogs'] != null) {
        final list = data['response']['blogs'] as List<dynamic>?;
        if (list != null) {
          return list
              .map((json) => Blog.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Lỗi: Danh sách blog rỗng hoặc không hợp lệ');
        }
      } else {
        throw Exception('Lỗi: Dữ liệu blog không hợp lệ');
      }
    } catch (e) {
      print('Lỗi fetchWishlistBlogs: $e');
      rethrow;
    }
  }

  /// Thêm bài viết vào wishlist
  Future<void> addToWishlist({required int blogId}) async {
    try {
      final response = await dio.post(
        _wishlistCreateUrl,
        data: {'blog_id': blogId},
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Thêm blog vào yêu thích thành công');
      } else {
        throw Exception(
            'Lỗi thêm blog vào yêu thích: ${response.data['message'] ?? 'Không rõ nguyên nhân'}');
      }
    } catch (e) {
      print('❌ Lỗi addToWishlistBlog: $e');
      rethrow;
    }
  }

  Future<void> removeWishlistBlog(int blogId) async {
    try {
      final response = await dio.delete(
        'http://98.84.150.185:8000/api/connect-heart/client/wishlist/delete-wishlist-blog/$blogId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer YOUR_TOKEN', // Đảm bảo bạn thêm token hợp lệ
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Blog đã được xóa khỏi danh sách yêu thích');
      } else {
        throw Exception('Lỗi: ${response.data['message']}');
      }
    } catch (e) {
      print('Lỗi khi xóa blog yêu thích: $e');
      rethrow;
    }
  }

  /// Lấy danh sách bình luận của blog
  Future<List<Comment>> fetchCommentsForBlog(int blogId) async {
    final resp = await dio.get(
      '$_listCommentsUrl/$blogId', // ← gắn blogId vào path
      options: Options(
        headers: {'Accept': 'application/json'},
        contentType: 'application/json',
      ),
    );

    if (resp.statusCode != 200) {
      throw Exception('Lỗi tải comment: HTTP ${resp.statusCode}');
    }

    final data = resp.data;
    if (data == null || data['response'] == null || data['response'] is! List) {
      throw Exception('Dữ liệu comment không hợp lệ');
    }

    return (data['response'] as List<dynamic>)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Thêm bình luận vào blog
  Future<void> createCommentForBlog(
      {required int blogId, required String content, int? parent_id}) async {
    try {
      final response = await dio.post(
        _createCommentUrl,
        data: {
          'blog_id': blogId,
          'content': content,
          if (parent_id != null) 'parent_id': parent_id,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Tạo bình luận thành công');
      } else {
        throw Exception(
            'Lỗi tạo bình luận: ${response.data['message'] ?? 'Không rõ nguyên nhân'}');
      }
    } catch (e) {
      print('❌ Lỗi createCommentForBlog: $e');
      rethrow;
    }
  }

  /// Lấy danh sách blog của người dùng
  Future<List<Blog>> fetchUserBlogs() async {
    try {
      final response = await dio.get(
          'http://98.84.150.185:8000/api/connect-heart/organization/my-blog');
      final data = response.data;

      // 1) Lấy thẳng mảng
      final rawList = data['response'];
      if (rawList is! List) {
        throw Exception('Dữ liệu trả về không phải List');
      }

      // 2) Map mỗi phần tử (Map<String,dynamic>) thành Event
      return rawList
          .map((e) => Blog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi fetchUserBlogs: $e');
      rethrow;
    }
  }

  // Create new blog
  Future<void> createBlog({
    required String content,
    required List<File> images, // List of images to upload
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        'files[]': await Future.wait(images.map(
          (image) async => await MultipartFile.fromFile(image.path),
        )),
      });

      final response = await dio.post(
        'http://98.84.150.185:8000/api/connect-heart/organization/blogs',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Blog created successfully');
      } else {
        throw Exception('Error creating blog: ${response.data['message']}');
      }
    } catch (e) {
      print('❌ Error creating blog: $e');
      rethrow;
    }
  }

  // Update existing blog
  Future<void> updateBlog({
    required int blogId,
    required String content,
  }) async {
    try {
      // Chỉ cần truyền nội dung dưới dạng JSON
      final data = {
        'content': content,
      };

      print('Updating blog with content: $content');

      final response = await dio.patch(
        'http://98.84.150.185:8000/api/connect-heart/organization/blogs/$blogId',
        data: data, // Truyền data dưới dạng JSON
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json', // Dùng JSON thay vì multipart
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Blog updated successfully');
      } else {
        throw Exception('Error updating blog: ${response.data['message']}');
      }
    } catch (e) {
      print('❌ Error updating blog: $e');
      rethrow;
    }
  }

  Future<void> deleteBlog(int blogId) async {
    try {
      final response = await Dio().delete(
        'http://98.84.150.185:8000/api/connect-heart/organization/blogs/$blogId',
      );

      if (response.statusCode == 200) {
        print("Bài viết đã được xóa thành công.");
        // Bạn có thể gọi hàm để reload lại danh sách blog ở đây nếu cần
      } else {
        print("Lỗi: ${response.data['message']}");
      }
    } catch (e) {
      print("Đã xảy ra lỗi khi xóa bài viết: $e");
    }
  }
}

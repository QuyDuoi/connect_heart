import 'dart:io';
import 'package:connect_heart/data/models/comment.dart';
import 'package:dio/dio.dart';
import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/auth_service.dart';

class EventService {
  final Dio dio = AuthService.dioInstance;

  final String baseUrl =
      'http://98.84.150.185:8000/api/connect-heart/organization/events';
  final String wishlistListUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/wishlist/list-wishlist-event';
  final String wishlistCreateUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/wishlist/create-wishlist-event';
  static const String _wishlistDeleteUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/wishlist/delete-wishlist-event';
  static const String _commentListUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/comment/list-comment-event';

  Future<List<Event>> fetchEvents() async {
    try {
      final response = await dio.get(baseUrl);
      final data = response.data;

      if (data != null &&
          data['response'] != null &&
          data['response']['events'] != null) {
        return (data['response']['events']['data'] as List)
            .map((eventData) => Event.fromJson(eventData))
            .toList();
      } else {
        throw Exception('Lỗi: Dữ liệu không hợp lệ');
      }
    } catch (e) {
      print('Lỗi fetchEvents: $e');
      rethrow;
    }
  }

  Future<List<Event>> fetchCommingEvents() async {
    try {
      final response = await dio.get('$baseUrl?sort=date_start-asc-30days');
      final data = response.data;

      if (data != null &&
          data['response'] != null &&
          data['response']['events'] != null) {
        return (data['response']['events']['data'] as List)
            .map((eventData) => Event.fromJson(eventData))
            .toList();
      } else {
        throw Exception('Lỗi: Dữ liệu không hợp lệ');
      }
    } catch (e) {
      print('Lỗi fetchCommingEvents: $e');
      rethrow;
    }
  }

  static const String _baseUrl =
      'http://98.84.150.185:8000/api/connect-heart/organization/events';
  static const String _uploadThumbnailsUrl =
      'http://98.84.150.185:8000/api/connect-heart/client/thumbnail/upload-images';

  /// Tạo event và trả về object Event (có id mới)
  Future<Event> createEvent({
    required String title,
    String? description,
    required String location,
    required DateTime dateStart,
    DateTime? dateEnd,
    required int categoryId,
    required String type,
    required bool certificateIsTrue,
    File? certificateFile,
    int roleId = 1,
  }) async {
    final body = {
      'title': title,
      'description': description ?? '',
      'location': location,
      'date_start': dateStart.toIso8601String(),
      if (dateEnd != null) 'date_end': dateEnd.toIso8601String(),
      'category_id': categoryId,
      'type': type.toLowerCase(),
      'status': 'active',
      'certificate_is_true': certificateIsTrue,
      'role_id': roleId,
    };

    final response = await dio.post(
      _baseUrl,
      data: body,
      options: Options(
        headers: {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = response.data['response'] as Map<String, dynamic>;
      return Event.fromJson(json);
    } else {
      throw Exception(
        'Lỗi khi tạo sự kiện: ${response.data['message'] ?? response.statusMessage}',
      );
    }
  }

  /// Upload nhiều ảnh thumbnail cho event
  Future<void> uploadThumbnails({
    required int eventId,
    required List<File> images,
  }) async {
    final form = FormData();

    // Thêm event_id
    form.fields.add(MapEntry('event_id', eventId.toString()));

    // Thêm từng file vào files[]
    for (var img in images) {
      form.files.add(MapEntry(
        'files[]',
        await MultipartFile.fromFile(
          img.path,
          filename: img.path.split('/').last,
        ),
      ));
    }

    final response = await dio.post(
      _uploadThumbnailsUrl,
      data: form,
      options: Options(
        headers: {'Accept': 'application/json'},
        contentType: 'multipart/form-data',
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Lỗi upload ảnh: ${response.data['message'] ?? response.statusMessage}',
      );
    }
  }
  
  Future<void> createCommentForEvent({
    required int eventId,
    required String content,
  }) async {
    try {
      final response = await dio.post(
        'http://98.84.150.185:8000/api/connect-heart/client/comment/create-comment-event',
        data: {
          'event_id': eventId,
          'content': content,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Lỗi tạo bình luận: ${response.data['message'] ?? 'Không rõ nguyên nhân'}');
      }

      print('✅ Bình luận thành công');
    } catch (e) {
      print('❌ Lỗi createCommentForEvent: $e');
      rethrow;
    }
  }

  /// Thêm event vào wishlist (yêu thích)
  Future<void> addToWishlist({required int eventId}) async {
    try {
      final response = await dio.post(
        wishlistCreateUrl,
        data: {
          'event_id': eventId,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Thêm vào yêu thích thành công');
      } else {
        throw Exception(
            'Lỗi thêm vào yêu thích: ${response.data['message'] ?? 'Không rõ nguyên nhân'}');
      }
    } catch (e) {
      print('❌ Lỗi addToWishlist: $e');
      rethrow;
    }
  }

  Future<List<Event>> fetchWishlistEvents() async {
    try {
      final resp = await dio.get(wishlistListUrl,
          options: Options(
            headers: {'Accept': 'application/json'},
            contentType: 'application/json',
          ));
      final data = resp.data;

      // Lấy trực tiếp List từ 'events'
      final List<dynamic> list = data['response']['events'] as List<dynamic>;

      return list
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi fetchWishlistEvents: $e');
      rethrow;
    }
  }

  /// Bỏ yêu thích (unlike)
  Future<void> removeFromWishlist({required int eventId}) async {
    final resp = await dio.delete(
      '$_wishlistDeleteUrl/$eventId',
      options: Options(headers: {'Accept': 'application/json'}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Lỗi xóa wishlist: ${resp.data['message']}');
    }
  }

  /// Lấy danh sách bình luận của một event
  Future<List<Comment>> fetchCommentsForEvent(int eventId) async {
    final resp = await dio.get(
      '$_commentListUrl/$eventId', // ← gắn eventId vào path
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

  /// Fetch the list of events for the current user
  Future<List<Event>> fetchUserEvents() async {
    try {
      final response = await dio.get(
          'http://98.84.150.185:8000/api/connect-heart/organization/my-event');
      final data = response.data;

      // 1) Lấy thẳng mảng
      final rawList = data['response'];
      if (rawList is! List) {
        throw Exception('Dữ liệu trả về không phải List');
      }

      // 2) Map mỗi phần tử (Map<String,dynamic>) thành Event
      return rawList
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Lỗi fetchUserEvents: $e');
      rethrow;
    }
  }

  // Delete event API method
  Future<void> deleteEvent(int eventId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/$eventId',
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Lỗi khi xóa sự kiện: ${response.data['message'] ?? 'Không rõ nguyên nhân'}');
      }
    } catch (e) {
      print('Lỗi deleteEvent: $e');
      rethrow;
    }
  }
}

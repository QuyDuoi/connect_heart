import 'dart:io';
import 'package:connect_heart/data/models/comment.dart';
import 'package:connect_heart/data/models/user.dart';
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

  /// Lấy danh sách event nổi bật
  Future<List<Event>> fetchHighlightedEvents() async {
    try {
      final response = await dio.get('$baseUrl?filter=highlighted');
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
      print('Lỗi fetchHighlightedEvents: $e');
      rethrow;
    }
  }

  /// Lấy danh sách event mới nhất
  Future<List<Event>> fetchNewestEvents() async {
    try {
      final response = await dio.get('$baseUrl?filter=newest');
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
      print('Lỗi fetchNewestEvents: $e');
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
    int? parent_id,
  }) async {
    try {
      final response = await dio.post(
        'http://98.84.150.185:8000/api/connect-heart/client/comment/create-comment-event',
        data: {
          'event_id': eventId,
          'content': content,
          if (parent_id != null) 'parent_id': parent_id,
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

  /// Xoá một comment (event hoặc blog)
  Future<void> deleteComment({required int commentId}) async {
    final url =
        'http://98.84.150.185:8000/api/connect-heart/client/comment/delete-comment/$commentId';
    final response = await dio.delete(
      url,
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Lỗi xoá bình luận: ${response.data['message'] ?? response.statusMessage}',
      );
    }
    // nếu API trả về {"code":..., "status":..., "response": true},
    // bạn cũng có thể verify response.data['response'] == true
  }

  /// Cập nhật nội dung một comment
  Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    final url =
        'http://98.84.150.185:8000/api/connect-heart/client/comment/update-comment/$commentId';
    final response = await dio.put(
      url,
      data: {'content': content},
      options: Options(
        headers: {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Lỗi cập nhật bình luận: ${response.data['message'] ?? response.statusMessage}',
      );
    }
    // Giả sử API trả về response.data['response'] chứa object comment mới
    final json = response.data['response'] as Map<String, dynamic>;
    return Comment.fromJson(json);
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
      final rawList = data['response']['events'];
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

  Future<void> thamGiaSuKien(int eventId) async {
    try {
      final response = await dio.post(
        'http://98.84.150.185:8000/api/connect-heart/client/event-registration',
        data: {
          'event_id': eventId,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Tham gia sự kiện thành công');
      } else {
        throw Exception(
            'Lỗi tham gia sự kiện: ${response.data['message'] ?? response.statusMessage}');
      }
    } catch (e) {
      print('❌ Lỗi thamGiaSuKien: $e');
      rethrow;
    }
  }

  /// Lấy danh sách event đã đăng ký
  Future<List<Event>> fetchEventsSubmited() async {
    try {
      final response = await dio.get('http://98.84.150.185:8000/api/connect-heart/client/event-registration');
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
      print('Lỗi fetchNewestEvents: $e');
      rethrow;
    }
  }

  Future<void> createFeedback({
    required int eventId,
    required int rating,
    required String content,
  }) async {
    final resp = await dio.post(
      'http://98.84.150.185:8000/api/connect-heart/client/feedback/create-feedback-event',
      data: {
        'event_id': eventId,
        'rating': rating,
        'content': content,
      },
      options: Options(
        headers: {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Lỗi khi gửi đánh giá: ${resp.data['message']}');
    }
  }

  /// Tìm kiếm sự kiện theo từ khóa
  Future<List<Event>> searchEvents(String keyword) async {
    try {
      // Gọi GET lên cùng endpoint với param ?search=keyword
      final response = await dio.get(
        baseUrl,
        queryParameters: {'search': keyword},
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      final data = response.data;
      if (data != null &&
          data['response'] != null &&
          data['response']['events'] != null) {
        // parse mảng events.data
        return (data['response']['events']['data'] as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Lỗi: Dữ liệu trả về không hợp lệ');
      }
    } catch (e) {
      print('Lỗi searchEvents: $e');
      rethrow;
    }
  }

  Future<Event> updateEvent({
    required int eventId,
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

    // Nếu có file chứng chỉ, gửi multipart
    if (certificateFile != null) {
      final form = FormData.fromMap({
        ...body,
        'certificate_file': await MultipartFile.fromFile(
          certificateFile.path,
          filename: certificateFile.path.split('/').last,
        ),
      });
      final resp = await dio.patch(
        '$_baseUrl/$eventId',
        data: form,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: 'multipart/form-data',
        ),
      );
      if (resp.statusCode == 200) {
        final json = resp.data['response'] as Map<String, dynamic>;
        return Event.fromJson(json);
      } else {
        throw Exception(
            'Lỗi khi cập nhật sự kiện: ${resp.data['message'] ?? resp.statusMessage}');
      }
    } else {
      // Gửi JSON bình thường
      final resp = await dio.patch(
        '$_baseUrl/$eventId',
        data: body,
        options: Options(
          headers: {'Accept': 'application/json'},
          contentType: Headers.jsonContentType,
        ),
      );
      if (resp.statusCode == 200) {
        final json = resp.data['response'] as Map<String, dynamic>;
        return Event.fromJson(json);
      } else {
        throw Exception(
            'Lỗi khi cập nhật sự kiện: ${resp.data['message'] ?? resp.statusMessage}');
      }
    }
  }

  /// Lấy danh sách user đã đăng ký event
  Future<List<User>> fetchRegisteredUsers(int eventId) async {
    try {
      final resp = await dio.get(
        '$baseUrl/list-user-registration/$eventId',
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (resp.statusCode != 200) {
        throw Exception('Lỗi tải danh sách đăng ký: HTTP ${resp.statusCode}');
      }

      final data = resp.data;
      // Giả sử API trả về mảng users trong data['response']
      if (data == null || data['response'] == null || data['response'] is! List) {
        throw Exception('Dữ liệu đăng ký không hợp lệ');
      }

      return (data['response'] as List<dynamic>)
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Lỗi fetchRegisteredUsers: $e');
      rethrow;
    }
  }
}

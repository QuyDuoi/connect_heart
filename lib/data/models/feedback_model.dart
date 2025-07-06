import 'package:meta/meta.dart';

class UserFeedback {
  final int id;
  final String userName;
  final String imageProfile;

  UserFeedback({
    required this.id,
    required this.userName,
    required this.imageProfile,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as int,
      userName: json['user_name'] as String? ?? '',
      imageProfile: json['image_profile'] as String? ?? '',
    );
  }
}

/// Một feedback đơn lẻ
class FeedbackModel {
  final int id;
  final int userId;
  final int eventId;
  final int rating;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserFeedback user;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      eventId: json['event_id'] as int,
      rating: json['rating'] as int,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      user: UserFeedback.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Đóng gói kết quả của API lấy danh sách feedbacks
class FeedbackListResponse {
  final List<FeedbackModel> feedbacks;
  final double averageRating;
  final int totalFeedbacks;

  FeedbackListResponse({
    required this.feedbacks,
    required this.averageRating,
    required this.totalFeedbacks,
  });

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) {
    final resp = json['response'] as Map<String, dynamic>;
    final rawList = resp['feedbacks'] as List<dynamic>? ?? [];

    return FeedbackListResponse(
      feedbacks: rawList
          .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (resp['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalFeedbacks: resp['total_feedbacks'] as int? ?? 0,
    );
  }
}
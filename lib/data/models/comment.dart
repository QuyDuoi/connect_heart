class Comment {
  final int id;
  String content;
  final String userName;
  final String imageProfile;
  final DateTime createdAt;
  final List<Comment> children;
  int likeCount;

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    required this.imageProfile,
    required this.createdAt,
    required this.children,
    required this.likeCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      imageProfile: json['image_profile'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      likeCount: json['like_count'] as int? ?? 0,
    );
  }
}
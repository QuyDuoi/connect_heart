class Blog {
  final int id;
  final String content;
  final int userId;
  final bool status;
  final bool is_wishlist;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int wishlistsCount;
  final int commentsCount;
  final List<Thumbnail> thumbnails;
  final Author author;

  Blog({
    required this.id,
    required this.content,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.wishlistsCount,
    required this.commentsCount,
    required this.thumbnails,
    required this.author,
    required this.is_wishlist,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'] ?? 0, // Default value for id if null
      content: json['content'] ?? '', // Default value for content if null
      userId: json['user_id'] ?? 0, // Default value for userId if null
      status: json['status'] ?? false, // Default value for status if null
      is_wishlist: json['is_wishlist'] ?? false, // Default value for is_wishlist if null
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()), // Handle null createdAt
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String) 
          : null, // Handle null updatedAt
      wishlistsCount: json['wishlists_count'] ?? 0, // Default value for wishlistsCount if null
      commentsCount: json['comments_count'] ?? 0, // Default value for commentsCount if null
      thumbnails: json['thumbnails'] != null 
          ? List<Thumbnail>.from(
              (json['thumbnails'] as List).map((x) => Thumbnail.fromJson(x)),
            ) 
          : [], // Default to empty list if null
      author: json['author'] != null 
          ? Author.fromJson(json['author']) 
          : Author(id: 0, userName: 'No username', imageProfile: ''), // Default author if null
    );
  }
}

class Thumbnail {
  final int id;
  final String imageUrl; // Đổi tên thành imageUrl
  final String imageName;
  final DateTime createdAt;
  final int blogId;

  Thumbnail({
    required this.id,
    required this.imageUrl,  // Thay đổi ở đây
    required this.imageName,
    required this.createdAt,
    required this.blogId,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      id: json['id'] ?? 0, // Default value for id if null
      imageUrl: (json['image_url'] as String?) ?? '',  // Handle null image_url
      imageName: json['image_name'] ?? '', // Default image name if null
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()), // Handle null createdAt
      blogId: json['blog_id'] ?? 0, // Default value for blogId if null
    );
  }
}

class Author {
  final int id;
  final String userName;
  final String imageProfile;

  Author({
    required this.id,
    required this.userName,
    required this.imageProfile,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] ?? 0, // Default value for id if null
      userName: json['user_name'] ?? 'No username', // Default if no user_name exists
      imageProfile: json['image_profile'] ?? '', // Default if no image_profile exists
    );
  }
}

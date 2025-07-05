class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final String dateStart;
  final String dateEnd;
  final int categoryId;
  final String type;
  final String status;
  final bool certificateIsTrue;
  final String? certificateLink;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int wishlistsCount;
  final int commentsCount;
  final int registrationsCount;
  final bool is_wishlist;
  final bool is_registration;
  final List<String> thumbnails; // List of image paths for thumbnails
  final Creator creator; // The creator of the event
  final Category? category; // Optional category field

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateStart,
    required this.dateEnd,
    required this.categoryId,
    required this.type,
    required this.status,
    required this.certificateIsTrue,
    this.certificateLink,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.wishlistsCount,
    required this.commentsCount,
    required this.registrationsCount,
    required this.thumbnails,
    required this.creator,
    required this.category,
    required this.is_wishlist,
    required this.is_registration
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Thumbnails
    final List<dynamic> thumbnailsList =
        json['thumbnails'] as List<dynamic>? ?? [];
    final thumbnails = thumbnailsList
        .map<String>((t) => t['image_url'] as String? ?? '')
        .where((path) => path.isNotEmpty)
        .toList();

    // Fallback username: nếu 'creator' không có, dùng 'created_by' làm userName
    Creator creator;
    if (json['creator'] is Map<String, dynamic>) {
      creator = Creator.fromJson(json['creator'] as Map<String, dynamic>);
    } else {
      final int createdBy =
          json['created_by'] is int ? json['created_by'] as int : 0;
      creator = Creator(
          id: createdBy,
          userName: createdBy > 0 ? 'User #$createdBy' : 'Chưa rõ',
          imageProfile: '' // Default image, can be updated if available
      );
    }

    // Category: optional
    Category? category;
    if (json['category'] is Map<String, dynamic>) {
      category = Category.fromJson(json['category'] as Map<String, dynamic>);
    } else {
      category = null;
    }

    return Event(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? '',
      location: json['location'] as String? ?? '',
      dateStart: json['date_start'] as String? ?? '',
      dateEnd: json['date_end'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      certificateIsTrue: json['certificate_is_true'] as bool? ?? false,
      is_wishlist: json['is_wishlist'] as bool? ?? false,
      is_registration: json['is_registration'] as bool? ?? false,
      certificateLink: json['certificate_link'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      deletedAt: json['deleted_at'] as String?,
      wishlistsCount: json['wishlists_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      registrationsCount: json['registrations_count'] as int? ?? 0,
      thumbnails: thumbnails,
      creator: creator,
      category: category,
    );
  }
}

class Creator {
  final int id;
  final String userName;
  final String imageProfile; // Added field for image profile

  Creator({
    required this.id,
    required this.userName,
    required this.imageProfile, // Initialize this new field
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      userName:
          json['user_name'] ?? 'No username', // Default if no user_name exists
      imageProfile:
          json['image_profile'] ?? '', // Default if no image_profile exists
    );
  }
}

class Category {
  final int id;
  final String categoryName;

  Category({
    required this.id,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      categoryName: json['category_name'] ?? 'No category name',
    );
  }
}

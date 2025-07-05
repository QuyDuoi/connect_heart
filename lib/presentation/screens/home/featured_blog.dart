import 'package:flutter/material.dart';
import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/services/blog_service.dart';

class FeaturedBlogPost extends StatefulWidget {
  const FeaturedBlogPost({super.key});

  @override
  State<FeaturedBlogPost> createState() => _FeaturedBlogPostState();
}

class _FeaturedBlogPostState extends State<FeaturedBlogPost> {
  late Future<List<Blog>> _futureBlogs;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _futureBlogs = BlogService().fetchBlogs(); // Gọi API trong widget
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bài viết nổi bật',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Blog>>(
            future: _futureBlogs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmer();
              } else if (snapshot.hasError) {
                return Text('Lỗi tải blog: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final blog = snapshot.data!.first;
                return _buildBlogContent(blog);
              } else {
                return const Text('Không có bài viết nổi bật nào.');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlogContent(Blog blog) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header như cũ
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(blog.author.imageProfile),
              ),
              const SizedBox(width: 8),
              Text(blog.author.userName, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 16, color: Colors.blue),
            ],
          ),

          const SizedBox(height: 12),

          // Phần nội dung với maxLines và ellipsis
          Text(
            blog.content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
            maxLines: _isExpanded ? null : 3,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),

          // Nút Xem thêm / Ẩn bớt
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _isExpanded ? 'Ẩn bớt' : 'Xem thêm',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

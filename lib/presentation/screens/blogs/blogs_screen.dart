import 'package:connect_heart/presentation/screens/blogs/blog_form.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'blog_header.dart';
import 'blog_item.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  late Future<List<Blog>> _futureBlogs;

  @override
  void initState() {
    super.initState();
    _futureBlogs = BlogService().fetchBlogs(); // Gọi API lấy dữ liệu blogs
  }

  void _refreshBlogs() {
    setState(() {
      _futureBlogs = BlogService().fetchBlogs(); // Tải lại dữ liệu blogs
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BlogHeader(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh sách bài viết',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Nút Thêm mới
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BlogFormScreen()),
                        );
                        // Nếu có sự thay đổi sau khi quay lại, refresh lại dữ liệu
                        if (result == true) {
                          _refreshBlogs();
                        }
                      },
                      child: const Text(
                        'Thêm mới',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder<List<Blog>>(
                  future: _futureBlogs,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ShimmerListLoader(); // hiệu ứng loading
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Không có bài viết nào.'));
                    } else {
                      final blogs = snapshot.data!;
                      return Column(
                        children: blogs.map((blog) {
                          return BlogItem(
                            avatar: blog.author.imageProfile ??
                                'assets/khi_hau.png',
                            username: blog.author.userName,
                            content: blog.content,
                            image: blog.thumbnails.isNotEmpty
                                ? blog.thumbnails.first.imageUrl
                                : 'assets/blog.png',
                            wishlistsCount: blog.wishlistsCount,
                            commentsCount: blog.commentsCount,
                            id: blog.id,
                            isMyBlog: false,
                            blog: blog,
                            is_wishlist: blog.is_wishlist,
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

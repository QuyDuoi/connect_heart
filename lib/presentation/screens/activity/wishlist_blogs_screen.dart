import 'package:flutter/material.dart';
import 'package:connect_heart/data/models/blog.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/presentation/screens/blogs/blog_item.dart';
import 'package:connect_heart/presentation/screens/events/shimmer_loader.dart';

class WishlistBlogsScreen extends StatefulWidget {
  const WishlistBlogsScreen({Key? key}) : super(key: key);

  @override
  _WishlistBlogsScreenState createState() => _WishlistBlogsScreenState();
}

class _WishlistBlogsScreenState extends State<WishlistBlogsScreen> {
  late Future<List<Blog>> _futureWishlistBlogs;

  @override
  void initState() {
    super.initState();
    _futureWishlistBlogs = BlogService().fetchWishlistBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        title: const Text('Bài viết yêu thích'),
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FutureBuilder<List<Blog>>(
          future: _futureWishlistBlogs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerListLoader();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }
            final blogs = snapshot.data;
            if (blogs == null || blogs.isEmpty) {
              return const Center(
                  child: Text('Chưa có bài viết yêu thích nào.'));
            }
            return ListView.separated(
              itemCount: blogs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final blog = blogs[index];
                return BlogItem(
                  id: blog.id,
                  avatar: blog.author.imageProfile,
                  username: blog.author.userName,
                  content: blog.content,
                  image: blog.thumbnails.isNotEmpty
                      ? blog.thumbnails.first.imageUrl
                      : 'assets/blog.png',
                  wishlistsCount: blog.wishlistsCount,
                  commentsCount: blog.commentsCount,
                  blog: blog,
                  isMyBlog: false,
                  is_wishlist: blog.is_wishlist,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

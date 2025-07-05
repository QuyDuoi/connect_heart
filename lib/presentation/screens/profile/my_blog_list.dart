import 'package:connect_heart/data/models/blog.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/presentation/screens/blogs/blog_item.dart';

class MyBlogList extends StatelessWidget {
  final List<Blog> blogs;

  const MyBlogList({super.key, required this.blogs});

  @override
  Widget build(BuildContext context) {
    if (blogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'Chưa có bài viết nào được tạo.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        final blog = blogs[index];
        return BlogItem(
          avatar: blog.author.imageProfile,
          username: blog.author.userName,
          content: blog.content,
          image: blog.thumbnails.isNotEmpty
              ? blog.thumbnails.first.imageUrl 
              : 'assets/blog.png',
          wishlistsCount: blog.wishlistsCount,
          commentsCount: blog.commentsCount,
          id: blog.id,
          isMyBlog: true,
          blog: blog, 
          is_wishlist: blog.is_wishlist,
        );
      },
    );
  }
}

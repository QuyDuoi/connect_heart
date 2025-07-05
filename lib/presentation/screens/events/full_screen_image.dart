import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final bool isNetwork;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    this.isNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: imageUrl,
              child: PhotoView(
                imageProvider: isNetwork
                    ? NetworkImage(imageUrl)
                    : AssetImage(imageUrl) as ImageProvider,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

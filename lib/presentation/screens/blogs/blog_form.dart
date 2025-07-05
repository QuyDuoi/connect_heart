import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connect_heart/data/services/blog_service.dart';
import 'package:connect_heart/data/models/blog.dart';
import 'package:image_picker/image_picker.dart';

class BlogFormScreen extends StatefulWidget {
  final bool isEdit;
  final Blog? existingBlog;

  const BlogFormScreen({super.key, this.isEdit = false, this.existingBlog});

  @override
  State<BlogFormScreen> createState() => _BlogFormScreenState();
}

class _BlogFormScreenState extends State<BlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final contentCtrl = TextEditingController();

  final List<XFile> _images = [];
  bool _isUploading = false;

  final baseTextStyle = const TextStyle(fontFamily: 'Merriweather');
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingBlog != null) {
      // Nếu chỉnh sửa, điền dữ liệu vào các trường
      contentCtrl.text = widget.existingBlog!.content;
      _images.addAll(widget.existingBlog!.thumbnails.isNotEmpty
          ? widget.existingBlog!.thumbnails
              .map((e) =>
                  XFile(e.imageUrl)) // Sử dụng imageUrl thay vì imagePath
              .toList()
          : []);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      if (widget.isEdit) {
        // Gọi API để cập nhật bài viết
        await BlogService().updateBlog(
          blogId: widget.existingBlog!.id,
          content: contentCtrl.text.trim(),
        );
      } else {
        // Gọi API để tạo mới bài viết
        await BlogService().createBlog(
          content: contentCtrl.text.trim(),
          images: _images.isNotEmpty
              ? _images.map((e) => File(e.path)).toList()
              : [],
        );
      }

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.isEdit
                ? '🎉 Cập nhật bài viết thành công'
                : '🎉 Tạo bài viết thành công')),
      );

      // Trả lại thông báo thành công cho BlogsScreen
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Widget _requiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: baseTextStyle.copyWith(color: Colors.black),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    String? hint,
    int minLines = 1,
    int? maxLines = 5, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          required ? _requiredLabel(label) : Text(label, style: baseTextStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.multiline,
            minLines: minLines,
            maxLines: maxLines,
            style: baseTextStyle,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
              hintText: hint,
            ),
            validator: (val) => required && (val == null || val.isEmpty)
                ? 'Vui lòng nhập $label'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    // Ẩn phần upload ảnh khi là chế độ chỉnh sửa (isEdit)
    if (widget.isEdit) {
      return const SizedBox(); // Không hiển thị phần upload ảnh
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo, size: 32, color: Colors.black54),
              SizedBox(height: 8),
              Text('Thêm ảnh bài viết'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return _images.isEmpty
        ? const SizedBox()
        : GridView.builder(
            shrinkWrap: true, // Makes GridView respect parent height
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _images.length,
            itemBuilder: (context, i) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: widget.isEdit
                        // Nếu là chế độ chỉnh sửa, sử dụng Image.network để hiển thị ảnh từ URL
                        ? Image.network(
                            _images[i].path, // Đây là URL của ảnh
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        // Nếu không phải chỉnh sửa, sử dụng Image.file cho ảnh cục bộ
                        : Image.file(
                            File(_images[i].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _images.removeAt(i));
                      },
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black45,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.isEdit ? 'Chỉnh sửa bài viết' : 'Thêm mới bài viết',
          style: baseTextStyle.copyWith(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nội dung', contentCtrl,
                  required: true, hint: 'Nhập nội dung bài viết'),
              const SizedBox(height: 12),
              _buildImagePicker(), // Ẩn khi là chế độ chỉnh sửa
              _buildImagePreview(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(widget.isEdit ? 'Lưu thông tin' : 'Tạo bài viết',
                    style: baseTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

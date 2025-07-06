import 'dart:io';
import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EventImageScreen extends StatefulWidget {
  final Event event;
  final String? categoryName;
  const EventImageScreen({super.key, required this.event, this.categoryName});

  @override
  State<EventImageScreen> createState() => _EventImageScreenState();
}

String _formatDate(String isoString) {
  final dt = DateTime.tryParse(isoString);
  if (dt == null) return isoString;
  return DateFormat('dd/MM/yyyy').format(dt);
}

class _EventImageScreenState extends State<EventImageScreen> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70);
    if (picked != null && picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }

  Future<void> _uploadAll() async {
    if (_images.isEmpty) return;
    setState(() => _isUploading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (final img in _images) {
        await EventService()
            .uploadThumbnails(eventId: widget.event.id, images: [File(img.path)]);
      }
      Navigator.of(context, rootNavigator: true).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Upload ảnh thành công')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi upload ảnh: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final start = _formatDate(e.dateStart);
  final end = _formatDate(e.dateEnd);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm ảnh sự kiện'),
        leading: BackButton(onPressed: () {
          if (!_isUploading) Navigator.pop(context);
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Thông tin event
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lĩnh vực: ${widget.categoryName}'),
                  const SizedBox(height: 4),
                  Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Thời gian: $start  –  $end'),
                  const SizedBox(height: 4),
                  Text('Địa điểm: ${e.location}'),
                ],
              ),
            ),

            // 2. Khu vực chọn ảnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 120,
                  width: double.infinity,
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
                        Text('Thêm ảnh sự kiện'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Preview các ảnh đã chọn
            if (_images.isNotEmpty)
              Expanded(
                child: GridView.builder(
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
                          child: Image.file(
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
                ),
              ),

            // 4. Nút Hoàn tất
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadAll,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(_isUploading ? 'Đang tải...' : 'Hoàn tất'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

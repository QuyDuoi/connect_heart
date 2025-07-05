import 'dart:io';

import 'package:connect_heart/presentation/screens/events/event_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect_heart/data/models/event.dart';
import 'package:connect_heart/data/services/event_service.dart';
import 'package:image_picker/image_picker.dart';

class EventFormScreen extends StatefulWidget {
  final bool isEdit;
  final Event? existingEvent; 

  const EventFormScreen({super.key, this.isEdit = false, this.existingEvent});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  int? categoryId;
  String? eventType;

  bool hasCertificate = false;
  XFile? certificateImage;

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Y tế'},
    {'id': 2, 'name': 'Giáo dục'},
    {'id': 3, 'name': 'Cứu hộ'},
    {'id': 4, 'name': 'Khí hậu'},
  ];

  final List<String> eventTypes = ['Offline', 'Online'];

  final baseTextStyle = const TextStyle(fontFamily: 'Merriweather');

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingEvent != null) {
      // Nếu là chỉnh sửa, điền dữ liệu của sự kiện vào các trường
      final event = widget.existingEvent!;
      titleCtrl.text = event.title;
      descriptionCtrl.text = event.description;
      addressCtrl.text = event.location;
      startDate = DateTime.parse(event.dateStart);
      endDate = event.dateEnd != null ? DateTime.parse(event.dateEnd!) : null;
      categoryId = event.category?.id;
      eventType = event.type;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => certificateImage = pickedFile);
    }
  }

  Future<void> selectDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          startDate = picked;
        else
          endDate = picked;
      });
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

  Widget _buildTextField(String label, TextEditingController ctrl,
      {bool required = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          required ? _requiredLabel(label) : Text(label, style: baseTextStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLength: 100,
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

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(label),
          const SizedBox(height: 6),
          TextFormField(
            readOnly: true,
            onTap: onTap,
            controller: TextEditingController(
              text: date == null
                  ? ''
                  : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
            ),
            style: baseTextStyle,
            decoration: const InputDecoration(
              hintText: 'dd/mm/yyyy',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (_) => date == null ? 'Vui lòng chọn $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCategory() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: categoryId,
        style: baseTextStyle,
        decoration: InputDecoration(
          labelText: 'Danh mục *',
          labelStyle: baseTextStyle,
          border: const OutlineInputBorder(),
        ),
        items: categories
            .map((e) => DropdownMenuItem<int>(value: e['id'], child: Text(e['name'])))
            .toList(),
        onChanged: (val) => setState(() => categoryId = val),
        validator: (val) => val == null ? 'Vui lòng chọn danh mục' : null,
      ),
    );
  }

  Widget _buildDropdownType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownButtonFormField<String>(
        value: eventType,
        style: baseTextStyle,
        decoration: InputDecoration(
          labelText: 'Hình thức *',
          labelStyle: baseTextStyle,
          border: const OutlineInputBorder(),
        ),
        items: eventTypes
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: baseTextStyle.copyWith(color: Colors.black)),
                ))
            .toList(),
        onChanged: (val) => setState(() => eventType = val),
        validator: (val) => val == null ? 'Vui lòng chọn hình thức' : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: certificateImage == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 28),
                    SizedBox(height: 8),
                    Text('Thêm ảnh chứng chỉ'),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(certificateImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.isEdit ? 'Chỉnh sửa sự kiện' : 'Thêm mới sự kiện',
          style: baseTextStyle.copyWith(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                _buildTextField('Tiêu đề', titleCtrl,
                    required: true, hint: 'Nhập tiêu đề sự kiện'),
                _buildTextField('Mô tả', descriptionCtrl,
                    hint: 'Nhập mô tả sự kiện'),
                _buildTextField('Địa chỉ', addressCtrl,
                    required: true, hint: 'Nhập địa chỉ sự kiện'),
                _buildDateField(
                    'Ngày bắt đầu', startDate, () => selectDate(isStart: true)),
                _buildDateField(
                    'Ngày kết thúc', endDate, () => selectDate(isStart: false)),
                _buildDropdownCategory(),
                _buildDropdownType(),
                CheckboxListTile(
                  value: hasCertificate,
                  title: Text('Sự kiện có chứng chỉ không?', style: baseTextStyle),
                  onChanged: (val) =>
                      setState(() => hasCertificate = val ?? false),
                ),
                if (hasCertificate) _buildImagePicker(),
                ElevatedButton(
                  onPressed: () async {
                    // 1. Validate form
                    if (!_formKey.currentState!.validate()) return;

                    // 2. Hiện dialog loading (override navigator chính, rootNavigator: true)
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // 1) Tạo sự kiện, lấy event mới
                      final newEvent = await EventService().createEvent(
                        title: titleCtrl.text.trim(),
                        description: descriptionCtrl.text.trim(),
                        location: addressCtrl.text.trim(),
                        dateStart: startDate!,
                        dateEnd: endDate,
                        categoryId: categoryId!,
                        type: eventType!,
                        certificateIsTrue: hasCertificate,
                        certificateFile:
                            hasCertificate && certificateImage != null
                                ? File(certificateImage!.path)
                                : null,
                      );

                      // 2) Đóng dialog loading
                      Navigator.of(context, rootNavigator: true).pop();

                      // 3) Chuyển sang màn thêm ảnh, truyền newEvent
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => EventImageScreen(event: newEvent),
                      ));
                    } catch (e) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Lỗi: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text('Tiếp tục', style: baseTextStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:connect_heart/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  late final TextEditingController usernameCtrl;
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController addressCtrl;

  /// Giá trị giữ nguyên của backend: 'male' | 'female' | 'other'
  String? gender;

  /// Map từ giá trị backend sang label hiển thị
  static const Map<String, String> _genderLabels = {
    'male'  : 'Nam',
    'female': 'Nữ',
    'other' : 'Khác',
  };

  DateTime? dob;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);

    usernameCtrl = TextEditingController(text: user?.userName    ?? '');
    firstNameCtrl = TextEditingController(text: user?.firstName  ?? '');
    lastNameCtrl   = TextEditingController(text: user?.lastName   ?? '');
    emailCtrl      = TextEditingController(text: user?.email      ?? '');
    phoneCtrl      = TextEditingController(text: user?.phoneNumber?? '');
    addressCtrl    = TextEditingController(text: user?.address    ?? '');

    // Backend trả về như 'male','female','other'
    gender = user?.gender?.toLowerCase();
    // nếu backend lưu ngày sinh ở dạng ISO string:
    dob = user?.dateOfBirth != null
        ? DateTime.tryParse(user!.dateOfBirth!)
        : null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gọi API cập nhật với gender (male|female|other) và dob.toIso8601String()
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = const TextStyle(fontFamily: 'Merriweather');
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1, centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cập nhật thông tin tài khoản',
          style: baseStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
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
                _buildField('Tên tài khoản', usernameCtrl, style: baseStyle),
                _buildField('Họ', firstNameCtrl,        style: baseStyle),
                _buildField('Tên', lastNameCtrl,         style: baseStyle),
                _buildField('Email', emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: baseStyle),
                _buildPhoneInput(baseStyle),

                const SizedBox(height: 12),
                _requiredLabel('Ngày sinh', baseStyle),
                const SizedBox(height: 6),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: dob == null
                        ? ''
                        : '${dob!.day.toString().padLeft(2,'0')}/'
                          '${dob!.month.toString().padLeft(2,'0')}/'
                          '${dob!.year}',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dob ?? DateTime(2000,1,1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => dob = picked);
                  },
                  validator: (_) =>
                      dob == null ? 'Vui lòng chọn ngày sinh' : null,
                ),

                const SizedBox(height: 12),
                _requiredLabel('Giới tính', baseStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField2<String>(
                  value: gender,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  hint: const Text('Chọn giới tính'),
                  items: _genderLabels.entries.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.key,    // 'male','female','other'
                      child: Text(e.value), // 'Nam','Nữ','Khác'
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => gender = val),
                  validator: (val) => val == null ? 'Vui lòng chọn giới tính' : null,
                ),

                const SizedBox(height: 12),
                _buildField('Địa chỉ', addressCtrl, style: baseStyle),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Xác nhận', style: baseStyle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requiredLabel(String label, TextStyle style) {
    return RichText(
      text: TextSpan(
        text: label,
        style: style.copyWith(color: Colors.black),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(label, style),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: style,
            decoration: InputDecoration(
              hintText: 'Nhập ${label.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Vui lòng nhập $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel('Số điện thoại', style),
          const SizedBox(height: 6),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            style: style,
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left:12, right:8),
                child: Text('+84 |', style: TextStyle(fontSize:16)),
              ),
              prefixIconConstraints:
                  BoxConstraints(minWidth:0, minHeight:0),
              hintText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
          ),
        ],
      ),
    );
  }
}

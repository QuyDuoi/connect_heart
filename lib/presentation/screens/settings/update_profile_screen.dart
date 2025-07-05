import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final usernameCtrl = TextEditingController(text: 'Dahiiiii');
  final firstNameCtrl = TextEditingController(text: 'Dag');
  final lastNameCtrl = TextEditingController(text: 'Hien');
  final emailCtrl = TextEditingController(text: 'johndoe123@gmail.com');
  final phoneCtrl = TextEditingController(text: '865902091');
  final addressCtrl = TextEditingController(text: 'Hà Nội');

  String? gender = 'Nữ';
  DateTime? dob = DateTime(2003, 11, 2);

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gửi API cập nhật thông tin
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = const TextStyle(fontFamily: 'Merriweather');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cập nhật thông tin tài khoản',
          style: baseTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
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
                _buildFieldWithCounter('Tên tài khoản', usernameCtrl, style: baseTextStyle),
                _buildFieldWithCounter('Họ', firstNameCtrl, style: baseTextStyle),
                _buildFieldWithCounter('Tên', lastNameCtrl, style: baseTextStyle),
                _buildFieldWithCounter('Email', emailCtrl,
                    keyboardType: TextInputType.emailAddress, style: baseTextStyle),
                _buildPhoneInput(baseTextStyle),
                const SizedBox(height: 6),
                _requiredLabel('Ngày sinh', baseTextStyle),
                const SizedBox(height: 6),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dob ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => dob = picked);
                  },
                  controller: TextEditingController(
                    text: dob == null
                        ? ''
                        : '${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}',
                  ),
                  style: baseTextStyle,
                  decoration: const InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),
                const SizedBox(height: 8),
                _requiredLabel('Giới tính', baseTextStyle),
                const SizedBox(height: 6),
                DropdownButtonFormField2<String>(
                  value: gender,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  hint: const Text('Chọn giới tính'),
                  items: const [
                    DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                    DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                  ],
                  onChanged: (val) => setState(() => gender = val),
                  validator: (val) => val == null ? 'Vui lòng chọn giới tính' : null,
                ),
                const SizedBox(height: 8),
                _buildField('Địa chỉ', addressCtrl, style: baseTextStyle),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Xác nhận', style: baseTextStyle),
                )
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

  Widget _buildFieldWithCounter(String label, TextEditingController controller,
      {TextInputType? keyboardType, required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _requiredLabel(label, style),
              Text('${controller.text.length}/50', style: style.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: 50,
            style: style,
            decoration: InputDecoration(
              hintText: 'Nhập ${label.toLowerCase()}',
              border: const OutlineInputBorder(),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
            validator: (val) => val == null || val.isEmpty
                ? 'Vui lòng nhập $label'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(label, style),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: style,
            decoration: InputDecoration(
              hintText: 'Nhập ${label.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
            validator: (val) => val == null || val.isEmpty
                ? 'Vui lòng nhập $label'
                : null,
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
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Text(
                  '+84 |',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
            validator: (val) => val == null || val.isEmpty
                ? 'Vui lòng nhập số điện thoại'
                : null,
          ),
        ],
      ),
    );
  }
}

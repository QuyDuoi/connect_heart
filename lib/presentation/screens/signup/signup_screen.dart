import 'package:connect_heart/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? gender;
  DateTime? dob;

  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    final result = await AuthService.registerUser(
      username: usernameCtrl.text.trim(),
      firstName: firstNameCtrl.text.trim(),
      lastName: lastNameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), ''), // CHỈ giữ số
      address: addressCtrl.text.trim(),
      gender: gender,
      dob: dob,
      password: passwordCtrl.text,
    );

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (_) => _showSuccessDialog(),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Chúc mừng !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tài khoản của bạn đã được tạo thành công!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.go('/login')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Đăng ký tài khoản',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Merriweather',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Đảm bảo thông tin là chính xác',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildFieldWithCounter('Tên tài khoản', usernameCtrl,
                    hint: 'E.g. dahi111'),
                _buildFieldWithCounter('Họ', firstNameCtrl,
                    hint: 'Enter your first name'),
                _buildFieldWithCounter('Tên', lastNameCtrl,
                    hint: 'Enter your last name'),
                _buildFieldWithCounter('Email', emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    hint: 'johndoe123@gmail.com'),
                const SizedBox(height: 6),
                _buildPhoneInput(),
                const SizedBox(height: 8),
                _requiredLabel('Ngày sinh'),
                const SizedBox(height: 6),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => dob = picked);
                  },
                  controller: TextEditingController(
                    text: dob == null
                        ? ''
                        : '${dob!.day}/${dob!.month}/${dob!.year}',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  validator: (val) =>
                      dob == null ? 'Vui lòng chọn ngày sinh' : null,
                ),
                const SizedBox(height: 8),
                _requiredLabel('Giới tính'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                    DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                    DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                  ],
                  onChanged: (val) => setState(() => gender = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Choose your gender',
                  ),
                  validator: (val) =>
                      val == null ? 'Vui lòng chọn giới tính' : null,
                ),
                const SizedBox(height: 8),
                _buildField('Địa chỉ', addressCtrl),
                _buildField('Mật khẩu', passwordCtrl, obscure: true),
                _buildField('Xác nhận mật khẩu', confirmCtrl, obscure: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (passwordCtrl.text != confirmCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mật khẩu không khớp')),
                        );
                        return;
                      }
                      _register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Đăng ký'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requiredLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildFieldWithCounter(String label, TextEditingController controller,
      {TextInputType? keyboardType, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _requiredLabel(label),
              Text('${controller.text.length}/50',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: hint ?? 'Nhập ${label.toLowerCase()}',
              hintStyle: const TextStyle(color: Colors.grey),
              counterText: '',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            validator: (val) =>
                val == null || val.isEmpty ? 'Vui lòng nhập $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: 'Nhập ${label.toLowerCase()}',
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(),
              suffixIcon: obscure ? const Icon(Icons.visibility_off) : null,
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Vui lòng nhập $label' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _requiredLabel('Số điện thoại'),
          const SizedBox(height: 6),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
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
              hintStyle: TextStyle(color: Colors.grey),
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

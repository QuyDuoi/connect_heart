import 'package:connect_heart/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _oldCtrl.addListener(_validatePasswords);
    _newCtrl.addListener(_validatePasswords);
    _confirmCtrl.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    final oldPwd = _oldCtrl.text.trim();
    final newPwd = _newCtrl.text.trim();
    final confirmPwd = _confirmCtrl.text.trim();

    final isValid = oldPwd.isNotEmpty &&
        newPwd.isNotEmpty &&
        confirmPwd.isNotEmpty &&
        newPwd == confirmPwd;

    if (_canSubmit != isValid) {
      setState(() => _canSubmit = isValid);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final oldPwd = _oldCtrl.text.trim();
      final newPwd = _newCtrl.text.trim();

      final result = await AuthService.resetPassword(
        currentPassword: oldPwd,
        newPassword: newPwd,
      );

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error,
                    style: const TextStyle(fontFamily: 'Merriweather'))),
          );
        },
        (_) => _showSuccessDialog(),
      );
    }
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontFamily: 'Merriweather');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F1F5),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Đổi mật khẩu',
          style: textStyle.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPasswordField(
              label: 'Mật khẩu cũ',
              controller: _oldCtrl,
              obscureText: _obscureOld,
              toggleObscure: () => setState(() => _obscureOld = !_obscureOld),
              style: textStyle,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              label: 'Mật khẩu mới',
              controller: _newCtrl,
              obscureText: _obscureNew,
              toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              style: textStyle,
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              label: 'Xác nhận mật khẩu mới',
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              toggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              style: textStyle,
              validator: (v) {
                if (v != _newCtrl.text) return 'Mật khẩu xác nhận không khớp';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                disabledBackgroundColor: Colors.blue.shade900.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Xác nhận', style: textStyle.copyWith(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required TextStyle style,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: style.copyWith(fontSize: 14, color: Colors.black),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: style,
          validator: validator ??
              (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null,
          decoration: InputDecoration(
            hintText: 'Nhập ${label.toLowerCase()}',
            hintStyle: style.copyWith(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleObscure,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.blue, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Thành công!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mật khẩu của bạn đã được thay đổi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.of(dialogContext).pop(); // đóng dialog
                Navigator.of(context).pop(); // quay lại màn trước
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

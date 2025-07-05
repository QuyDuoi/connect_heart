import 'package:connect_heart/data/models/user.dart';
import 'package:connect_heart/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/token_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await AuthService.login(
        emailOrPhone: emailController.text.trim(),
        password: passwordController.text,
      );

      setState(() => _isLoading = false);

      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        ),
        (token) async {
          await ref.read(tokenProvider.notifier).setToken(token);
          await AuthService.init();

          // Load lại thông tin user từ SharedPreferences và đưa vào userProvider
          final prefs = await SharedPreferences.getInstance();
          final userJson = prefs.getString('user_data');
          if (userJson != null) {
            final user = User.fromJson(jsonDecode(userJson));
            await ref.read(userProvider.notifier).setUser(user);
          }

          context.go('/home');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to Connect Heart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vui lòng đăng nhập để truy cập',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu phải từ 6 ký tự';
                    }
                    return null;
                  },
                ),
                // const SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {},
                //     child: const Text('Forgot your password?'),
                //   ),
                // ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Bạn chưa có tài khoản?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

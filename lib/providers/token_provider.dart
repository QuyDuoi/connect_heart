import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenProvider = StateNotifierProvider<TokenNotifier, String?>((ref) {
  return TokenNotifier();
});

class TokenNotifier extends StateNotifier<String?> {
  TokenNotifier() : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('auth_token');
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('auth_token');
    } else {
      await prefs.setString('auth_token', token);
    }
    state = token;
  }
}

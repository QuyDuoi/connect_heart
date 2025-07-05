import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'signup_state.dart';

class SignupNotifier extends StateNotifier<SignupState> {
  SignupNotifier() : super(const SignupState());

  Future<void> submit({
    required String username,
    required String email,
    required String password,
    required void Function() onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future.delayed(const Duration(seconds: 2)); // giả lập API

    if (email == 'test@gmail.com') {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email đã tồn tại',
      );
    } else {
      onSuccess();
      state = state.copyWith(isLoading: false);
    }
  }
}

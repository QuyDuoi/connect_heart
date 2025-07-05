import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/screens/signup/signup_notifier.dart';
import '../presentation/screens/signup/signup_state.dart';

final signupProvider =
    StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier();
});

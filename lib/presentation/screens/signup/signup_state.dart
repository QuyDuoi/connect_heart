import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state.freezed.dart';

@freezed
class SignupState with _$SignupState {
  const factory SignupState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SignupState;
}

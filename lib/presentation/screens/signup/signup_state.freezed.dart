// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SignupState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignupStateCopyWith<SignupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignupStateCopyWith<$Res> {
  factory $SignupStateCopyWith(
          SignupState value, $Res Function(SignupState) then) =
      _$SignupStateCopyWithImpl<$Res, SignupState>;
  @useResult
  $Res call({bool isLoading, String? errorMessage});
}

/// @nodoc
class _$SignupStateCopyWithImpl<$Res, $Val extends SignupState>
    implements $SignupStateCopyWith<$Res> {
  _$SignupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SignupStateImplCopyWith<$Res>
    implements $SignupStateCopyWith<$Res> {
  factory _$$SignupStateImplCopyWith(
          _$SignupStateImpl value, $Res Function(_$SignupStateImpl) then) =
      __$$SignupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, String? errorMessage});
}

/// @nodoc
class __$$SignupStateImplCopyWithImpl<$Res>
    extends _$SignupStateCopyWithImpl<$Res, _$SignupStateImpl>
    implements _$$SignupStateImplCopyWith<$Res> {
  __$$SignupStateImplCopyWithImpl(
      _$SignupStateImpl _value, $Res Function(_$SignupStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$SignupStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SignupStateImpl implements _SignupState {
  const _$SignupStateImpl({this.isLoading = false, this.errorMessage});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SignupState(isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignupStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, errorMessage);

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignupStateImplCopyWith<_$SignupStateImpl> get copyWith =>
      __$$SignupStateImplCopyWithImpl<_$SignupStateImpl>(this, _$identity);
}

abstract class _SignupState implements SignupState {
  const factory _SignupState(
      {final bool isLoading, final String? errorMessage}) = _$SignupStateImpl;

  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of SignupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignupStateImplCopyWith<_$SignupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

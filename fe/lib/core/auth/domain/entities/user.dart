import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// User domain entity
/// Represents an authenticated user (Firebase Auth)
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) = _User;

  const User._();

  /// Check if user is anonymous (guest)
  bool get isAnonymous => uid.isEmpty || email.isEmpty;
}

/// Guest user singleton
class GuestUser {
  static const User instance = User(
    uid: '',
    email: '',
    displayName: 'Guest',
  );
}

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:service_sentinel_fe_v2/core/error/app_error.dart';
import 'package:service_sentinel_fe_v2/core/error/result.dart';
import 'package:service_sentinel_fe_v2/core/auth/domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final Dio _dio;
  static const String _baseUrl = '/auth';
  final fb.FirebaseAuth _firebaseAuth;

  AuthRepository(this._firebaseAuth, this._dio);

  User _mapFirebaseUserToDomain(fb.User user) {
    return User(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return Result.success(GuestUser.instance);
      }

      return Result.success(_mapFirebaseUserToDomain(user));
    } catch (e) {
      return Result.failure(AuthError(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw AuthError(message: '로그인 요청이 시간 초과되었습니다');
        },
      );

      // 서버 토큰 갱신 딜레이
      await Future.delayed(const Duration(seconds: 1));

      final user = credential.user;
      if (user == null) {
        return Result.failure(AuthError(message: '로그인에 실패했습니다'));
      }

      return Result.success(_mapFirebaseUserToDomain(user));
    } catch (e) {
      return Result.failure(AuthError(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Result.failure(AuthError(message: '로그인에 실패했습니다.'));
      }

      return Result.success(_mapFirebaseUserToDomain(user));
    } catch (e) {
      return Result.failure(AuthError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthError(message: e.toString()));
    }
  }

  @override
  Stream<User> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((fbUser) {
      if (fbUser == null) {
        return GuestUser.instance;
      }
      return _mapFirebaseUserToDomain(fbUser);
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = _firebaseAuth.currentUser;
    return user != null && !user.isAnonymous;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.isAnonymous) {
      return null;
    }

    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      fb.UserCredential userCredential;

      if (kIsWeb) {
        // Web: Firebase Auth가 OAuth를 직접 처리
        final provider = fb.GoogleAuthProvider()
          ..setCustomParameters({
            'prompt': 'select_account',
          });

        userCredential = await _firebaseAuth.signInWithPopup(provider);
      } else {
        // Mobile (Android / iOS): google_sign_in 사용
        final googleUser = await GoogleSignIn().signIn();

        // 사용자가 로그인 취소한 경우
        if (googleUser == null) {
          return Result.failure(
            UnauthorizedError(message: '로그인을 취소하였습니다.'),
          );
        }

        final googleAuth = await googleUser.authentication;

        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) {
        return Result.failure(
          UnauthorizedError(message: '로그인 실패!'),
        );
      }

      // 서버 토큰 갱신 딜레이
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(_mapFirebaseUserToDomain(user));
    } catch (e, stack) {
      print('error is $e');
      // 필요하면 FirebaseAuthException 타입 분기 가능
      return Result.failure(
        UnauthorizedError(message: '로그인 실패!'),
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _dio.delete('$_baseUrl/me');
    } catch (e) {
      rethrow;
    }
  }
}

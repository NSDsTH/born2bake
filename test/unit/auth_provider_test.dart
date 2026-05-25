import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:born2bake/providers/auth_provider.dart' as auth_lib;

// ─── Fake classes (Manual Mocks — ไม่ต้องใช้ build_runner) ──────────────────

class _FakeUser extends Fake implements User {
  final String _email;
  _FakeUser(this._email);

  @override
  String? get email => _email;
}

class _FakeUserCredential extends Fake implements UserCredential {
  final User? _user;
  _FakeUserCredential(this._user);

  @override
  User? get user => _user;
}

/// Mock ของ FirebaseAuth ที่ควบคุมได้จาก test
class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast(sync: true);

  String? _simulatedError;

  void simulateError(String message) => _simulatedError = message;
  void clearError() => _simulatedError = null;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_simulatedError != null) {
      throw FirebaseAuthException(code: 'test-error', message: _simulatedError);
    }
    final user = _FakeUser(email);
    _controller.add(user);
    return _FakeUserCredential(user);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_simulatedError != null) {
      throw FirebaseAuthException(code: 'test-error', message: _simulatedError);
    }
    final user = _FakeUser(email);
    _controller.add(user);
    return _FakeUserCredential(user);
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  void close() => _controller.close();
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeFirebaseAuth fakeAuth;
  late auth_lib.AuthProvider provider;

  setUp(() {
    fakeAuth = _FakeFirebaseAuth();
    provider = auth_lib.AuthProvider(firebaseAuth: fakeAuth);
  });

  tearDown(() {
    provider.dispose();
    fakeAuth.close();
  });

  // ─── TC-U-AUTH-01: initial state ────────────────────────────────────────

  test('TC-U-AUTH-01: state เริ่มต้น — ยังไม่ได้ login', () {
    expect(provider.isAuthenticated, isFalse);
    expect(provider.isLoading, isFalse);
    expect(provider.user, isNull);
    expect(provider.isAdmin, isFalse);
  });

  // ─── TC-U-AUTH-02: isAdmin ───────────────────────────────────────────────

  test('TC-U-AUTH-02: isAdmin เป็น true เฉพาะ admin@borntobake.com', () async {
    await provider.signIn('admin@borntobake.com', 'AnyPass123');
    expect(provider.isAdmin, isTrue);
  });

  test('TC-U-AUTH-02b: isAdmin เป็น false สำหรับ user ทั่วไป', () async {
    await provider.signIn('customer@test.com', 'AnyPass123');
    expect(provider.isAdmin, isFalse);
  });

  // ─── TC-U-AUTH-03: signIn success ───────────────────────────────────────

  test('TC-U-AUTH-03: signIn สำเร็จ — คืนค่า null และตั้งค่า isAuthenticated', () async {
    final error = await provider.signIn('user@test.com', 'Test1234!');
    expect(error, isNull);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.email, equals('user@test.com'));
  });

  // ─── TC-U-AUTH-04: signIn failure ───────────────────────────────────────

  test('TC-U-AUTH-04: signIn ล้มเหลว — คืนค่า error message', () async {
    fakeAuth.simulateError('รหัสผ่านไม่ถูกต้อง');
    final error = await provider.signIn('user@test.com', 'WrongPass');
    expect(error, equals('รหัสผ่านไม่ถูกต้อง'));
    expect(provider.isAuthenticated, isFalse);
    expect(provider.isLoading, isFalse);
  });

  // ─── TC-U-AUTH-05: isLoading state ──────────────────────────────────────

  test('TC-U-AUTH-05: isLoading เป็น false หลังจาก signIn เสร็จสิ้น', () async {
    await provider.signIn('user@test.com', 'Test1234!');
    expect(provider.isLoading, isFalse);
  });

  // ─── TC-U-AUTH-06: signUp success ───────────────────────────────────────

  test('TC-U-AUTH-06: signUp สำเร็จ — คืนค่า null และ set user', () async {
    final error = await provider.signUp('newuser@test.com', 'Test1234!');
    expect(error, isNull);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.user?.email, equals('newuser@test.com'));
  });

  // ─── TC-U-AUTH-07: signUp failure ───────────────────────────────────────

  test('TC-U-AUTH-07: signUp ล้มเหลว — คืนค่า error message (เช่น อีเมลซ้ำ)', () async {
    fakeAuth.simulateError('อีเมลนี้ถูกใช้งานแล้ว');
    final error = await provider.signUp('existing@test.com', 'Test1234!');
    expect(error, equals('อีเมลนี้ถูกใช้งานแล้ว'));
    expect(provider.isAuthenticated, isFalse);
  });

  // ─── TC-U-AUTH-08: signOut ───────────────────────────────────────────────

  test('TC-U-AUTH-08: signOut ล้าง user state', () async {
    await provider.signIn('user@test.com', 'Test1234!');
    expect(provider.isAuthenticated, isTrue);

    await provider.signOut();
    expect(provider.isAuthenticated, isFalse);
    expect(provider.user, isNull);
  });
}

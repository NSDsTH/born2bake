import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _authStateSubscription;
  bool _isDisposed = false;
  User? _user;
  bool _isLoading = false;

  AuthProvider({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance {
    // ฟังการเปลี่ยนแปลงสถานะ (Session Persistence)
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (_isDisposed) return;
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authStateSubscription?.cancel();
    super.dispose();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  
  // เช็คว่าเป็น Admin หรือไม่
  bool get isAdmin => _user?.email == 'admin@borntobake.com';

  // ฟังก์ชัน Login
  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      _isLoading = false;
      notifyListeners();
      return null; // Null หมายถึงสำเร็จ ไม่มี Error
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message; // คืนค่า Error Message กลับไปแสดงผล
    }
  }

  // ฟังก์ชัน Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ฟังก์ชัน Register (สมัครสมาชิกใหม่)
  Future<String?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // คำสั่งสร้างบัญชีใหม่ของ Firebase
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      _isLoading = false;
      notifyListeners();
      return null; // Null หมายถึงสมัครสำเร็จ
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message; // คืนค่า Error Message กลับไปแสดงผล (เช่น อีเมลซ้ำ)
    }
  }
}
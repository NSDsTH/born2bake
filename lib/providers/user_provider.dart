import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  bool _hasSavedAddress = false;
  String _savedAddress = '';

  bool get hasSavedAddress => _hasSavedAddress;
  String get savedAddress => _savedAddress;

  // Constructor: สั่งให้โหลดที่อยู่ทันทีที่แอปเปิดขึ้นมา
  UserProvider() {
    _loadAddress();
  }

  // ฟังก์ชันดึงข้อมูลจาก Local Storage (SharedPreferences)
  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    // ดึงค่าที่อยู่ ถ้าไม่มีให้เป็นค่าว่าง
    _savedAddress = prefs.getString('user_address') ?? '';
    _hasSavedAddress = _savedAddress.isNotEmpty;
    notifyListeners();
  }

  // ฟังก์ชันบันทึกข้อมูลลง Local Storage
  Future<void> saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_address', address);
    _savedAddress = address;
    _hasSavedAddress = true;
    notifyListeners();
  }

  // ฟังก์ชันลบที่อยู่ (เผื่อต้องการใช้งาน)
  Future<void> clearAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_address');
    _savedAddress = '';
    _hasSavedAddress = false;
    notifyListeners();
  }
}
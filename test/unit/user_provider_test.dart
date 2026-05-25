import 'package:born2bake/providers/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ─── TC-U-USR-01 ──────────────────────────────────────────────────────────

  test('TC-U-USR-01: hasSavedAddress เป็น false เมื่อยังไม่มีที่อยู่ใน storage', () async {
    final provider = UserProvider();
    await Future.delayed(Duration.zero); // รอให้ _loadAddress() เสร็จ
    expect(provider.hasSavedAddress, isFalse);
    expect(provider.savedAddress, equals(''));
  });

  // ─── TC-U-USR-02 ──────────────────────────────────────────────────────────

  test('TC-U-USR-02: saveAddress บันทึกที่อยู่และอัปเดต state ได้ถูกต้อง', () async {
    final provider = UserProvider();
    await provider.saveAddress('123 ถนนสุขุมวิท กรุงเทพฯ');
    expect(provider.hasSavedAddress, isTrue);
    expect(provider.savedAddress, equals('123 ถนนสุขุมวิท กรุงเทพฯ'));
  });

  // ─── TC-U-USR-03 ──────────────────────────────────────────────────────────

  test('TC-U-USR-03: clearAddress ลบที่อยู่และ reset state กลับเป็นค่าว่าง', () async {
    final provider = UserProvider();
    await provider.saveAddress('456 ถนนทดสอบ');
    await provider.clearAddress();
    expect(provider.hasSavedAddress, isFalse);
    expect(provider.savedAddress, equals(''));
  });

  // ─── TC-U-USR-04 ──────────────────────────────────────────────────────────

  test('TC-U-USR-04: UserProvider โหลดที่อยู่ที่บันทึกไว้ก่อนหน้าตอน init', () async {
    SharedPreferences.setMockInitialValues({
      'user_address': '789 ถนน Bakery Lane',
    });
    final provider = UserProvider();
    await Future.delayed(Duration.zero);
    expect(provider.hasSavedAddress, isTrue);
    expect(provider.savedAddress, equals('789 ถนน Bakery Lane'));
  });

  // ─── TC-U-USR-05 ──────────────────────────────────────────────────────────

  test('TC-U-USR-05: saveAddress บันทึกลง SharedPreferences จริง (persistence)', () async {
    final provider = UserProvider();
    await provider.saveAddress('101 ถนน Persistent Road');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_address'), equals('101 ถนน Persistent Road'));
  });

  // ─── TC-U-USR-06 ──────────────────────────────────────────────────────────

  test('TC-U-USR-06: clearAddress ลบค่าออกจาก SharedPreferences จริง', () async {
    final provider = UserProvider();
    await provider.saveAddress('202 ถนนทดสอบ');
    await provider.clearAddress();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_address'), isNull);
  });
}

import 'package:born2bake/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:born2bake/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const existingPassword = 'Test1234!';
  late String existingEmail;
  late String signUpEmail;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    existingEmail = 'itest_login_${DateTime.now().millisecondsSinceEpoch}@born2bake.test';
    signUpEmail = 'itest_signup_${DateTime.now().millisecondsSinceEpoch}@born2bake.test';

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: existingEmail,
        password: existingPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
    }
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 500));
  });

  Finder fieldByLabel(String label) => find.bySemanticsLabel(label);

  // pump หลายครั้งแทน pumpAndSettle เพราะ Firebase stream ทำให้ settle ไม่ได้
  Future<void> settle(WidgetTester tester, {int seconds = 5}) async {
    await tester.pump();
    await tester.pump(Duration(seconds: seconds));
  }

  // ─── TC-I01 ───────────────────────────────────────────────────────────────
  testWidgets('TC-I01: Boot app and check Login Screen UI loads properly',
      (WidgetTester tester) async {
    app.main();
    await settle(tester, seconds: 8);

    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
    expect(find.text('สมัครสมาชิกเลย'), findsOneWidget);
  });

  // ─── TC-I02 ───────────────────────────────────────────────────────────────
  testWidgets('TC-I02: Firebase Real Authentication Sign Up Flow',
      (WidgetTester tester) async {
    app.main();
    await settle(tester, seconds: 8);

    await tester.tap(find.text('สมัครสมาชิกเลย'));
    await tester.pump(const Duration(seconds: 4));

    await tester.enterText(fieldByLabel('อีเมล'), signUpEmail);
    await tester.enterText(fieldByLabel('รหัสผ่าน'), existingPassword);
    await tester.enterText(fieldByLabel('ยืนยันรหัสผ่าน'), existingPassword);

    await tester.tap(find.widgetWithText(ElevatedButton, 'สมัครสมาชิก'));

    // Poll up to 25 s — createUserWithEmailAndPassword may be slower than signIn
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.text('Borntobake.1998').evaluate().isNotEmpty) break;
    }

    expect(find.text('Borntobake.1998'), findsOneWidget);
  });

  // ─── TC-I03 ───────────────────────────────────────────────────────────────
  testWidgets('TC-I03: Firebase Real Authentication Login Flow',
      (WidgetTester tester) async {
    app.main();
    await settle(tester, seconds: 8);

    await tester.enterText(fieldByLabel('อีเมล'), existingEmail);
    await tester.enterText(fieldByLabel('รหัสผ่าน'), existingPassword);

    await tester.tap(find.text('เข้าสู่ระบบ'));
    await settle(tester, seconds: 8);

    expect(find.text('Borntobake.1998'), findsOneWidget);
  });

  // ─── TC-I04 ───────────────────────────────────────────────────────────────
  testWidgets(
      'TC-I04: Multi-Screen Navigation — Login → Register → MainScreen → CartScreen',
      (WidgetTester tester) async {
    app.main();
    await settle(tester, seconds: 8);

    // Screen 1: LoginScreen
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);

    // Screen 2: RegisterScreen
    await tester.tap(find.text('สมัครสมาชิกเลย'));
    await tester.pump(const Duration(seconds: 3));
    expect(find.widgetWithText(ElevatedButton, 'สมัครสมาชิก'), findsOneWidget);

    // กลับไป LoginScreen — RegisterScreen uses Icons.arrow_back_ios_new
    final backArrow = find.byIcon(Icons.arrow_back_ios_new);
    if (backArrow.evaluate().isNotEmpty) {
      await tester.tap(backArrow.first);
    }
    await tester.pump(const Duration(seconds: 3));

    // Screen 3: MainScreen (after login)
    await tester.enterText(fieldByLabel('อีเมล'), existingEmail);
    await tester.enterText(fieldByLabel('รหัสผ่าน'), existingPassword);
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await settle(tester, seconds: 8);
    expect(find.text('Borntobake.1998'), findsOneWidget);

    // Screen 4: CartScreen
    final cartIcon = find.byIcon(Icons.shopping_cart_outlined);
    if (cartIcon.evaluate().isNotEmpty) {
      await tester.tap(cartIcon.first);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('ไม่มีสินค้าในตะกร้า'), findsOneWidget);
    }
  });
}

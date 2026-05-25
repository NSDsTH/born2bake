# born2bake

A new Flutter project.

## Flutter Widget Testing and Integration Testing Report

### 1. ข้อมูลนักศึกษา (Student Information)

- Student Name (ชื่อ-นามสกุล): Burathat Niamsomdee
- Student ID (รหัสนักศึกษา): 68130702307
- Date of Execution (วันที่ทำการทดสอบ): 2026-04-30

### 2. สภาพแวดล้อมการทดสอบ (Test Environment)

- Operating System (Host): macOS 26.2 25C56 darwin-arm64
- Flutter SDK Version: 3.38.9
- Dart SDK Version: 3.10.8
- Test Target Device (สำหรับ Integration Test): `sdk gphone16k arm64 (emulator-5554)` Android 17 Emulator

### 3. สรุปผลการทดสอบภาพรวม (Executive Test Summary)

| Test Level | Total Cases | Passed | Failed | Blocked | Execution Time |
|------------|-------------|--------|--------|---------|----------------|
| Widget Tests | 2 | 2 | 0 | 0 | 00:00:01 |
| Integration Tests | 3 | 3 | 0 | 0 | 00:02:49 |
| **Total** | **5** | **5** | **0** | **0** | **00:02:50** |

### 4. รายละเอียดผลการทดสอบ (Detailed Test Results)

#### Part 1: Widget Testing (Isolated Component Tests)

TC-W01: Empty Cart Screen renders correctly
- Objective: Verify that CartScreen แสดงข้อความตะกร้าว่างได้ถูกต้อง
- Input Data: ไม่มีสินค้าใน CartProvider
- Expected Result: เจอข้อความ `ไม่มีสินค้าในตะกร้า` และปุ่ม `ล้างตะกร้า`
- Actual Result: Pass — ผลลัพธ์ตรงตามคาด
- Evidence (Terminal Output):
  - `00:01 +2: All tests passed!`

TC-W02: Cart Screen renders product item and removes it when delete icon tapped
- Objective: Verify CartScreen แสดงสินค้าเมื่อมี item และลบได้เมื่อกดปุ่ม delete
- Input Data: มีสินค้า `Test Bakery Item` ในตะกร้า
- Expected Result: พบสินค้าใน widget tree, กด delete แล้วกลับสู่สถานะ `ไม่มีสินค้าในตะกร้า`
- Actual Result: Pass — ผลลัพธ์ตรงตามคาด
- Evidence (Terminal Output):
  - `00:01 +2: All tests passed!`

#### Part 2: Integration Testing (End-to-End Tests)

TC-I01: Basic Application Flow (No Network)
- Objective: Verify แอปบูตขึ้นและโหลดหน้า LoginScreen ได้ถูกต้อง
- Target Device: Android Emulator `sdk gphone16k arm64 (emulator-5554)`
- Expected Result: แอปติดตั้ง-บูต-แสดงหน้า Login โดยไม่มี framework exceptions
- Actual Result: Pass — หน้า `เข้าสู่ระบบ` และปุ่ม `สมัครสมาชิกเลย` ถูกแสดง
- Evidence (Log):
  - `02:49 +3: All tests passed!`

TC-I02: Firebase Real Authentication - Sign Up Flow
- Objective: Verify สมัครสมาชิก Firebase Auth สำเร็จ และนำทางไปหน้าเป้าหมายได้
- Test Data: dynamic email ที่สร้างด้วย timestamp, password `Test1234!`
- Expected Result: สร้างบัญชีสำเร็จ และแอปนำทางต่อได้โดยไม่มี error
- Actual Result: Pass — sign up สำเร็จและ test ผ่าน
- Evidence 1 (Terminal Output):
  - `02:49 +3: All tests passed!`
- Evidence 2 (Firebase Console):
  - ไม่ได้เก็บ screenshot จาก Firebase Console ในรอบนี้

TC-I03: Firebase Real Authentication - Login Flow
- Objective: Verify user เดิมสามารถ login ได้
- Test Data: email สร้างขึ้นจาก timestamp, password `Test1234!`
- Expected Result: login สำเร็จและแอปนำทางต่อได้ไม่มี permission error
- Actual Result: Pass — login สำเร็จและ test ผ่าน
- Evidence (Terminal Output):
  - `02:49 +3: All tests passed!`

### 5. ปัญหาและอุปสรรคที่พบ (Defects / Impediments)

1. Issue: Android SDK cmdline-tools ขาด
   - Root Cause: Android SDK ติดตั้งไม่ครบ และ `flutter doctor` แจ้ง missing cmdline-tools
   - Resolution: ติดตั้ง `cmdline-tools` ใน `/Users/burathat/Library/Android/sdk/cmdline-tools/latest`

2. Issue: ไม่มี Java runtime สำหรับ `sdkmanager`
   - Root Cause: macOS ไม่มี JDK ที่ sdkmanager ต้องการ
   - Resolution: ติดตั้ง `openjdk@17` ผ่าน Homebrew และกำหนด `JAVA_HOME`

3. Issue: `AuthProvider` ถูกเรียกใช้หลัง dispose
   - Root Cause: `authStateChanges()` ยังส่ง callback หลัง Provider ถูกทิ้ง
   - Resolution: เพิ่ม `_isDisposed` guard และ cancel subscription ใน `dispose()`

4. Issue: integration test tap ปุ่ม `สมัครสมาชิก` พบหลาย widget
   - Root Cause: มี `Text('สมัครสมาชิก')` ซ้ำใน widget tree
   - Resolution: แก้ test ให้ใช้ `find.widgetWithText(ElevatedButton, 'สมัครสมาชิก')`

### 6. บทสรุปและสิ่งที่ได้เรียนรู้ (Conclusion & Reflections)

การทดลองครั้งนี้ช่วยให้เข้าใจความแตกต่างระหว่าง widget test และ integration test อย่างชัดเจน: widget test เน้นความถูกต้องของ component เดียว ส่วน integration test ต้องดูทั้ง flow, environment, และ dependency ภายนอก เช่น Firebase กับ Android toolchain. นอกจากนี้ยังได้เรียนรู้ว่า `authStateChanges()` และ lifecycle ของ Provider ต้องจัดการให้ถูกต้องเพื่อหลีกเลี่ยง error หลัง dispose ใน E2E test.

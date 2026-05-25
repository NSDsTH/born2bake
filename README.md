# Borntobake.1998 (born2bake)

## 1. Project Title & Description
**Borntobake.1998** is a mobile e-commerce application designed to streamline the ordering process for a bakery business (operated by บริษัท โพลี่ ออฟฟิเชียล จำกัด). 

The application provides a seamless digital storefront where users can:
* Browse a catalog of bakery products (e.g., Shiopan, Cakes, Cookies).
* Customize orders (e.g., sweetness levels, add-ons).
* Manage their shopping cart and preferred delivery addresses via local storage.
* Securely register and log in using Firebase Authentication.
* Complete purchases and track order history powered by real-time Cloud Firestore.

## 2. Prerequisites
To build and run this project, ensure you have the following installed on your system:
* **Flutter SDK:** Version 3.x or higher
* **Dart SDK:** Included with Flutter
* **IDE:** VS Code, Android Studio, or IntelliJ IDEA
* **Platform Tools:** 
  * Android Studio with Android SDK and Emulator (for Android testing)
  * Xcode (for iOS testing, macOS only)
  * Chrome (for Web debugging)

## 3. Installation & Run Instructions
Follow these steps to set up and run the application locally:

**Step 1: Extract the project**
Unzip the submitted package and open the `born2bake` directory in your IDE.

**Step 2: Install dependencies**
Open the terminal at the project root and run:
```bash
flutter pub get
```

**Step 3: Run the application**
To run the app on a connected device or emulator, execute:
```bash
flutter run
```
*(Optional) To specify a device, use `flutter run -d <device_id>` (e.g., `flutter run -d chrome`).*

**Step 4: Clean the project (Before archiving)**
To clear build artifacts and reclaim disk space before zipping the project, run:
```bash
flutter clean
```

## 4. Testing Instructions

This project contains **42 automated test cases** across 3 levels (Unit, Widget, Integration) covering requirements R1–R5.

### 4.1 Unit Tests (32 tests) — No device required

Tests business logic in `AuthProvider`, `CartProvider`, and `UserProvider` using manual mock/fake classes (no real Firebase needed).

```bash
# Run all unit tests
flutter test test/unit/

# Run a specific file
flutter test test/unit/auth_provider_test.dart
flutter test test/unit/cart_provider_test.dart
flutter test test/unit/user_provider_test.dart
```

### 4.2 Widget Tests (2 tests) — No device required

Tests UI component rendering of `CartScreen`.

```bash
flutter test test/widget_test.dart
```

### 4.3 Run Unit + Widget Tests Together

```bash
flutter test test/
```

Expected output: `+34: All tests passed!`

### 4.4 Integration Tests — Android Emulator (4 tests)

Requires a running Android Emulator. Tests E2E flows with real Firebase Auth and Firestore.

```bash
# List available devices
flutter devices

# Run integration tests (replace emulator-5554 with your device ID)
flutter test integration_test/app_test.dart -d emulator-5554 --timeout 120s
```

Expected output: `+4: All tests passed!`

### 4.5 Integration Tests — Web Chrome (4 tests)

Requires [ChromeDriver](https://googlechromelabs.github.io/chrome-for-testing/) matching your Chrome version, placed in the project root.

```bash
# Option A: Use the provided script (starts ChromeDriver automatically)
./test_chrome.sh

# Option B: Manual
chromedriver --port=4444 &
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d chrome
```

Expected output: `All tests passed!`

> **Note:** `flutter test integration_test/... -d chrome` is not supported by Flutter — `flutter drive` is required for web integration tests.

---

## 5. Technical Report

### 5.1 Application Overview and Target Users
**Application Overview:**
Borntobake.1998 is a mobile e-commerce application designed to streamline the ordering process for a bakery business.  The application provides a seamless digital storefront where customers can browse bakery products, customize their orders (e.g., sweetness levels, add-ons), manage their shopping cart, and securely complete purchases.  The app integrates real-time cloud data management for order processing and user authentication to provide a personalized experience.

**Target Users:**
1. **Customers (General Users):** Individuals looking to browse and purchase bakery items easily through their mobile devices.  They require an intuitive interface for product selection, cart management, and order tracking. 
2. **Bakery Administrator (Admin):** The business owner or staff who need to manage the product catalog (adding, editing, or removing items) and monitor incoming orders. 

### 5.2 Application Architecture and Page Navigation
**Architecture:**
The application is built using the Flutter framework for cross-platform mobile development.  It employs the Provider pattern for state management, ensuring efficient data sharing and UI updates across different screens (e.g., `AuthProvider`, `CartProvider`, `UserProvider`).  The backend infrastructure relies on Firebase, utilizing Firebase Authentication for user identity management and Cloud Firestore for real-time NoSQL database operations. 

**Page Navigation Flow:**
The application utilizes Role-Based Routing to direct users to appropriate screens based on their authentication status and role. 
* **Entry Point (`LoginScreen`):** All users start here. Unauthenticated users can choose to log in or navigate to the `RegisterScreen`. 
* **Customer Flow:**
  * Upon successful login, customers are routed to the `MainScreen` (Storefront). 
  * From `MainScreen`, users can browse products, view details (`ProductDetailScreen`), and add items to their cart. 
  * The `CartScreen` allows users to review their selected items and proceed to checkout. 
  * Checkout involves the `AddressScreen` (if no saved address exists) and the `PaymentScreen` to confirm the order. 
  * Upon successful confirmation, the user is directed to the `SuccessScreen`. 
  * A Drawer menu in the `MainScreen` provides access to the `OrderHistoryScreen` and the logout function. 
* **Admin Flow:**
  * If the authenticated user matches the admin credentials (e.g., `admin@borntobake.com`), they are routed directly to the `AdminDashboardScreen` to manage products. 

### 5.3 Data Design

**Firebase Collections and Data Structures**
The application uses Cloud Firestore with a NoSQL document-based structure. 
* **Collection: `orders`**
  * Purpose: Stores customer order histories. 
  * Structure:
    * `userId` (String): The Firebase UID of the customer. 
    * `email` (String): The customer's email address. 
    * `items` (Array of Maps): Detailed list of purchased products. 
      * `productId` (String) 
      * `name` (String) 
      * `price` (Number) 
      * `quantity` (Number) 
      * `sweetness` (String) 
      * `addOns` (Array) 
    * `totalAmount` (Number): Total cost of the order. 
    * `paymentMethod` (String): Selected payment type. 
    * `address` (String): Delivery address or pickup location. 
    * `status` (String): Current order status (e.g., "รอการยืนยัน"). 
    * `timestamp` (Server Timestamp): Time the order was placed. 

*(Note: Product catalog data is also managed within Firestore, allowing the Admin Dashboard to dynamically update the storefront.)* 

**Local Storage Design and Usage**
To enhance the user experience, the application implements local data persistence using the `shared_preferences` package. 
* **Usage:** It stores the user's preferred delivery address locally on the device (`user_address` key). 
* **Benefit:** This prevents users from having to re-enter their address for every purchase.  The `UserProvider` manages the logic, checking for a saved address upon initialization.  If a saved address exists, the application automatically bypasses the `AddressScreen` during the checkout flow and proceeds directly to the `PaymentScreen`, streamlining the purchasing process. 

### 5.4 Security Considerations

**Authentication:**
The application relies on Firebase Authentication to securely manage user identities.  Users must register and log in using email and password credentials.  This ensures that sensitive order data and user profiles are tied to verified accounts. 

**Data Access Rules (High-Level):**
Security within the app is enforced through role-based access control implemented in the application logic and supported by Firestore Security Rules (implicitly required for production). 
* **Customer Access:** Customers are restricted to viewing the public product catalog and their own personal order history.  The `OrderHistoryScreen` explicitly queries the `orders` collection filtering by the current user's UID (`where('userId', isEqualTo: userId)`). 
* **Admin Access:** Administrative privileges (e.g., accessing the `AdminDashboardScreen` to modify the product catalog) are restricted to specific, predefined admin accounts. 

---

## 6. Testing and Test Scripts Report (SEA606)
*(Laboratory Test Report: Week 5)*[cite: 1]

### 6.1 Test Environment[cite: 1]
* **Operating System (Host):** macOS 26.2 25C56 darwin-arm64  
* **Flutter SDK Version:** 3.38.9  
* **Dart SDK Version:** 3.10.8  
* **Test Target Device:** `sdk gphone16k arm64 (emulator-5554)` Android 17 Emulator  

### 6.2 Executive Test Summary[cite: 1]

| Test Level | Total Cases | Passed | Failed | Blocked | Execution Time |  
|---|---|---|---|---|---|  
| Unit Tests | 32 | 32 | 0 | 0 | ~00:00:02 |  
| Widget Tests | 2 | 2 | 0 | 0 | ~00:00:01 |  
| Integration Tests — Android | 4 | 4 | 0 | 0 | ~00:01:18 |  
| Integration Tests — Chrome | 4 | 4 | 0 | 0 | ~00:06:01 |  
| **Total** | **42** | **42** | **0** | **0** | **~00:07:22** |  

### 6.3 Detailed Test Results[cite: 1]

**Part 1: Widget Testing (Isolated Component Tests)**  
* **TC-W01: Empty Cart Screen renders correctly**  
  * **Objective:** Verify that CartScreen แสดงข้อความตะกร้าว่างได้ถูกต้อง  
  * **Input Data:** ไม่มีสินค้าใน CartProvider  
  * **Expected Result:** เจอข้อความ `ไม่มีสินค้าในตะกร้า` และปุ่ม `ล้างตะกร้า`  
  * **Actual Result:** Pass — ผลลัพธ์ตรงตามคาด  
  * **Evidence:** `00:01 +2: All tests passed!`  
* **TC-W02: Cart Screen renders product item and removes it when delete icon tapped**  
  * **Objective:** Verify CartScreen แสดงสินค้าเมื่อมี item และลบได้เมื่อกดปุ่ม delete  
  * **Input Data:** มีสินค้า `Test Bakery Item` ในตะกร้า  
  * **Expected Result:** พบสินค้าใน widget tree, กด delete แล้วกลับสู่สถานะ `ไม่มีสินค้าในตะกร้า`  
  * **Actual Result:** Pass — ผลลัพธ์ตรงตามคาด  
  * **Evidence:** `00:01 +2: All tests passed!`  

**Part 2: Integration Testing (End-to-End Tests)**  
* **TC-I01: Basic Application Flow (No Network)**  
  * **Objective:** Verify แอปบูตขึ้นและโหลดหน้า LoginScreen ได้ถูกต้อง  
  * **Expected Result:** แอปติดตั้ง-บูต-แสดงหน้า Login โดยไม่มี framework exceptions  
  * **Actual Result:** Pass — หน้า `เข้าสู่ระบบ` และปุ่ม `สมัครสมาชิกเลย` ถูกแสดง  
  * **Evidence:** `02:49 +3: All tests passed!`  
* **TC-I02: Firebase Real Authentication - Sign Up Flow**  
  * **Objective:** Verify สมัครสมาชิก Firebase Auth สำเร็จ และนำทางไปหน้าเป้าหมายได้  
  * **Expected Result:** สร้างบัญชีสำเร็จ และแอปนำทางต่อได้โดยไม่มี error  
  * **Actual Result:** Pass — sign up สำเร็จและ test ผ่าน  
  * **Evidence:** `02:49 +3: All tests passed!`  
* **TC-I03: Firebase Real Authentication - Login Flow**  
  * **Objective:** Verify user เดิมสามารถ login ได้  
  * **Expected Result:** login สำเร็จและแอปนำทางต่อได้ไม่มี permission error  
  * **Actual Result:** Pass — login สำเร็จและ test ผ่าน  
  * **Evidence:** `02:49 +3: All tests passed!`  

### 6.4 Defects / Impediments[cite: 1]
1. **Issue:** Android SDK cmdline-tools ขาด  
   * **Root Cause:** Android SDK ติดตั้งไม่ครบ และ `flutter doctor` แจ้ง missing cmdline-tools  
   * **Resolution:** ติดตั้ง `cmdline-tools` ใน `/Users/burathat/Library/Android/sdk/cmdline-tools/latest`  
2. **Issue:** ไม่มี Java runtime สำหรับ `sdkmanager`  
   * **Root Cause:** macOS ไม่มี JDK ที่ sdkmanager ต้องการ  
   * **Resolution:** ติดตั้ง `openjdk@17` ผ่าน Homebrew และกำหนด `JAVA_HOME`  
3. **Issue:** `AuthProvider` ถูกเรียกใช้หลัง dispose  
   * **Root Cause:** `authStateChanges()` ยังส่ง callback หลัง Provider ถูกทิ้ง  
   * **Resolution:** เพิ่ม `_isDisposed` guard และ cancel subscription ใน `dispose()`  
4. **Issue:** integration test tap ปุ่ม `สมัครสมาชิก` พบหลาย widget  
   * **Root Cause:** มี `Text('สมัครสมาชิก')` ซ้ำใน widget tree  
   * **Resolution:** แก้ test ให้ใช้ `find.widgetWithText(ElevatedButton, 'สมัครสมาชิก')`  

### 6.5 Conclusion & Reflections[cite: 1]
การทดลองครั้งนี้ช่วยให้เข้าใจความแตกต่างระหว่าง widget test และ integration test อย่างชัดเจน: widget test เน้นความถูกต้องของ component เดียว ส่วน integration test ต้องดูทั้ง flow, environment, และ dependency ภายนอก เช่น Firebase กับ Android toolchain.   นอกจากนี้ยังได้เรียนรู้ว่า `authStateChanges()` และ lifecycle ของ Provider ต้องจัดการให้ถูกต้องเพื่อหลีกเลี่ยง error หลัง dispose ใน E2E test.  
```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:born2bake/providers/cart_provider.dart';
import 'package:born2bake/screens/success_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:born2bake/providers/auth_provider.dart';
import 'package:born2bake/providers/user_provider.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color primaryGreen = const Color(0xFF2A5D50);
  final Color primaryRed = const Color(0xFFEF4444);
  
  // สร้างตัวแปรเก็บสถานะการเลือกวิธีชำระเงิน
  // 1 = ชำระเงินปลายทาง (จัดส่ง), 2 = รับและชำระเงินที่หน้าร้าน
  int selectedPaymentMethod = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ช่องทางการชำระเงิน',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'เลือกรูปแบบการชำระเงิน',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Option 1: ชำระเงินปลายทาง
                  _buildPaymentOption(
                    value: 1,
                    title: 'ชำระเงินปลายทาง (Cash on Delivery)',
                    subtitle: 'ชำระเงินสดหรือโอนจ่ายกับพนักงานจัดส่งเมื่อได้รับสินค้า',
                    icon: Icons.local_shipping_outlined,
                  ),
                  const SizedBox(height: 12),

                  // Option 2: ชำระเงินที่หน้าร้าน
                  _buildPaymentOption(
                    value: 2,
                    title: 'รับและชำระเงินที่หน้าร้าน (Pick up at store)',
                    subtitle: 'มารับสินค้าและชำระเงินที่สาขาร้อยเอ็ด',
                    icon: Icons.storefront_outlined,
                  ),
                ],
              ),
            ),
          ),
          
          // ปุ่มยืนยันคำสั่งซื้อด้านล่าง
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    // 1. ดึง Provider ที่จำเป็น
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    final userProvider = Provider.of<UserProvider>(context, listen: false);

                    final userId = authProvider.user?.uid;
                    final userEmail = authProvider.user?.email;

                    if (userId != null && cartProvider.items.isNotEmpty) {
                      // 2. จัดเตรียม Data Model สำหรับ Order
                      final orderData = {
                        'userId': userId,
                        'email': userEmail,
                        'items': cartProvider.items.values.map((item) => {
                          'productId': item.product.id,
                          'name': item.product.name,
                          'price': item.itemTotalPrice,
                          'quantity': item.quantity,
                          'sweetness': item.sweetness,
                          'addOns': item.addOns,
                        }).toList(),
                        'totalAmount': cartProvider.totalAmount,
                        'paymentMethod': selectedPaymentMethod == 1 ? 'Cash on Delivery' : 'Pick up at store',
                        'address': selectedPaymentMethod == 1 ? userProvider.savedAddress : 'รับที่สาขาร้อยเอ็ด',
                        'status': 'รอการยืนยัน', // สถานะเริ่มต้นของออเดอร์
                        'timestamp': FieldValue.serverTimestamp(), // ประทับเวลาจาก Server
                      };

                      try {
                        // 3. บันทึกลง Cloud Firestore ใน Collection 'orders'
                        await FirebaseFirestore.instance.collection('orders').add(orderData);
                        print('Order saved successfully: $orderData');

                        // 4. เคลียร์ข้อมูลในตะกร้า
                        cartProvider.clear();

                        if (!context.mounted) return;

                        // 5. นำทางไปยังหน้า Success Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SuccessScreen()),
                        );
                      } catch (e) {
                        print('Error saving order: $e');
                        // แสดง error dialog หรือ snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกคำสั่งซื้อ: $e')),
                        );
                      }
                    } else {
                      // ถ้าไม่ได้ login หรือไม่มีสินค้าในตะกร้า
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณาเข้าสู่ระบบและมีสินค้าในตะกร้าก่อน')),
                      );
                    }
                  },
                  child: const Text('ยืนยันคำสั่งซื้อ', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper สำหรับสร้างตัวเลือกช่องทางชำระเงิน
  Widget _buildPaymentOption({
    required int value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedPaymentMethod == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen.withAlpha(25) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? primaryGreen : Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ปุ่มวงกลมเลือกสถานะ (Radio UI)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:born2bake/providers/cart_provider.dart';
import 'package:born2bake/providers/user_provider.dart';
import 'package:born2bake/screens/address_screen.dart';
import 'package:born2bake/screens/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  final Color primaryGreen = const Color(0xFF2A5D50);
  final Color primaryOrange = const Color(0xFFF97316);
  final Color primaryRed = const Color(0xFFEF4444);
  final Color lightGreyBg = const Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'รายการสั่งซื้อที่ สาขาร้อยเอ็ด',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'ไม่มีสินค้าในตะกร้า',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนเพิ่มข้อมูลที่อยู่
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'เพิ่มข้อมูลที่อยู่',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '*จัดส่งเฉพาะบริเวณร้านเท่านั้น',
                              style: TextStyle(color: primaryOrange, fontSize: 12),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // รายการที่สั่ง
                  const Text(
                    'รายการที่สั่ง',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // ลิสต์รายการสินค้า
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItemKey = cart.items.keys.toList()[index];
                      final cartItem = cart.items.values.toList()[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // รูปภาพ
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  cartItem.product.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // รายละเอียดและราคา
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cartItem.product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '฿${cartItem.itemTotalPrice.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryGreen,
                                            ),
                                          ),
                                          if (cartItem.product.originalPrice != null)
                                            Text(
                                              cartItem.product.originalPrice!.toStringAsFixed(0),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // ปุ่มปรับจำนวน และปุ่มลบ
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _buildQuantityButton(Icons.remove, () {
                                            cart.decrementQuantity(cartItemKey);
                                          }),
                                          Container(
                                            width: 30,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${cartItem.quantity}',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          _buildQuantityButton(Icons.add, () {
                                            cart.incrementQuantity(cartItemKey);
                                          }),
                                        ],
                                      ),
                                      IconButton(
                                        key: Key('delete-$cartItemKey'),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          cart.removeItem(cartItemKey);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32, thickness: 1, color: Colors.grey),

                  // คูปอง
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_activity, color: primaryGreen, size: 20),
                          const SizedBox(width: 8),
                          const Text('ใช้คูปองหรือ รหัสส่วนลด', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('ใช้', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1, color: Colors.grey),

                  // สรุปยอด
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('รวมราคาสินค้า', style: TextStyle(color: Colors.grey)),
                      Text('${cart.totalAmount.toStringAsFixed(0)} บาท', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ยอดรวม (สุทธิ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${cart.totalAmount.toStringAsFixed(0)} บาท',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1, color: Colors.grey),
                ],
              ),
            ),

      // 5. Bottom Buttons (ล้างตะกร้า, สั่งเพิ่ม, ยืนยัน)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreyBg,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('ล้างตะกร้า', style: TextStyle(fontSize: 14)),
                      onPressed: () => cart.clear(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      label: const Text('สั่งเพิ่ม', style: TextStyle(color: Colors.white, fontSize: 14)),
                      onPressed: () {
                        // กลับไปยังหน้าแรกสุด (MainScreen)
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: cart.items.isEmpty 
                    ? null 
                    : () {
                        // ดึงข้อมูลสถานะที่อยู่ของผู้ใช้
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        
                        if (userProvider.hasSavedAddress) {
                          // ถ้ามีที่อยู่แล้ว -> ไปหน้าชำระเงิน
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentScreen()),
                          );
                        } else {
                          // ถ้ายังไม่มีที่อยู่ -> ไปหน้ากรอกที่อยู่
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddressScreen()),
                          );
                        }
                      },
                  child: const Text('ยืนยันคำสั่งซื้อ', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สำหรับปุ่มปรับจำนวน (ดีไซน์กล่องสี่เหลี่ยมตามภาพ)
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[700]),
      ),
    );
  }
}
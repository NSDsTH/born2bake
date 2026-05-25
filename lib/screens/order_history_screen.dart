import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:born2bake/providers/auth_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF2A5D50);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    print('OrderHistoryScreen: userId = $userId');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text('ประวัติการสั่งซื้อ', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: Text('กรุณาเข้าสู่ระบบก่อน'))
          : StreamBuilder<QuerySnapshot>(
              // Query ดึงข้อมูล order ของ User คนนี้ เรียงจากใหม่ไปเก่า
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: userId)
                  // .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No orders found for userId: $userId');
                  return const Center(
                    child: Text('ยังไม่มีประวัติการสั่งซื้อ', style: TextStyle(color: Colors.grey)),
                  );
                }

                final orders = snapshot.data!.docs;
                print('Found ${orders.length} orders for userId: $userId');

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final data = orders[index].data() as Map<String, dynamic>;
                    final items = data['items'] as List<dynamic>;
                    final totalAmount = data['totalAmount'];
                    final status = data['status'];
                    
                    // จัดการ Format วันที่
                    final timestamp = data['timestamp'] as Timestamp?;
                    final dateStr = timestamp != null 
                        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}' 
                        : 'กำลังประมวลผล...';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('วันที่: $dateStr', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'รอการยืนยัน' ? Colors.orange.withAlpha(50) : primaryGreen.withAlpha(50),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'รอการยืนยัน' ? Colors.orange[800] : primaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // ลูปแสดงรายการสินค้าที่สั่งในออเดอร์นี้
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item['quantity']}x ${item['name']}'),
                                    Text('฿${item['price'] * item['quantity']}'),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ยอดรวมทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('฿$totalAmount', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
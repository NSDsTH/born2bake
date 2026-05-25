import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:born2bake/models/product.dart';
import 'package:born2bake/widgets/product_card.dart';
import 'package:born2bake/screens/cart_screen.dart'; // ถูกเรียกใช้ที่ปุ่มตะกร้าแล้ว

import 'package:provider/provider.dart';
import 'package:born2bake/providers/auth_provider.dart';
import 'package:born2bake/screens/login_screen.dart';

import 'package:born2bake/screens/order_history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Color primaryBrandColor = const Color(0xFFE75B43);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ฟังก์ชันสำหรับ Upload Mock Data แบบด่วน (ใช้แค่ครั้งเดียวแล้วลบทิ้งได้เลย)
  Future<void> _uploadMockDataToFirestore() async {
    try {
      // อัปโหลด Category
      for (var cat in mockCategories) {
        await _firestore.collection('categories').doc(cat.id).set(cat.toMap());
      }
      // อัปโหลด Product
      for (var prod in mockProducts) {
        await _firestore.collection('products').doc(prod.id).set({
          'name': prod.name,
          'description': prod.description,
          'price': prod.price,
          'originalPrice': prod.originalPrice,
          'categoryId': prod.categoryId, // ใช้ categoryId ตามที่แก้ Model แล้ว
          'imageUrl': prod.imageUrl,
          'isOutOfStock': prod.isOutOfStock,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("อัปโหลดข้อมูลสำเร็จ!")));
    } catch (e) {
      print("Error Uploading Data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // นำ AppBar ที่มีปุ่มตะกร้ากลับมา
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Borntobake.1998', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFF2A5D50)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // ดึงข้อมูล Categories จาก Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!categorySnapshot.hasData || categorySnapshot.data!.docs.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: _uploadMockDataToFirestore,
                child: const Text("กดเพื่อ Upload ข้อมูลจำลองขึ้น Firestore (ทำครั้งเดียว)"),
              ),
            );
          }

          final categories = categorySnapshot.data!.docs.map((doc) {
            return Category.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return DefaultTabController(
            length: categories.length,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    pinned: true,
                    floating: true,
                    elevation: 0,
                    // ซ่อนปุ่มย้อนกลับอัตโนมัติ (เผื่อหลุดมาจากหน้า Login)
                    automaticallyImplyLeading: false, 
                    bottom: TabBar(
                      isScrollable: true,
                      labelColor: primaryBrandColor,
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: primaryBrandColor,
                      indicatorWeight: 3.0,
                      tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
                    ),
                  ),
                ];
              },
              
              // ดึงข้อมูล Products ตามหมวดหมู่
              body: TabBarView(
                children: categories.map((category) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('products')
                        .where('categoryId', isEqualTo: category.id)
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("ไม่มีสินค้าในหมวดหมู่นี้", style: TextStyle(color: Colors.grey)));
                      }

                      final products = productSnapshot.data!.docs.map((doc) {
                        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      }).toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.65, // ปรับอัตราส่วนให้พอดีกับ ProductCard ที่มีรายละเอียด
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF2A5D50), // ใช้สีเขียวแบรนด์
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Borntobake.1998',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // ใช้ Consumer เพื่อดึง Email ของ User ปัจจุบันมาแสดง
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        authProvider.user?.email ?? 'ลูกค้า',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      );
                    },
                  ),
                ],
              ),
            ),

            // เมนูประวัติการสั่งซื้อ
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.grey),
              title: const Text('ประวัติการสั่งซื้อ'),
              onTap: () {
                // ปิด Drawer ก่อน
                Navigator.pop(context); 
                // Navigate ไปยังหน้า Order History
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
            ),
            
            const Divider(),
            
            // เมนูออกจากระบบ
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                // 1. เรียกใช้คำสั่ง Sign Out
                await Provider.of<AuthProvider>(context, listen: false).signOut();
                
                if (!context.mounted) return;
                
                // 2. เคลียร์หน้าจอทั้งหมดและพากลับไปหน้า Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, 
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 